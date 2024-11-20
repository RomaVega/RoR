require_relative 'manufacturer'
require_relative 'validation'
require_relative 'text_formatter'

class Wagon
  attr_reader :type

  include Manufacturer
  include Validation
  include TextFormatter

end
