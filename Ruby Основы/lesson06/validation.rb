module Validation
  def self.included(base)
    base.extend ClassMethods
    base.include InstanceMethods
  end

  module ClassMethods
    def validate(attribute, validation_type, *args)
      @validations ||= []
      @validations << { attribute: attribute, type: validation_type, options: args }
    end

    def validations
      @validations || []
    end
  end

  module InstanceMethods
    def validate!
      self.class.validations.each do |validation|
        attribute = validation[:attribute]
        value = instance_variable_get("@#{attribute}")
        type = validation[:type]
        options = validation[:options]

        send("validate_#{type}", value, *options)
      end
      true
    end

    def valid?
      validate!
    rescue StandardError
      false
    end

    private

    def validate_presence(value)
      raise "Value cannot be nil or empty!" if value.nil? || value.strip.empty?
    end

    def validate_format(value, format)
      raise "Value does not match format #{format}!" unless value =~ format
    end

    def validate_type(value, klass)
      raise "Value must be of type #{klass}!" unless value.is_a?(klass)
    end
  end
end