# load environment varaible data from the .env file
# Using this is optional
require 'dotenv'
Dotenv.load

# Fake data
require 'faker'

# Very simple database
require 'pstore'
Db = PStore.new "database.pstore"
Db.transaction { Db[:commands] ||= {} }
Db.transaction { Db[:modules] ||= {} }

# Sinatra
require 'sinatra/base'

# Pry (debugging)
require 'pry'

# Selenium
require 'selenium-webdriver'

# Capybara
require 'capybara'
require 'capybara/dsl'

# Awesome Print
require 'awesome_print'

# Faye-websocket
require 'faye/websocket'
require 'thin'
Faye::WebSocket.load_adapter('thin')


# MainServer class definition
# it's extended by files in lib/
class MainServer < Sinatra::Base
end

# Core utils
require_relative './lib/core_utils'

# Capybara / Selenium config
require_relative './capybara_driver.rb'

# Methods added to capybara
require_relative './driver_helpers.rb'

# Automated browser API
require_relative './lib/browser'
Driver = MainServer::Browser::Driver

# HTTP routes
require_relative './lib/routes'

# Websocket API
require_relative './lib/websockets'