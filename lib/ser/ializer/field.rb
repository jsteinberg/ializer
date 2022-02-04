# frozen_string_literal: true

module Ser
  class Ializer
    class Field
      class << self
        def transform(key, key_transformer)
          return key unless key_transformer

          key_transformer.call(key)
        end
      end

      attr_reader :name, :setter, :key, :deser, :model_class, :if_condition, :block, :description

      def initialize(name, options, config, &block)
        @name = name
        @setter = options[:setter] || "#{name}="
        @key = options[:key] || Field.transform(name.to_s, config.key_transformer)
        @deser = options[:deser]
        @if_condition = options[:if]
        @model_class = options[:model_class]
        @description = options[:desc]
        @block = block
      end

      def get_value(object, context)
        return object.public_send(name) unless block

        block.call(object, context)
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
