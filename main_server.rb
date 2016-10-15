require 'sinatra/base'

require 'pry'
require 'selenium-webdriver'
require 'capybara'
require 'capybara/dsl'
require 'awesome_print'

# Class is extended by files in lib/
class MainServer < Sinatra::Base
end

require_relative './lib/core_utils'
include CoreUtils

require_relative './lib/browser'
require_relative './lib/routes'
