require 'securerandom'

class MainServer

  # The root route
  # ==========================================================
  #
  
  # the GET version of POST urls just render the root page
  # this doesn't happen unless there's an error but it's handy anyway.
  get [
    '/', '/browser', 'create_command', 'delete_command', 'run_command',
    'update_command', 'run_module', 'new_module', 'delete_module',
    'sync_module_commands', 'sync_all_modules', 'export_module'
  ] do
    # Upgrade the connection to websocket, if possible,
    # and initialize the websocket event listeners.
    if Faye::WebSocket.websocket?(request.env) 
      Websockets.setup_client request
    else
      # For standard HTTP requests, render views/root.erb
      # Other than views/layout.erb this is the only view file.
      slim :root
    end
  end

  # API routes
  # =========================================================
  #

  # Create a command with params:
  # name: String
  # command: String (ruby code)
  #
  post '/create_command' do
    name, command = params.values_at(:name, :command)
    commandObj = { name: name, command: command }
    id = SecureRandom.urlsafe_base64
    Db.transaction { Db[:commands][id] = commandObj }
    redirect '/'
  end

  # Update a command with params:
  # id: String
  # name: String
  # command: String (ruby code)
  #
  post '/update_command' do
    id = params[:id]
    name, command = params.values_at(:name, :command)
    commandObj = { name: name, command: command }
    Db.transaction { Db[:commands][id] = commandObj }
    redirect '/'
  end

  # Delete a command with params:
  # id: String
  #
  post '/delete_command' do
    command_id = params[:id]
    Db.transaction do
      Db[:commands].delete command_id
      Db[:modules].each do |module_id, moduleObj|
        moduleObj[:commands].delete_if do |command_id|
          command_id = command_id
        end
      end
    end
    redirect '/'
  end

  # Run a command with params:
  # id: String
  #
  post '/run_command' do
    id = params[:id]
    command = Db.transaction { Db[:commands][id][:command] } 
    @results, @err = Browser.execute_command(command)
    slim :root
  end

  # Create a module with params:
  # name: String
  #
  post '/new_module' do
    name = params[:name]
    id = SecureRandom.urlsafe_base64
    moduleObj = { name: name, commands: [] }
    Db.transaction { Db[:modules][id] = moduleObj }
    redirect '/'
  end

  # Delete a module with params:
  # id: String
  #
  post '/delete_module' do
    id = params[:id]
    Db.transaction { Db[:modules].delete id }
    redirect '/'
  end

  # Sync module commands with params:
  # moduleId: String
  # commandList: String (comma-separated command ids)
  #
  post '/sync_module_commands' do
    module_id = params[:moduleId]
    command_list = params[:commandIds].split(",")
    sync_module(module_id, command_list)
    redirect '/'
  end

  # Sync all modules with params:
  # modules: Array
  #          - each item is also an array: [index, moduleObj]
  #          - moduleObj is a hash with keys:
  #            id: Strig
  #            commandIds: String (comma-separated command ids)#
  #
  post '/sync_all_modules' do
    params[:modules]&.each do |moduleObj|
      moduleObj = moduleObj[1] # $.post includes indexes with arrays; ignore it
      sync_module(moduleObj['id'], moduleObj['commandIds'])
    end
    redirect '/'
  end

  # Run a module with params:
  # id: String
  # interval: Integer
  # Runs commands one-by-one and incrementally sends results over websockets.
  #
  post '/run_module' do
    id = params[:id]
    interval = params[:interval] || 1 # default num seconds between commands
    commands = get_commands(id)
    run_commands(commands, interval)
  end

  # Export a module with params:
  # id: String
  # filename: String (something like 'my_file.rb')
  #
  post '/export_module' do
    id = params[:id]
    commands = get_commands(id)
    filename = params[:name]
    if filename.chars.any? { |char| !char =~ /[a-zA-Z0-9\_\.]/ }
      @err = "File name is not valid - only use alphaneumerics, underscore, and period"
    else
      File.open("export/#{filename}", "w") do |f|
        commands.each do |command|
          string = "\# #{command[:name]}\n#{command[:command]}\n\n"
          f.write string
        end
      end
    end
    slim :root
  end

  private

  # Lookup the list of commands belonging to a module
  #
  def get_commands(module_id)
    Db.transaction { Db[:modules][module_id][:commands] }.map do |cmd_id|
      Db.transaction { Db[:commands][cmd_id] }
    end
  end

  # Define the list of commands that belong to a module
  # There are no individual push / pop calls here - 
  # to change the list you have to redefine it
  #
  def sync_module(module_id, command_list)
    Db.transaction do
      Db[:modules][module_id][:commands] = command_list
    end
  end

  # run a sequence of commands one-by-one,
  # pausing for <interval> seconds between each.
  # This is asynchronous, and will send the results over websockets
  # TODO: prevent race conditions here
  #
  def run_commands(commands, interval)
    Thread.new do
      commands.each do |command|
        @results, @err = Browser.execute_command(command[:command])
        Websockets.send_to_all({
          log: {
            results: @results,
            error: @err
          }
        })
        sleep interval.to_i
      end
    end
    slim :root
  end
  
end