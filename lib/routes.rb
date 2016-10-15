class MainServer

  get ['/', '/browser'] do
    if Faye::WebSocket.websocket?(request.env) 
      Websockets.setup_client request
    else
      slim :root
    end
  end

  post '/browser' do
    @results, @err = Browser.execute_command(params[:cmd])
    slim :root
  end
  
end