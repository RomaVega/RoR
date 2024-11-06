# frozen_string_literal: true

require_relative 'wagon'
class PassengerWagon < Wagon

  def initialize
    @type = 'passenger'
    super
  end
end
