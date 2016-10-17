module DriverHelpers
  def module_require(name)
    require "./export/#{name}"
  end
end