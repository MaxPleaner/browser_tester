class CapybaraDriver

  def self.new_driver
    configure
    register_driver
  end

  def self.configure
    Capybara.run_server = false
    Capybara.default_wait_time = 5
  end

  def self.register_driver
    Capybara.register_driver :chrome do |app|
      profile = Selenium::WebDriver::Chrome::Profile.new
      profile['download.prompt_for_download'] = false
      profile['download.default_directory'] = "~/Desktop"
      Capybara::Selenium::Driver.new( app,
        browser: :chrome,
        profile: profile,
      )
    end.call
  end

end