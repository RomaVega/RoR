require_relative 'manufacturer'
require_relative 'validation'

class Wagon
  attr_reader :type

  include Manufacturer
  include Validation

end
