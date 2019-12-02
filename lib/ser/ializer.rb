# frozen_string_literal: true

module Ser
  class Ializer # rubocop:disable Metrics/ClassLength
    @@method_registry = {} # rubocop:disable Style/ClassVars

    class << self
      # Public DSL
      def property(name, options = {}, &block)
        return add_attribute(Field.new(name, options, &block)) if options[:deser]

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

        add_attribute(Field.new(name, options))
      end

      def with(deser)
        deser._attributes.values.map(&:dup).each(&method(:add_attribute))
      end
      # End Public DSL

      def serialize(object, context = nil)
        return serialize_one(object, context) unless valid_enumerable?(object)

        object.map { |o| serialize_one(o, context) }
      end

      def register(method_name, deser, *matchers)
        raise ArgumentError, 'register should only be called on the Ser::Ializer class' unless self == Ser::Ializer

        define_singleton_method(method_name) do |name, options = {}, &block|
          options[:deser] = deser
          add_attribute Field.new(name, options, &block)
        end

        matchers.each do |matcher|
          method_registry[matcher.to_s.to_sym] = method_name
        end
      end

      def register_default(deser)
        define_singleton_method('default') do |name, options = {}, &block|
          raise ArgumentError, warning_message(name) if ::Ializer.config.raise_on_default?

          puts warning_message(name) if ::Ializer.config.warn_on_default?

          options[:deser] = deser
          add_attribute Field.new(name, options, &block)
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
            {}
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

        if field.block
          add_attribute_with_block(field)
        else
          add_attribute_with_method(field)
        end
      end

      def add_attribute_with_block(field)
        define_singleton_method field.name do |object, context|
          value = field.block.call(object, context)

          serialize_field(field, value, context)
        end
      end

      def add_attribute_with_method(field)
        define_singleton_method field.name do |object, context|
          value = object.public_send(field.name)

          serialize_field(field, value, context)
        end
      end

      def serialize_field(field, value, context)
        return nil if value.nil?

        return field.serialize(value, context) unless valid_enumerable?(value)

        value.map { |v| field.serialize(v, context) }
      end

      def serialize_one(object, context)
        _attributes.values.each_with_object({}) do |field, data|
          next unless field.valid_for_context?(object, context)

          value = public_send(field.name, object, context)

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
