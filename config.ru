require './main_server'

ENV["RACK_ENV"] ||= "development"

run MainServer