# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Ser::Ializer do
  let(:order) { TestOrder.init }

  describe 'NamedMethodDeSer' do
    it 'serializes properties correctly' do
      data = NamedMethodDeSer.serialize(order)

      expect(data['string-prop']).to    eq Ializer::StringDeSer.serialize(order.string_prop)
      expect(data['symbol-prop']).to    eq Ializer::SymbolDeSer.serialize(order.symbol_prop)
      expect(data['integer-prop']).to   eq Ializer::FixNumDeSer.serialize(order.integer_prop)
      expect(data['decimal-prop']).to   eq Ializer::BigDecimalDeSer.serialize(order.decimal_prop)
      expect(data['bool-prop']).to      eq Ializer::BooleanDeSer.serialize(order.bool_prop)
      expect(data['date-prop']).to      eq Ializer::DateDeSer.serialize(order.date_prop)
      expect(data['timestamp-prop']).to eq Ializer::TimeDeSer.serialize(order.timestamp_prop)
      expect(data['millis-prop']).to    eq Ializer::MillisDeSer.serialize(order.millis_prop)
      expect(data['float-prop']).to     eq Ializer::FloatDeSer.serialize(order.float_prop)
    end

    it 'serializes an array of attributes from hash context correctly' do
      data = NamedMethodDeSer.serialize(order, attributes: %i[string-prop symbol-prop])

      expect(data.length).to eq 2
      expect(data['string-prop']).to    eq Ializer::StringDeSer.serialize(order.string_prop)
      expect(data['symbol-prop']).to    eq Ializer::SymbolDeSer.serialize(order.symbol_prop)

      data = NamedMethodDeSer.serialize(order, 'attributes' => %w[string-prop symbol-prop])
      expect(data.length).to eq 2

      data = NamedMethodDeSer.serialize(order, include: %w[string-prop symbol-prop])
      expect(data.length).to eq 2

      data = NamedMethodDeSer.serialize(order, 'include' => %i[string-prop symbol-prop])
      expect(data.length).to eq 2
    end

    it 'serializes an array of attributes from context correctly' do
      context = OpenStruct.new(attributes: %w[string-prop symbol-prop])

      data = NamedMethodDeSer.serialize(order, context)

      expect(data.length).to eq 2
      expect(data['string-prop']).to    eq Ializer::StringDeSer.serialize(order.string_prop)
      expect(data['symbol-prop']).to    eq Ializer::SymbolDeSer.serialize(order.symbol_prop)
    end

    it 'serializes as a collection' do
      data = NamedMethodDeSer.serialize([order])

      expect(data).to be_a Array
      expect(data.length).to eq 1

      obj_data = data[0]

      expect(obj_data['string-prop']).to    eq Ializer::StringDeSer.serialize(order.string_prop)
      expect(obj_data['symbol-prop']).to    eq Ializer::SymbolDeSer.serialize(order.symbol_prop)
      expect(obj_data['integer-prop']).to   eq Ializer::FixNumDeSer.serialize(order.integer_prop)
    end

    it 'serializes as a collection for attributes from hash context correctly' do
      data = NamedMethodDeSer.serialize([order], attributes: %w[string-prop symbol-prop])

      expect(data).to be_a Array
      expect(data.length).to eq 1

      obj_data = data[0]

      expect(obj_data.length).to eq 2
      expect(obj_data['string-prop']).to    eq Ializer::StringDeSer.serialize(order.string_prop)
      expect(obj_data['symbol-prop']).to    eq Ializer::SymbolDeSer.serialize(order.symbol_prop)
    end

    it 'returns [] for empty collection' do
      data = NamedMethodDeSer.serialize([])

      expect(data).to eq []
    end

    it 'serializes nested object' do
      order.add_customer

      data = NamedMethodDeSer.serialize(order)

      expect(data['customer']).to be_present
      expect(data['customer']['name']).to eq Ializer::StringDeSer.serialize(order.customer.name)
      expect(data['customer']['tele']).to eq Ializer::StringDeSer.serialize(order.customer.tele)
    end

    it 'serializes nested array objects' do
      order.add_item.add_item

      data = NamedMethodDeSer.serialize(order)

      expect(data['items'].length).to eq 2
      expect(data['items'][0]['name']).to eq Ializer::StringDeSer.serialize(order.items[0].name)
      expect(data['items'][0]['quantity']).to eq Ializer::FixNumDeSer.serialize(order.items[0].quantity)
    end
  end

  describe 'PropertyDeSer' do
    it 'serializes properties correctly' do
      data = PropertyDeSer.serialize(order)

      expect(data['string-prop']).to    eq Ializer::StringDeSer.serialize(order.string_prop)
      expect(data['symbol-prop']).to    eq Ializer::SymbolDeSer.serialize(order.symbol_prop)
      expect(data['integer-prop']).to   eq Ializer::FixNumDeSer.serialize(order.integer_prop)
      expect(data['decimal-prop']).to   eq Ializer::BigDecimalDeSer.serialize(order.decimal_prop)
      expect(data['bool-prop']).to      eq Ializer::BooleanDeSer.serialize(order.bool_prop)
      expect(data['date-prop']).to      eq Ializer::DateDeSer.serialize(order.date_prop)
      expect(data['timestamp-prop']).to eq Ializer::TimeDeSer.serialize(order.timestamp_prop)
      expect(data['millis-prop']).to    eq Ializer::MillisDeSer.serialize(order.millis_prop)
      expect(data['float-prop']).to     eq Ializer::FloatDeSer.serialize(order.float_prop)
      expect(data['array-prop']).to     eq order.array_prop
      expect(data['json-prop']).to      eq order.json_prop
    end

    it 'does not serialize admin props with no context' do
      data = PropertyDeSer.serialize(order)

      expect(data['secret-prop']).not_to be_present
    end

    it 'does not serialize admin props with if context.admin? false' do
      data = PropertyDeSer.serialize(order, OpenStruct.new(admin?: false))

      expect(data['secret-prop']).not_to be_present
    end

    it 'does serialize admin props with if context.admin? true' do
      data = PropertyDeSer.serialize(order, OpenStruct.new(admin?: true))

      expect(data['secret-prop']).to eq 'secret'
    end

    it 'serializes nested object' do
      order.add_customer

      data = PropertyDeSer.serialize(order)

      expect(data['customer']).to be_present
      expect(data['customer']['name']).to eq Ializer::StringDeSer.serialize(order.customer.name)
      expect(data['customer']['tele']).to eq Ializer::StringDeSer.serialize(order.customer.tele)
    end

    it 'does not serialize empty nested array objects' do
      data = PropertyDeSer.serialize(order)

      expect(data['items']).to be_nil
    end

    it 'serializes nested array objects' do
      order.add_item.add_item

      data = PropertyDeSer.serialize(order)

      expect(data['items'].length).to eq 2
      expect(data['items'][0]['name']).to eq Ializer::StringDeSer.serialize(order.items[0].name)
      expect(data['items'][0]['quantity']).to eq Ializer::FixNumDeSer.serialize(order.items[0].quantity)
    end

    it 'serializes custom field keys' do
      data = KeyChangePropertyDeSer.serialize(order)

      expect(data['bool-enabled']).to eq Ializer::BooleanDeSer.serialize(order.bool_prop)
    end
  end

  describe 'PropertySerializer' do
    it 'serializes properties correctly' do
      data = PropertySerializer.serialize(order)

      expect(data['string-prop']).to    eq Ializer::StringDeSer.serialize(order.string_prop)
      expect(data['symbol-prop']).to    eq Ializer::SymbolDeSer.serialize(order.symbol_prop)
    end

    it 'does not serialize admin props with no context' do
      data = PropertySerializer.serialize(order)

      expect(data['secret-prop']).not_to be_present
    end

    it 'does serialize admin props with if context.admin? true' do
      data = PropertySerializer.serialize(order, OpenStruct.new(admin?: true))

      expect(data['secret-prop']).to eq 'secret'
    end

    it 'serializes nested object with anonymous serializer' do
      order.add_customer

      data = PropertySerializer.serialize(order)

      expect(data['customer']).to be_present
      expect(data['customer']['name']).to eq Ializer::StringDeSer.serialize(order.customer.name)
      expect(data['customer']['tele']).to eq Ializer::StringDeSer.serialize(order.customer.tele)
    end

    describe 'attribute_names' do
      it 'contains all fields' do
        attribute_names = PropertySerializer.attribute_names

        expect(attribute_names).to include(:string_prop)
        expect(attribute_names).to include(:symbol_prop)
        expect(attribute_names).to include(:secret_prop)
        expect(attribute_names).to include(:customer)
      end
    end
  end

  describe 'UnderscoredDeSer' do
    it 'serializes properties correctly with underscores' do
      data = UnderscoredDeSer.serialize(order)

      expect(data['string_prop']).to    eq Ializer::StringDeSer.serialize(order.string_prop)
      expect(data['symbol_prop']).to    eq Ializer::SymbolDeSer.serialize(order.symbol_prop)
    end
  end

  describe 'NoKeyTransformerDeSer' do
    it 'serializes properties correctly with underscores' do
      data = NoKeyTransformerDeSer.serialize(order)

      expect(data['string_prop']).to    eq Ializer::StringDeSer.serialize(order.string_prop)
      expect(data['symbol_prop']).to    eq Ializer::SymbolDeSer.serialize(order.symbol_prop)
    end
  end

  describe 'OverrideProperyDeSer' do
    it 'serializes properties correctly' do
      data = OverrideProperyDeSer.serialize(order)

      expect(data['string-prop']).to    eq "#{Ializer::StringDeSer.serialize(order.string_prop)}_override"
      expect(data['symbol-prop']).to    eq Ializer::SymbolDeSer.serialize(order.symbol_prop)
      expect(data['integer-prop']).to   eq 106
    end
  end

  describe 'InheritanceDeSer' do
    it 'serializes only base attributes' do
      data = BaseInheritanceDeSer.serialize(order)

      expect(data['string-prop']).to    eq Ializer::StringDeSer.serialize(order.string_prop)
      expect(data['symbol-prop']).to    eq Ializer::SymbolDeSer.serialize(order.symbol_prop)
      expect(data).not_to have_key('integer-prop')
    end

    it 'serializes properties correctly' do
      data = InheritanceDeSer.serialize(order)

      expect(data['string-prop']).to    eq Ializer::StringDeSer.serialize(order.string_prop)
      expect(data['symbol-prop']).to    eq CustomSymbolDeSer.serialize(order.symbol_prop)
      expect(data['integer-prop']).to   eq Ializer::FixNumDeSer.serialize(order.integer_prop)
    end
  end

  describe 'CompositionDeSer' do
    it 'serializes only base attributes' do
      data = BaseCompositionDeSer.serialize(order)

      expect(data['string-prop']).to    eq Ializer::StringDeSer.serialize("#{order.string_prop}_override")
      expect(data['symbol-prop']).to    eq Ializer::SymbolDeSer.serialize("#{order.symbol_prop}_override")
      expect(data).not_to have_key('integer-prop')
    end

    it 'serializes properties correctly' do
      data = CompositionDeSer.serialize(order)

      expect(data['string-prop']).to    eq Ializer::StringDeSer.serialize("#{order.string_prop}_override2")
      expect(data['symbol-prop']).to    eq Ializer::SymbolDeSer.serialize("#{order.symbol_prop}_override")
      expect(data['integer-prop']).to   eq Ializer::FixNumDeSer.serialize(order.integer_prop)
    end

    describe 'serialize_json' do
      it 'serializes to json correctly' do
        json = BaseCompositionDeSer.serialize_json(order)

        expect(json).to eq '{"string-prop":"string_override","symbol-prop":"symbol_override"}'

        data = JSON.parse(json)
        expect(data['string-prop']).to    eq Ializer::StringDeSer.serialize("#{order.string_prop}_override")
        expect(data['symbol-prop']).to    eq Ializer::SymbolDeSer.serialize("#{order.symbol_prop}_override")
      end
    end
  end

  describe 'BlockDeSer' do
    it 'serializes properties correctly' do
      data = BlockDeSer.serialize(order)

      expect(data['string-prop']).to    eq "#{order.string_prop}_block"
      expect(data['integer-prop']).to   eq order.integer_prop + 1
    end

    it 'serializes nested object' do
      order.add_customer

      data = BlockDeSer.serialize(order)

      expect(data['customer']).to be_present
      expect(data['customer']['name']).to eq "#{order.customer.name}_block"
      expect(data['customer']['tele']).to eq Ializer::StringDeSer.serialize(order.customer.tele)
    end

    it 'serializes nested array objects' do
      order.add_item.add_item

      data = BlockDeSer.serialize(order)

      expect(data['items'].length).to eq 2
      expect(data['items'][0]['name']).to eq "#{order.items[0].name}_block"
      expect(data['items'][0]['quantity']).to eq Ializer::FixNumDeSer.serialize(order.items[0].quantity)
    end
  end

  describe 'DefaultDeSer' do
    it 'raises error if raise_on_default specified' do
      ::Ializer.config.raise_on_default = true

      expect do
        described_class.send(:create_anon_class).class_eval do
          property :uses_default
        end
      end.to raise_error(ArgumentError)

      ::Ializer.config.raise_on_default = false
    end
  end

  describe 'attributes' do
    it 'grants access to attributes' do
      attributes = ItemDeSer.attributes
      expect(attributes.count).to eq 2
      expect(attributes.keys).to eq %w[name quantity]
      expect(attributes['name'].deser).to eq Ializer::StringDeSer
      expect(attributes['quantity'].deser).to eq Ializer::FixNumDeSer
    end

    describe 'field description' do
      it 'parses the scription correctly' do
        attributes = ItemDeSer.attributes
        expect(attributes['name'].description).to eq 'Name of the item'
        expect(attributes['quantity'].description).to eq 'Quantity of the item'
      end
    end
  end

  describe 'deser_types' do
    it 'maps all registered desers to their respective type' do
      deser_types = described_class.deser_types
      expect(deser_types['Ializer::BigDecimalDeSer']).to eq 'Decimal'
      expect(deser_types['Ializer::BooleanDeSer']).to eq 'Boolean'
      expect(deser_types['Ializer::DateDeSer']).to eq 'Date'
      expect(deser_types['Ializer::DefaultDeSer']).to eq 'Json'
      expect(deser_types['Ializer::FixNumDeSer']).to eq 'Integer'
      expect(deser_types['Ializer::FloatDeSer']).to eq 'Float'
      expect(deser_types['Ializer::MillisDeSer']).to eq 'Millis'
      expect(deser_types['Ializer::StringDeSer']).to eq 'String'
      expect(deser_types['Ializer::SymbolDeSer']).to eq 'Symbol'
      expect(deser_types['Ializer::TimeDeSer']).to eq 'Timestamp'
    end
  end

  describe 'documentation' do
    it 'stores documentation options in field' do
      attributes = NamedMethodDeSer.attributes
      customer_field = attributes['customer']
      expect(customer_field.documentation).not_to be_nil
      expect(customer_field.documentation[:type]).to eq 'Customer'
    end
  end
end
