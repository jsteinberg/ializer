# frozen_string_literal: true

class BaseInheritanceDeSer < De::Ser::Ializer
  string      :string_prop
  symbol      :symbol_prop
end

class CustomSymbolDeSer
  def self.serialize(value, _context = nil)
    "#{value}_custom".to_sym
  end

  def self.parse(value)
    value.to_sym
  end
end

class InheritanceDeSer < BaseInheritanceDeSer
  property    :symbol_prop, deser: CustomSymbolDeSer
  integer     :integer_prop
end
