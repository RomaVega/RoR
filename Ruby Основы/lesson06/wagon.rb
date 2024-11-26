require_relative 'manufacturer'
require_relative 'validation'
require_relative 'text_formatter'
require_relative 'train'

class Wagon
  attr_reader :type

  include Manufacturer
  include Validation
  include TextFormatter

end
