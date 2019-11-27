# frozen_string_literal: true

class OverrideProperyDeSer < De::Ser::Ializer
  string      :string_prop
  symbol      :symbol_prop
  integer     :integer_prop

  def self.string_prop(object, _context)
    "#{object.string_prop}_override"
  end

  def self.integer_prop(_object, _context)
    106
  end
end
