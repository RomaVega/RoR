# frozen_string_literal: true
require_relative 'text_formatter'
module Validation

  def valid?
    validate!
    true
  rescue StandardError
    false
  end

  def input_empty?(attribute, name)
    value = instance_variable_get("@#{attribute}")
    if value.nil? || value.empty?
      raise StandardError, "#{name} cannot be empty!"
    end
  end

  def name_length(attribute, name, length)
    value = instance_variable_get("@#{attribute}")
    raise "#{name} must be #{length} characters!" unless value.length == length
  end

  def validate_train_type(type)
    valid_types = %w[passenger cargo]
    raise "Invalid train type. Must be one of: #{valid_types.join(', ')}" if type.nil? || !valid_types.include?(type)
  end

  def validate_inclusion(attribute, name, list)
    value = instance_variable_get("@#{attribute}")
    raise "#{name} must be one of #{list.join(', ')}!" unless list.include?(value)
  end

  # Station validations:
  def validate_station_not_empty(attribute, name)
    value = instance_variable_get("@#{attribute}")
    raise red_clr("#{name} cannot be empty!").to_s if value.nil? || value.strip.empty?
  end

  def validate_station_length(attribute, name, min_length, max_length)
    value = instance_variable_get("@#{attribute}")
    length = value.length
    if length < min_length || length > max_length
      raise StandardError, "#{name} must be between #{min_length} and #{max_length} characters"
    end
  end

  def validate_station_name(attribute, name, length_min, length_max)
    value = instance_variable_get("@#{attribute}")
    if value.nil? || value.strip.empty?
      raise ArgumentError, red_clr("#{name} cannot be empty!")
    elsif value.length < length_min || value.length > length_max
      raise ArgumentError, red_clr("#{name} must be #{length_min}-#{length_max} characters")
    end
  end
  
  def validate_cargo_volume(value)
    if value < 1 || value > 100
      raise ArgumentError, 'Cargo volume must be between 1 and 100!'
    end
  end

  def validate_loading_input(amount)
    if amount <= 0
      raise ArgumentError, 'Loading amount must be greater than 0!'
    elsif amount > @volume_available
      raise ArgumentError, "Loading amount must be less than or equal to #{@volume_available}"
    end
  end

  def validate_passenger_volume(seats)
    unless [33, 55, 77].include?(seats)
      raise ArgumentError, 'Number of seats must be 33, 55 or 77!'
    end
  end

end
