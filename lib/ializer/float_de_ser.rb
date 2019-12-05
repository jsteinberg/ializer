# frozen_string_literal: true

module Ializer
  class FloatDeSer
    NAN_STRING = Float::NAN.to_s
    INFINITY_STRING = Float::INFINITY.to_s
    NEGATIVE_INFINITY_STRING = (-Float::INFINITY).to_s

    def self.serialize(value, _context = nil)
      value = value.to_f unless value.is_a? Float

      return NAN_STRING if value.nan?

      return value.to_s if value.infinite?

      value
    end

    def self.parse(value)
      return Float::NAN if value == NAN_STRING

      return -Float::INFINITY if value == NEGATIVE_INFINITY_STRING

      return Float::INFINITY if value == INFINITY_STRING

      value.to_f
    end
  end
end

Ser::Ializer.register('float', Ializer::FloatDeSer, Float, :float)
