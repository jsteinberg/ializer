# frozen_string_literal: true

class BlockDeSer < De::Ser::Ializer
  string :string_prop do |object|
    object.string_prop + '_block'
  end
  integer :integer_prop do |object|
    object.integer_prop + 1
  end

  nested :customer, model_class: OpenStruct do
    string :name do |object|
      object.name + '_block'
    end
    string :tele
  end

  nested :items, model_class: TestOrderItem do
    string :name do |object|
      object.name + '_block'
    end
    integer :quantity
  end
end
