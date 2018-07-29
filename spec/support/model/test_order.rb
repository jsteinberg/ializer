# frozen_string_literal: true

LETTERS = ('a'..'z').to_a
NUMBERS = ('0'..'9').to_a

TestOrder = Struct.new(
  :string_prop,
  :symbol_prop,
  :integer_prop,
  :decimal_prop,
  :bool_prop,
  :date_prop,
  :timestamp_prop,
  :millis_prop,
  :float_prop,
  :customer,
  :items,
  keyword_init: true
) do
  def self.init # rubocop:disable Metrics/MethodLength
    timestamp = Time.now
    TestOrder.new \
      string_prop: 'string',
      symbol_prop: :symbol,
      integer_prop: rand(0..100),
      decimal_prop: BigDecimal('3.141592654'),
      bool_prop: [true, false].sample,
      date_prop: Date.today,
      timestamp_prop: timestamp,
      millis_prop: timestamp,
      float_prop: 3.14
  end

  def add_item
    self.items ||= []
    self.items << TestOrderItem.init
    self
  end

  def add_customer
    self.customer = OpenStruct.new(name: LETTERS.sample(10).join, tele: NUMBERS.sample(10).join)
  end
end

TestOrderItem = Struct.new(:name, :quantity, keyword_init: true) do
  def self.init
    TestOrderItem.new \
      name: LETTERS.sample(8).join,
      quantity: rand(0..10)
  end
end
