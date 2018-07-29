# frozen_string_literal: true

module Ser
  class Ializer
    class Field
      attr_reader :name, :setter, :key, :deser, :model_class, :block

      def initialize(name, deser, model_class = nil, &block)
        @name = name
        @setter = "#{name}=" # TODO: configurable
        @key = name.to_s.dasherize # TODO: configurable
        @deser = deser
        @model_class = model_class
        @block = block
      end

      def serialize(value)
        deser.serialize(value)
      end

      def parse(value)
        if model_class
          deser.parse(value, model_class)
        else
          deser.parse(value)
        end
      end
    end
  end
end
