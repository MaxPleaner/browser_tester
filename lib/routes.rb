require 'securerandom'

class MainServer

  # the GET version of POST urls just render the root page
  # this shouldn't ever happen in production but helps a bit in development
  get [
    '/', '/browser', 'create_command', 'delete_command', 'run_command',
    'update_command'
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
    id = params[:id]
    Db.transaction { Db[:commands].delete id }
    redirect '/'
  end

  post '/run_command' do
    id = params[:id]
    command = Db.transaction { Db[:commands][id][:command] } 
    @results, @err = Browser.execute_command(command)
    slim :root
  end
  
end