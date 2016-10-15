require 'faye/websocket'

class WebsocketMiddleware
  KEEPALIVE_TIME = 15 # in seconds

  def initialize(app)
    @app     = app
    @clients = []
  end

  def call(env)
    if Faye::WebSocket.websocket?(env)
      ws = Faye::WebSocket.new(env, nil, {ping: KEEPALIVE_TIME })
      ws.on(:open) { |event| onopen ws, event }
      ws.on(:message) { |event| onmessage ws, event }
      ws.on(:close) { |event| onclose ws, event }
      ws.rack_response
    else
      @app.call env
    end
  end

  def onopen(ws, event)
    @clients << ws
  end

  def onmessage(ws, event)
    data = event.data
    send_message(ws, "hello from server")
  end

  def onclose(ws, event)
    @clients.delete ws
  end

  def send_message(client, data)
    client.send(data)
  end

end
