class MainServer::Websockets

  KEEPALIVE_TIME = 15000 # in seconds

  Clients = []

  def self.setup_client(request)
    ws = Faye::WebSocket.new(request.env, [],{ping: KEEPALIVE_TIME })
    ws.on(:open) { |event| onopen ws, event }
    ws.on(:message) { |event| onmessage ws, event }
    ws.on(:close) { |event| onclose ws, event }
    ws.rack_response
  end

  def self.onopen(ws, event)
    Clients << ws
  end

  def self.onmessage(ws, event)
    data = event.data
  end

  def self.onclose(ws, event)
    Clients.delete ws
  end

  # Only try and send stuff that can be converted to JSON
  def self.send_message(client, object)
    client.send(object.to_json)
  end
  
  def self.send_to_all(object)
    Clients.each { |client| send_message client, object }
  end

end
