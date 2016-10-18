module DriverHelpers
  
  # In a user-defined command, this can be called at the top-level
  # but it can't be defined within the scope of user-defined constants.
  # It is functionally pretty simple.
  # i.e. module_require 'my_module'
  # TODO: find a way unload stuff
  #
  def module_require(name)
    load "./export/#{name}.rb"
  end

  # Make the driver instance methods available to another class.
  # Adds method_missing to the klass' instance and class scope.
  # This method is called by Object#delegate_to_driver(klass)
  # see core_utils.rb for more info
  #
  def delegate(klass)
    klass.class_exec do
      def method_missing(m, *args, &block)
        method = Driver.method(m)
        method ? method.call(*args, &block) : super
      end
      def self.method_missing(m, *args, &block)
        method = Driver.method(m)
        method ? method.call(*args, *block) : super
      end
    end
  end

end