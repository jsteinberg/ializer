# frozen_string_literal: true

module Ser
  class Ializer
    @@method_registry = {} # rubocop:disable Style/ClassVars

    class << self
      # Public DSL
      def property(name, deser: nil, type: nil, model_class: nil, &block)
        return add_attribute(Field.new(name, deser, model_class, &block)) if deser

        return string(name, &block) unless type

        meth = lookup_method(type)

        return meth.call(name, &block) if meth

        string(name, &block)
      end

      def nested(name, deser: nil, model_class: nil, &block)
        if block
          deser = create_anon_class
          deser.class_eval(&block)
        end

        add_attribute(Field.new(name, deser, model_class))
      end

      def with(deser)
        deser._attributes.values.map(&:dup).each(&method(:add_attribute))
      end
      # End Public DSL

      def serialize(object)
        return serialize_one(object) unless valid_enumerable?(object)

        object.map { |o| serialize_one(o) }
      end

      def register(method_name, deser_class, *matchers)
        define_singleton_method(method_name) do |name, &block|
          add_attribute Field.new(name, deser_class, &block)
        end

        matchers.each do |matcher|
          method_registry[matcher.to_s.to_sym] = method_name
        end
      end

      protected

      def create_anon_class
        Class.new(Ser::Ializer)
      end

      def method_registry
        @@method_registry
      end

      def lookup_method(type)
        method_name = method_registry[type.to_s.to_sym]

        return nil unless method_name

        method(method_name)
      end

      def _attributes
        @attributes ||=
          if equal? Ser::Ializer
            {}
          else
            superclass._attributes.dup
          end
      end

      private

      def add_attribute(field)
        _attributes[field.key] = field

        if field.block
          add_attribute_with_block(field)
        else
          add_attribute_with_method(field)
        end
      end

      def add_attribute_with_block(field)
        define_singleton_method field.name do |object|
          value = field.block.call(object)

          serialize_field(field, value)
        end
      end

      def add_attribute_with_method(field)
        define_singleton_method field.name do |object|
          value = object.public_send(field.name)

          serialize_field(field, value)
        end
      end

      def serialize_field(field, value)
        return nil if value.nil?

        return field.serialize(value) unless value.is_a? Enumerable

        value.map { |v| field.serialize(v) }
      end

      def serialize_one(object)
        _attributes.values.each_with_object({}) do |field, data|
          value = public_send(field.name, object)

          next if value.nil?

          data[field.key] = value
        end
      end

      def valid_enumerable?(object)
        return true if object.is_a? Array

        return true if defined?(ActiveRecord) && object.is_a?(ActiveRecord::Relation)

        false
      end
    end
  end
end
