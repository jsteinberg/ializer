# frozen_string_literal: true

class PropertyDeSer < De::Ser::Ializer
  property    :string_prop,     type: :type_that_doest_exist_but_will_evaluate_to_string
  property    :symbol_prop,     type: Symbol
  property    :integer_prop,    type: Integer
  property    :decimal_prop,    type: BigDecimal
  property    :bool_prop,       type: :boolean
  property    :date_prop,       type: Date
  property    :timestamp_prop,  type: Time
  property    :millis_prop,     type: :millis
  property    :float_prop,      type: Float
  property    :secret_prop,     type: String, if: ->(object, context) { PropertyDeSer.admin?(object, context) }
  property    :array_prop,      type: :array
  property    :json_prop,       type: :json

  nested      :customer,        deser: CustomerDeSer,   model_class: OpenStruct
  property    :items,           deser: ItemDeSer,       model_class: TestOrderItem

  def self.admin?(_object, context)
    return false if context.nil?

    context.admin?
  end
end

class KeyChangePropertyDeSer < PropertyDeSer
  property :bool_prop, type: :boolean, key: 'bool-enabled'
end

class CustomeSetterPropertyDeSer < PropertyDeSer
  property :string_prop, setter: :setter_string_prop
end

class OverriddenSetterPropertyDeSer < PropertyDeSer
  def self.decimal_prop=(object, value)
    object.decimal_prop = value * 2
  end
end
