# frozen_string_literal: true

module Validation

  def valid?
    validate!
    true
  rescue StandardError
    false
  end

  def validate_not_empty(attribute, name)
    value = instance_variable_get("@#{attribute}")
    raise clr("#{name} cannot be empty!", 91) if value.nil? || value.strip.empty?
  end
end

def validate_length(attribute, name, length)
  value = instance_variable_get("@#{attribute}")
  raise "#{name} must be #{length} characters!" unless value.length == length
end

def validate_inclusion(attribute, name, list)
  value = instance_variable_get("@#{attribute}")
  raise "#{name} must be one of #{list.join(', ')}!" unless list.include?(value)
end

def validate_type(attribute, name, klass)
  value = instance_variable_get("@#{attribute}")
  raise "#{name} must be #{klass} type!" unless value.is_a?(klass)
end