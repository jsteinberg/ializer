# frozen_string_literal: true

module De
  module Ser
    class Ializer < ::Ser::Ializer
      class << self
        def parse(data, model_class)
          return parse_many(data, model_class) if data.is_a? Array

          parse_one(data, model_class)
        end

        def parse_many(data, model_class)
          data.map { |obj_data| parse_one(obj_data, model_class) }
        end

        def parse_one(data, model_class)
          # OpenStruct lazily defines methods so respond_to? fails initially
          return parse_ostruct(data) if ostruct?(model_class)

          parse_object(data, model_class.new)
        end

        def parse_object(data, object)
          data.each do |key, value|
            parse_attribute(object, key, value)
          end

          object
        end

        def parse_json(json, model_class)
          data = MultiJson.load(json)
          parse(data, model_class)
        end

        def parse_attribute(object, key, value)
          field = _attributes[key]

          return unless field

          return unless object.respond_to?(field.setter)

          parse_field(object, field, value)
        end

        protected

        def create_anon_class
          Class.new(De::Ser::Ializer)
        end

        private

        def parse_field(object, field, value)
          parsed_value = field.parse(value)

          return if parsed_value.nil?

          object.public_send(field.setter, parsed_value)
        end

        def ostruct?(model_class)
          defined?(OpenStruct) && model_class <= OpenStruct
        end

        def parse_ostruct(data)
          object = OpenStruct.new

          data.each do |key, value|
            parse_ostruct_field(object, key, value)
          end

          object
        end

        def parse_ostruct_field(object, key, value)
          field = _attributes[key]

          return unless field

          parse_field(object, field, value)
        end
      end
    end
  end
end
