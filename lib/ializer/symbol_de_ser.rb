# frozen_string_literal: true

module Ializer
  class SymbolDeSer
    def self.serialize(value, _context = nil)
      value.to_s
    end

    def self.parse(value)
      value.to_sym
    end
  end
end

Ser::Ializer.register('symbol', Ializer::SymbolDeSer, Symbol, :symbol, :sym)
