# frozen_string_literal: true

require 'ostruct'

class NamedMethodDeSer < De::Ser::Ializer
  string      :string_prop
  symbol      :symbol_prop
  integer     :integer_prop
  decimal     :decimal_prop
  boolean     :bool_prop
  date        :date_prop
  timestamp   :timestamp_prop
  millis      :millis_prop
  float       :float_prop

  nested      :customer,
              deser: CustomerDeSer,
              model_class: OpenStruct,
              documentation: { type: 'Customer' }
  nested      :items, deser: ItemDeSer, model_class: TestOrderItem
end
