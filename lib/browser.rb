
# A custom error class; for when the browser has been manually closed
# The browser will be relaunched so the server doesn't have to restart
#
class BrowserIsClosedError < StandardError; end

# The Browser class is a wrapper over capybara / selenium
#
class MainServer::Browser

  # Start the capybara / selenium driver
  #
  Driver = CapybaraDriver.new_driver

  # extra methods made available to user-defined commands
  #
  Driver.class.class_exec { include DriverHelpers }

  # Eval a string containing Ruby code.
  # The eval is run in the scope of Driver
  # This means that capybara methods such as `visit` are available
  # at top-level scope (with an implicit caller)
  #
  # This method returns [<results_object>, <error_string>]
  # Any errors in the eval are rescued and formatted to string. 
  #
  # If the command response indicates that it failed because the browser window
  # is closed, the browser will be restarted and the command gets retried.
  # TODO: prevent infinite loops in the case of persistent failure
  #
  def self.execute_command(cmd_string)
    begin
      cmd_result = with_dsl { eval cmd_string }
      ensure_chrome_is_reachable(cmd_result)
    rescue BrowserIsClosedError
      retry
    rescue Exception => e
      [nil, build_error_string(e)]
    end
  end

  # Execute a block of code in the context of the Driver capybara instance.
  # This is what lets Capybara methods be available at the top-level scope.
  # Note that this does **not** make these methods available to user-defined
  # constants such as classes/modules - 'delete_to_driver(self)' needs to be used
  # in that case
  #
  def self.with_dsl(&blk)
    Driver.instance_exec &blk
  end

  # Unused command to take a screenshot
  #
  def self.screenshot(page, path, open=false)
    fn = open ? :save_and_open_screenshot : :save_screenshot
    page.send(fn, path)
  end

  # Reads the command result and checks for an error indicating that
  # the browser window is closed.
  # If this condition is met, restart the browser.
  # Otherwise, return the original result.
  #
  def self.ensure_chrome_is_reachable(eval_result)
    if eval_result.is_a?(Hash) && is_disconnected?(eval_result['message'])
      const_set(:Driver, CapybaraDriver.new_driver)
      raise BrowserIsClosedError
    end
    [eval_result, nil]
  end

  # helper method to determine if the browser is closed
  def self.is_disconnected?(msg)
    ["chrome not reachable", "disconnected"].any? do |str|
      msg.include?(str)
    end
  end

end
