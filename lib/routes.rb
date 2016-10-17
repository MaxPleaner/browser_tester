require 'securerandom'

class MainServer

  # the GET version of POST urls just render the root page
  # this shouldn't ever happen in production but helps a bit in development
  get [
    '/', '/browser', 'create_command', 'delete_command', 'run_command',
    'update_command', 'run_module', 'new_module', 'delete_module',
    'sync_module_commands', 'sync_all_modules'
  ] do
    if Faye::WebSocket.websocket?(request.env) 
      Websockets.setup_client request
    else
      slim :root
    end
  end

  post '/create_command' do
    name, command = params.values_at(:name, :command)
    commandObj = { name: name, command: command }
    id = SecureRandom.urlsafe_base64
    Db.transaction { Db[:commands][id] = commandObj }
    redirect '/'
  end

  post '/update_command' do
    id = params[:id]
    name, command = params.values_at(:name, :command)
    commandObj = { name: name, command: command }
    Db.transaction { Db[:commands][id] = commandObj }
    redirect '/'
  end

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

  post '/run_command' do
    id = params[:id]
    command = Db.transaction { Db[:commands][id][:command] } 
    @results, @err = Browser.execute_command(command)
    slim :root
  end

  post '/new_module' do
    name = params[:name]
    id = SecureRandom.urlsafe_base64
    moduleObj = { name: name, commands: [] }
    Db.transaction { Db[:modules][id] = moduleObj }
    redirect '/'
  end

  post '/delete_module' do
    id = params[:id]
    Db.transaction { Db[:modules].delete id }
    redirect '/'
  end

  post '/sync_module_commands' do
    module_id = params[:moduleId]
    command_list = params[:commandIds].split(",")
    sync_module(module_id, command_list)
    redirect '/'
  end

  post '/sync_all_modules' do
    params[:modules]&.each do |moduleObj|
      moduleObj = moduleObj[1] # $.post includes indexes with arrays; ignore it
      sync_module(moduleObj['id'], moduleObj['commandIds'])
    end
    redirect '/'
  end

  post '/run_module' do
    id = params[:id]
    interval = params[:interval] || 1 # default num seconds between commands
    commands = Db.transaction { Db[:modules][id][:commands] }.map do |cmd_id|
      Db.transaction { Db[:commands][cmd_id] }
    end
    run_commands(commands, interval)
  end

  post '/export_module' do
  end

  private

  def sync_module(module_id, command_list)
    Db.transaction do
      Db[:modules][module_id][:commands] = command_list
    end
  end

  def run_commands(commands, interval)
    # Thread.new do
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
    # end
    slim :root
  end
  
end