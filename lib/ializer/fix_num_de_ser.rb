# frozen_string_literal: true

module Ializer
  class FixNumDeSer
    def self.serialize(value, _context = nil)
      value
    end

    def self.parse(value)
      return value if value.is_a? Numeric

      value.to_i
    end
  end
end

Ser::Ializer.register('integer', Ializer::FixNumDeSer, Integer, :integer)
