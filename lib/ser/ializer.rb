# frozen_string_literal: true

require 'active_support/hash_with_indifferent_access'
require 'active_support/core_ext/hash'

module Ser
  class Ializer # rubocop:disable Metrics/ClassLength
    @@method_registry = {} # rubocop:disable Style/ClassVars

    class << self
      def config
        @config ||=
          if equal? Ser::Ializer
            ::Ializer.config
          else
            superclass.config
          end
      end

      def setup
        @config = config.dup

        yield @config
      end

      # Public DSL
      def property(name, options = {}, &block)
        return add_attribute(Field.new(name, options, config, &block)) if options[:deser]

        return default(name, options, &block) unless options[:type]

        meth = lookup_method(options[:type])

        return meth.call(name, options, &block) if meth

        default(name, options, &block)
      end

      def nested(name, options = {}, &block)
        if block
          deser = create_anon_class
          deser.class_eval(&block)
          options[:deser] = deser
        end

        add_attribute(Field.new(name, options, config))
      end

      def with(deser)
        deser._attributes.values.each do |field|
          add_composed_attribute(field, deser)
        end
      end
      # End Public DSL

      def serialize(object, context = nil)
        return serialize_one(object, context) unless valid_enumerable?(object)

        return [] if object.empty?

        object.map { |o| serialize_one(o, context) }
      end

      def serialize_json(object, context = nil)
        MultiJson.dump(serialize(object, context))
      end

      def register(method_name, deser, *matchers)
        raise ArgumentError, 'register should only be called on the Ser::Ializer class' unless self == Ser::Ializer

        define_singleton_method(method_name) do |name, options = {}, &block|
          options[:deser] = deser
          add_attribute Field.new(name, options, config, &block)
        end

        matchers.each do |matcher|
          method_registry[matcher.to_s.to_sym] = method_name
        end
      end

      def register_default(deser)
        define_singleton_method('default') do |name, options = {}, &block|
          raise ArgumentError, warning_message(name) if config.raise_on_default?

          puts warning_message(name) if config.warn_on_default?

          options[:deser] = deser
          add_attribute Field.new(name, options, config, &block)
        end
      end

      def attribute_names
        _attributes.values.map(&:name)
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
            ActiveSupport::HashWithIndifferentAccess.new
          else
            superclass._attributes.dup
          end
      end

      private

      def warning_message(name)
        "Warning: #{self} using default DeSer for property #{name}"
      end

      def add_attribute(field)
        _attributes[field.key] = field

        define_singleton_method field.name do |object, context|
          value = field.get_value(object, context)

          serialize_field(field, value, context)
        end
      end

      def add_composed_attribute(field, deser)
        _attributes[field.key] = field

        define_singleton_method field.name do |object, context|
          deser.public_send(field.name, object, context)
        end
      end

      def serialize_field(field, value, context)
        return nil if value.nil?

        return field.serialize(value, context) unless valid_enumerable?(value)

        return nil if value.empty?

        value.map { |v| field.serialize(v, context) }
      end

      def serialize_one(object, context)
        fields_for_serialization(context).each_with_object({}) do |field, data|
          next unless field.valid_for_context?(object, context)

          value = public_send(field.name, object, context)

          next if value.nil?

          data[field.key] = value
        end
      end

      def fields_for_serialization(context)
        field_names = fields_names_for_serialization(context)

        return _attributes.values unless field_names

        _attributes.values_at(*field_names).compact
      end

      def fields_names_for_serialization(context)
        return nil unless context

        if context.is_a?(Hash)
          context = context.with_indifferent_access
          return context[:attributes] || context[:include]
        end

        return context.attributes if context.respond_to?(:attributes)

        nil
      end

      def valid_enumerable?(object)
        return true if object.is_a? Array

        return true if defined?(ActiveRecord) && object.is_a?(ActiveRecord::Relation)

        false
      end
    end
  end
end
