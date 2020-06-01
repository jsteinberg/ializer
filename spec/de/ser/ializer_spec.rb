# frozen_string_literal: true

require 'spec_helper'

RSpec.describe De::Ser::Ializer do
  let(:order) { TestOrder.init }

  describe 'NamedMethodDeSer' do
    it 'parses properties correctly' do
      data = NamedMethodDeSer.serialize(order)

      parsed = NamedMethodDeSer.parse(data, TestOrder)

      expect(parsed.string_prop).to    eq order.string_prop
      expect(parsed.symbol_prop).to    eq order.symbol_prop
      expect(parsed.integer_prop).to   eq order.integer_prop
      expect(parsed.decimal_prop).to   eq order.decimal_prop
      expect(parsed.bool_prop).to      eq order.bool_prop
      expect(parsed.date_prop).to      eq order.date_prop
      expect(parsed.float_prop).to     eq order.float_prop
      expect((parsed.timestamp_prop.to_f - order.timestamp_prop.to_f).abs).to be < 1
      expect((parsed.millis_prop.to_f - order.millis_prop.to_f).abs).to be < 1
    end

    it 'parses nested object' do
      order.add_customer
      data = NamedMethodDeSer.serialize(order)

      parsed = NamedMethodDeSer.parse(data, TestOrder)

      expect(parsed.customer).to be_present
      expect(parsed.customer).to be_a OpenStruct

      expect(parsed.customer.name).to eq order.customer.name
      expect(parsed.customer.tele).to eq order.customer.tele
    end

    it 'parses nested array objects' do
      order.add_item.add_item
      data = NamedMethodDeSer.serialize(order)

      parsed = NamedMethodDeSer.parse(data, TestOrder)

      expect(parsed.items.length).to eq 2
      expect(parsed.items.first).to be_a TestOrderItem
      expect(parsed.items.first.name).to eq order.items[0].name
      expect(parsed.items.first.quantity).to eq order.items[0].quantity
    end

    it 'parses json file correctly' do
      json = JSON.parse(File.read('./spec/fixtures/test_order.json'))

      parsed = NamedMethodDeSer.parse(json, TestOrder)

      expect(parsed.string_prop).to    eq 'string'
      expect(parsed.symbol_prop).to    eq :symbol
      expect(parsed.integer_prop).to   eq 94
      expect(parsed.decimal_prop).to   eq '3.141592654'.to_d
      expect(parsed.bool_prop).to      eq true
      expect(parsed.date_prop).to      eq Date.parse('2020-06-01')
      expect(parsed.float_prop).to     eq 3.14
      expect(parsed.timestamp_prop).to eq Time.parse('2020-06-01T14:53:31.445-05:00')
    end

    it 'parses json nulls and ignores them' do
      json = JSON.parse(File.read('./spec/fixtures/test_order_null_fields.json'))

      parsed = NamedMethodDeSer.parse(json, TestOrder)

      expect(parsed.string_prop).to    eq nil
      expect(parsed.symbol_prop).to    eq nil
      expect(parsed.integer_prop).to   eq nil
      expect(parsed.decimal_prop).to   eq nil
      expect(parsed.bool_prop).to      eq nil
      expect(parsed.date_prop).to      eq nil
      expect(parsed.float_prop).to     eq nil
      expect(parsed.timestamp_prop).to eq nil
      expect(parsed.millis_prop).to eq nil
    end
  end

  describe 'PropertyDeSer' do
    it 'parses properties correctly' do
      data = PropertyDeSer.serialize(order)

      parsed = PropertyDeSer.parse(data, TestOrder)

      expect(parsed.string_prop).to    eq order.string_prop
      expect(parsed.symbol_prop).to    eq order.symbol_prop
      expect(parsed.integer_prop).to   eq order.integer_prop
      expect(parsed.decimal_prop).to   eq order.decimal_prop
      expect(parsed.bool_prop).to      eq order.bool_prop
      expect(parsed.date_prop).to      eq order.date_prop
      expect(parsed.float_prop).to     eq order.float_prop
      expect((parsed.timestamp_prop.to_f - order.timestamp_prop.to_f).abs).to be < 1
      expect((parsed.millis_prop.to_f - order.millis_prop.to_f).abs).to be < 1
    end

    it 'parses conditional props' do
      data = PropertyDeSer.serialize(order, OpenStruct.new(admin?: true))

      parsed = PropertyDeSer.parse(data, TestOrder)
      expect(parsed.secret_prop).to eq order.secret_prop
    end

    it 'parses nested object' do
      order.add_customer
      data = PropertyDeSer.serialize(order)

      parsed = PropertyDeSer.parse(data, TestOrder)

      expect(parsed.customer).to be_present
      expect(parsed.customer).to be_a OpenStruct

      expect(parsed.customer.name).to eq order.customer.name
      expect(parsed.customer.tele).to eq order.customer.tele
    end

    it 'parses nested array objects' do
      order.add_item.add_item
      data = PropertyDeSer.serialize(order)

      parsed = PropertyDeSer.parse(data, TestOrder)

      expect(parsed.items.length).to eq 2
      expect(parsed.items.first).to be_a TestOrderItem
      expect(parsed.items.first.name).to eq order.items[0].name
      expect(parsed.items.first.quantity).to eq order.items[0].quantity
    end

    it 'parses custom field keys' do
      data = KeyChangePropertyDeSer.serialize(order)
      parsed = KeyChangePropertyDeSer.parse(data, TestOrder)

      expect(data.keys).to include('bool-enabled')
      expect(parsed.bool_prop).to eq order.bool_prop
    end

    it 'parses uses custom setter' do
      data = CustomeSetterPropertyDeSer.serialize(order)
      parsed = CustomeSetterPropertyDeSer.parse(data, TestOrder)

      expect(parsed.string_prop).to eq order.string_prop
    end
  end

  describe 'PropertySerializer' do
    it 'does not implement parse method' do
      expect(PropertySerializer).not_to respond_to(:parse)
    end
  end

  describe 'OverrideProperyDeSer' do
    it 'parses properties correctly' do
      data = OverrideProperyDeSer.serialize(order)

      parsed = OverrideProperyDeSer.parse(data, TestOrder)

      expect(parsed.string_prop).to     eq order.string_prop + '_override'
      expect(parsed.symbol_prop).to     eq order.symbol_prop
      expect(parsed.integer_prop).to    eq 106
    end
  end

  describe 'InheritanceDeSer' do
    it 'parses only base attributes' do
      data = BaseInheritanceDeSer.serialize(order)

      parsed = OverrideProperyDeSer.parse(data, TestOrder)

      expect(parsed.string_prop).to    eq order.string_prop
      expect(parsed.symbol_prop).to    eq order.symbol_prop
      expect(parsed.integer_prop).to   eq nil
    end

    it 'parses properties correctly' do
      data = InheritanceDeSer.serialize(order)

      parsed = OverrideProperyDeSer.parse(data, TestOrder)

      expect(parsed.string_prop).to    eq order.string_prop
      expect(parsed.symbol_prop).to    eq CustomSymbolDeSer.serialize(order.symbol_prop)
      expect(parsed.integer_prop).to   eq order.integer_prop
    end
  end

  describe 'CompositionDeSer' do
    it 'parses only base attributes' do
      data = BaseCompositionDeSer.serialize(order)

      parsed = BaseCompositionDeSer.parse(data, TestOrder)

      expect(parsed.string_prop).to    eq order.string_prop + '_override'
      expect(parsed.symbol_prop).to    eq((order.symbol_prop.to_s + '_override').to_sym)
      expect(parsed.integer_prop).to   eq nil
    end

    it 'parses properties correctly' do
      data = CompositionDeSer.serialize(order)

      parsed = CompositionDeSer.parse(data, TestOrder)

      expect(parsed.string_prop).to    eq order.string_prop + '_override2'
      expect(parsed.symbol_prop).to    eq((order.symbol_prop.to_s + '_override').to_sym)
      expect(parsed.integer_prop).to   eq order.integer_prop
    end

    describe 'parse_json' do
      it 'parses json correctly' do
        json = BaseCompositionDeSer.serialize_json(order)

        parsed = BaseCompositionDeSer.parse_json(json, TestOrder)
        expect(parsed.string_prop).to    eq order.string_prop + '_override'
        expect(parsed.symbol_prop).to    eq((order.symbol_prop.to_s + '_override').to_sym)
        expect(parsed.integer_prop).to   eq nil
      end
    end
  end

  describe 'BlockDeSer' do
    it 'parses properties correctly' do
      data = BlockDeSer.serialize(order)

      parsed = BlockDeSer.parse(data, TestOrder)

      expect(parsed.string_prop).to    eq order.string_prop + '_block'
      expect(parsed.integer_prop).to   eq order.integer_prop + 1
    end

    it 'parses nested object' do
      order.add_customer
      data = BlockDeSer.serialize(order)

      parsed = BlockDeSer.parse(data, TestOrder)

      expect(parsed.customer).to be_present
      expect(parsed.customer).to be_a OpenStruct

      expect(parsed.customer.name).to eq order.customer.name + '_block'
      expect(parsed.customer.tele).to eq order.customer.tele
    end

    it 'parses nested array objects' do
      order.add_item.add_item
      data = BlockDeSer.serialize(order)

      parsed = BlockDeSer.parse(data, TestOrder)

      expect(parsed.items.length).to eq 2
      expect(parsed.items.first).to be_a TestOrderItem
      expect(parsed.items.first.name).to eq order.items[0].name + '_block'
      expect(parsed.items.first.quantity).to eq order.items[0].quantity
    end
  end
end
