require './main_server'

ENV["RACK_ENV"] ||= "production"

run MainServer