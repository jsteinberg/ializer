# frozen_string_literal: true

class BaseCompositionDeSer < De::Ser::Ializer
  string      :string_prop
  symbol      :symbol_prop

  def self.string_prop(object, _context)
    "#{object.string_prop}_override"
  end

  def self.symbol_prop(object, _context)
    "#{object.symbol_prop}_override"
  end
end

class CompositionDeSer < BaseCompositionDeSer
  with        BaseCompositionDeSer
  integer     :integer_prop

  def self.string_prop(object, _context)
    "#{object.string_prop}_override2"
  end
end
