# frozen_string_literal: true

class PropertySerializer < Ser::Ializer
  property    :string_prop,     type: :type_that_doest_exist_but_will_evaluate_to_string
  property    :symbol_prop,     type: Symbol
  property    :secret_prop,     type: String, if: PropertyDeSer.method(:admin?)

  nested      :customer,        model_class: OpenStruct do
    string :name
    string :tele
  end

  def self.secret_prop(_object, _context)
    'secret'
  end
end
