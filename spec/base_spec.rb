describe "Accessing the browser" do

  before(:each) do
    @server = MainServer
    @browser = @server::Browser
    @driver = @browser::Driver
  end
  it "has a driver object with capybara methods" do
    expect(@driver.class).to eq(Capybara::Selenium::Driver)
  end
  it "can drop into capybara dsl" do
    expect(@browser.with_dsl { method(:visit) }).to be_a Method
  end
  it "can visit a web page" do
    expect(@driver.respond_to?(:visit)).to be true
  end
  it "can take a screenshot" do
    expect(@browser.respond_to?(:screenshot)).to be true
  end
end

describe "Server routes" do
  # note that the server needs to be running for these tests to pass

end