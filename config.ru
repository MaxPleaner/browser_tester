require './main_server'
require './lib/websocket_middleware'

ENV["RACK_ENV"] ||= "development"

run WebsocketMiddleware
run MainServer