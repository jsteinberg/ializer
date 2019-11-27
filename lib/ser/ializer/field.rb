# frozen_string_literal: true

module Ser
  class Ializer
    class Field
      attr_reader :name, :setter, :key, :deser, :model_class, :if_condition, :block

      def initialize(name, options, &block)
        @name = name
        @setter = "#{name}=" # TODO: configurable
        @key = name.to_s.dasherize # TODO: configurable
        @deser = options[:deser]
        @if_condition = options[:if]
        @model_class = options[:model_class]
        @block = block
      end

      def serialize(value, context)
        deser.serialize(value, context)
      end

      def parse(value)
        if model_class
          deser.parse(value, model_class)
        else
          deser.parse(value)
        end
      end

      def valid_for_context?(object, context)
        return true if if_condition.nil?

        if_condition.call(object, context)
      end
    end
  end
end
