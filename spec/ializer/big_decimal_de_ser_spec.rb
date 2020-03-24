# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Ializer::BigDecimalDeSer do
  describe '#serialize' do
    it 'serializes values to string' do
      expect(described_class.serialize(BigDecimal('3.1415926'))).to eq '3.1415926'
      expect(described_class.serialize(3.1415926)).to eq '3.1415926'
      expect(described_class.serialize(3)).to eq '3.0'
      expect(described_class.serialize(BigDecimal::NAN)).to eq 'NaN'
      expect(described_class.serialize(BigDecimal::INFINITY)).to eq 'Infinity'
      expect(described_class.serialize(-BigDecimal::INFINITY)).to eq '-Infinity'
    end
  end

  describe '#parse' do
    it 'parses values to BigdDecimal' do
      expect(described_class.parse('3.1415926')).to eq BigDecimal('3.1415926')
      expect(described_class.parse('NaN').to_s).to eql BigDecimal::NAN.to_s
      expect(described_class.parse('Infinity')).to eq BigDecimal::INFINITY
      expect(described_class.parse('-Infinity')).to eq(-BigDecimal::INFINITY)
    end
  end
end
