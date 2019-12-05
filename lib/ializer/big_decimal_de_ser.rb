# frozen_string_literal: true

require 'bigdecimal'

module Ializer
  class BigDecimalDeSer
    def self.serialize(value, _context = nil)
      value.to_s('F')
    end

    def self.parse(value)
      BigDecimal(value)
    end
  end
end

Ser::Ializer.register('decimal', Ializer::BigDecimalDeSer, :BigDecimal, :decimal)
