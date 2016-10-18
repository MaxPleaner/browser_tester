class MainServer::Websockets

  KEEPALIVE_TIME = 15000 # in seconds
                         # TODO: set this to a proper number

  # A globally accessible list of socket connections
  Clients = []

  # Create a new websocket connection
  def self.setup_client(request)
    ws = Faye::WebSocket.new(request.env, [],{ping: KEEPALIVE_TIME })
    ws.on(:open) { |event| onopen ws, event }
    ws.on(:message) { |event| onmessage ws, event }
    ws.on(:close) { |event| onclose ws, event }
    ws.rack_response
  end

  # The event when a socket opens
  def self.onopen(ws, event)
    Clients << ws
  end

  # The event when the server gets a message; not used
  def self.onmessage(ws, event)
    # data = event.data
  end

  # The event when a socket closes
  def self.onclose(ws, event)
    Clients.delete ws
  end

  # Method to send a message to a specific client
  # The object passed to this method should be convertable to JSON
  def self.send_message(client, object)
    client.send(object.to_json)
  end
  
  # Method to send a message to all clients
  # Functionally, since this app only supports a single user
  # and there is no code implemented to track users,
  # `send_message` is never called directly, only `send_to_all`.
  def self.send_to_all(object)
    Clients.each { |client| send_message client, object }
  end

end
