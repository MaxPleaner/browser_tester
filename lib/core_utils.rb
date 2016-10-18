class Object

  # takes an error and sends it through awesome_print
  # to get a styled html representation
  #
  def build_error_string(e)
    [e, e.message, e.backtrace]
    .map { |err| err.ai(html: true) }
    .join("<br>")
  end

  # capybara methods are globally accessible
  # i.e. MainServer::Browser::Driver.visit '<url>'
  # but this is too verbose for user scripts.
  #
  # Say I'm defining a class that I'm exporting as a module:
  #
  # class MyClass
  #   def initialize
  #     visit '<url>'
  #   end
  # end
  #
  # How could I make `visit` work this way (with an implicit caller)?
  # Furthermore, how could I make it work in both class and instance methods
  # as well as modules?
  #
  # Just put `delegate_to_driver(self)` right after the `class MyClass` line
  # It's like a combined 'include' and 'extend' that works using method_missing.
  #
  def delegate_to_driver(klass)
    MainServer::Browser::Driver.delegate(klass)
  end
end