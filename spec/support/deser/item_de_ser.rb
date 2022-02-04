# frozen_string_literal: true

class ItemDeSer < De::Ser::Ializer
  string      :name, desc: 'Name of the item'
  integer     :quantity, desc: 'Quantity of the item'
end
