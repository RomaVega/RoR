# frozen_string_literal: true
module Accessors
  def attr_accessor_with_history(*names)
    names.each do |name|
      # Имя переменной и история значений
      var_name = "@#{name}".to_sym
      history_name = "@#{name}_history".to_sym

      # Геттер для переменной
      define_method(name) { instance_variable_get(var_name) }

      # Сеттер для переменной с сохранением истории
      define_method("#{name}=".to_sym) do |value|
        history = instance_variable_get(history_name) || []
        current_value = instance_variable_get(var_name)
        history << current_value unless current_value.nil? # Добавляем текущее значение в историю
        instance_variable_set(history_name, history)
        instance_variable_set(var_name, value)
      end

      # Метод для возврата истории
      define_method("#{name}_history".to_sym) do
        instance_variable_get(history_name) || []
      end
    end
  end

  def strong_attr_accessor(name, klass)
    var_name = "@#{name}".to_sym

    # Геттер
    define_method(name) { instance_variable_get(var_name) }

    # Сеттер с проверкой типа
    define_method("#{name}=".to_sym) do |value|
      unless value.is_a?(klass)
        raise TypeError, "Invalid type: Expected #{klass}, got #{value.class}"
      end
      instance_variable_set(var_name, value)
    end
  end
end
