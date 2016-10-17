module DriverHelpers
  
  # in user scripts, these methods are callable at global scope
  module InstanceMethods
    def module_require(name)
      load "./export/#{name}.rb"
    end
  end

  # these are added as class methods to Driver
  module ClassMethods
    
    # Make the driver instance methods available to another class.
    # Adds method_missing to the klass' instance and class scope.
    # This method is called by delegate_to_driver(klass) at the global scope
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

end