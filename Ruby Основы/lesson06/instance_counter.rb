# frozen_string_literal: true

module InstanceCounter
  def self.included(base)
    base.extend ClassMethods
    base.send :include, InstanceMethods
  end

  module ClassMethods
    # Метод для получения количества экземпляров
    def instances
      @instances ||= 0
    end

    # Метод для увеличения счетчика экземпляров
    def increment_instances
      @instances += 1
    end
  end

  module InstanceMethods
    private

    # Метод для регистрации экземпляра, увеличивает счетчик
    def register_instance
      self.class.increment_instances
    end
  end
end
