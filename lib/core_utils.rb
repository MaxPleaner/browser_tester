class Object
  def build_error_string(e)
    [e, e.message, e.backtrace]
    .map { |err| err.ai(html: true) }
    .join("<br>")
  end
  def delegate_to_driver(klass)
    Object::Driver ||= MainServer::Browser::Driver
    Driver.delegate(klass)
  end
end