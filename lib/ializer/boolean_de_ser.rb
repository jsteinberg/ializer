# frozen_string_literal: true

module Ializer
  class BooleanDeSer
    def self.serialize(value, _context = nil)
      value
    end

    def self.parse(value)
      return value if value.is_a? TrueClass
      return value if value.is_a? FalseClass

      value.to_s == 'true'
    end
  end
end

Ser::Ializer.register('boolean', Ializer::BooleanDeSer, :Boolean, :boolean)
