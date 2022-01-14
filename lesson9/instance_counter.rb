# frozen_string_literal: true

module InstanceCounter
  def self.included(base)
    base.extend ClassMethods
    base.include InstanceMethods
  end

  module ClassMethods
    def instances
      @instances ||= 0
    end

    def add_instance
      @instances = instances + 1
    end
  end

  module InstanceMethods
    private

    def register_instance
      self.class.add_instance
    end
  end
end
