# frozen_string_literal: true

require 'bigdecimal'

module Ializer
  class BigDecimalDeSer
    def self.serialize(value, _context = nil)
      value = value.to_d unless value.is_a? BigDecimal

      value.to_s('F')
    end

    def self.parse(value)
      return nil if value.nil?

      BigDecimal(value)
    rescue ArgumentError
      value
    end
  end
end

Ser::Ializer.register('decimal', Ializer::BigDecimalDeSer, :BigDecimal, :decimal)
