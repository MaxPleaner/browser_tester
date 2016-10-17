class Object
  def delegate_to_driver(klass)
    Object::Driver ||= MainServer::Browser::Driver
    Driver.delegate(klass)
  end
end