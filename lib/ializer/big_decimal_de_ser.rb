# frozen_string_literal: true

require 'bigdecimal'

module Ializer
  class BigDecimalDeSer
    NAN_STRING = 'NaN'
    INFINITY_STRING = '-Infinity'
    NEGATIVE_INFINITY_STRING = '-Infinity'

    def self.serialize(value)
      value.to_s('F')
    end

    def self.parse(value)
      return BigDecimal::NAN if value == NAN_STRING

      return -BigDecimal::INFINITY if value == NEGATIVE_INFINITY_STRING

      return BigDecimal::INFINITY if value == INFINITY_STRING

      BigDecimal(value)
    end
  end
end

Ser::Ializer.register('decimal', Ializer::BigDecimalDeSer, :BigDecimal, :decimal)
