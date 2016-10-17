require_relative './delegate_to_driver'
require_relative './capybara_driver.rb'
require_relative './driver_helpers.rb'

class BrowserIsClosedError < StandardError; end

class MainServer::Browser

  Driver = CapybaraDriver.new_driver

  # extra methods made available to user-defined commands
  Driver.class.class_exec { include DriverHelpers::InstanceMethods }
  Driver.class.class_exec { extend DriverHelpers::ClassMethods }

  # returns [results or nil, err_string or nil]
  def self.execute_command(cmd_string)
    begin
      binding.pry
      cmd_result = with_dsl { eval cmd_string }
      ensure_chrome_is_reachable(cmd_result)
    rescue BrowserIsClosedError
      retry
    rescue Exception => e
      [nil, build_error_string(e)]
    end
  end

  def self.with_dsl(&blk)
    Driver.instance_exec &blk
  end

  def self.screenshot(page, path, open=false)
    fn = open ? :save_and_open_screenshot : :save_screenshot
    page.send(fn, path)
  end

  def self.ensure_chrome_is_reachable(eval_result)
    if eval_result.is_a?(Hash) && is_disconnected?(eval_result['message'])
      const_set(:Driver, CapybaraDriver.new_driver)
      raise BrowserIsClosedError
    end
    [eval_result, nil]
  end

  def self.is_disconnected?(msg)
    ["chrome not reachable", "disconnected"].any? do |str|
      msg.include?(str)
    end
  end

end
