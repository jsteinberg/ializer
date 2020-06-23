# frozen_string_literal: true

module Ializer
  class SymbolDeSer
    def self.serialize(value, _context = nil)
      value.to_s
    end

    def self.parse(value)
      return nil if value.nil?

      value.to_sym
    rescue NoMethodError
      value
    end
  end
end

Ser::Ializer.register('symbol', Ializer::SymbolDeSer, Symbol, :symbol, :sym)
