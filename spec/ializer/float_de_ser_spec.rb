# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Ializer::FloatDeSer do
  describe '#serialize' do
    it 'serializes values to string' do
      expect(described_class.serialize(4.0)).to eq 4
      expect(described_class.serialize(4)).to eq 4
      expect(described_class.serialize('4')).to eq 4
    end

    it 'serializes nan to string' do
      expect(described_class.serialize(Float::NAN)).to eq 'NaN'
    end
  end

  describe '#parse' do
    it 'parses values to string' do
      expect(described_class.parse('4')).to eq 4
      expect(described_class.parse(4)).to eq 4
    end

    it 'parses NaN to Float::NAN' do
      expect(described_class.parse('NaN')).to be_nan
    end

    it 'parses Infinity correctly' do
      expect(described_class.parse('Infinity').infinite?).to eq 1
      expect(described_class.parse('-Infinity').infinite?).to eq(-1)
    end

    it 'returns nil if value nil' do
      expect(described_class.parse(nil)).to eq nil
    end
  end
end
