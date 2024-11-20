require_relative 'wagon'
require_relative 'validation'
require_relative 'text_formatter'
class PassengerWagon < Wagon

  include Validation
  include TextFormatter

  def initialize
    @type = 'passenger'
    super
  end
end