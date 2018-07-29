# frozen_string_literal: true

module Ializer
  class FloatDeSer
    def self.serialize(value)
      return NAN_STRING if value.nan?

      return value.to_s if value.infinite?

      value
    end

    def self.parse(value)
      return Float::NAN if value == BigDecimalDeSer::NAN_STRING

      return -Float::INFINITY if value == BigDecimalDeSer::NEGATIVE_INFINITY_STRING

      return Float::INFINITY if value == BigDecimalDeSer::INFINITY_STRING

      value.to_f
    end
  end
end

Ser::Ializer.register('float', Ializer::FloatDeSer, Float, :float)
