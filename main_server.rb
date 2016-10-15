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
include CoreUtils

# Automated browser API
require_relative './lib/browser'

# HTTP routes
require_relative './lib/routes'

# Websocket API
require_relative './lib/websockets'