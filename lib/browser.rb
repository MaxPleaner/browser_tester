require_relative './capybara_driver.rb'

class MainServer::Browser

  Driver = CapybaraDriver.new_driver

  # returns [results or nil, err_string or nil]
  def self.execute_command(cmd_string)
    begin
      cmd_result = with_dsl { eval cmd_string }
      ensure_chrome_is_reachable(cmd_result)
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
      return [nil, "browser window was closed - restarted. Try again."]
    end
    [eval_result, nil]
  end

  def self.is_disconnected?(msg)
    ["chrome not reachable", "disconnected"].any? do |str|
      msg.include?(str)
    end
  end

end
