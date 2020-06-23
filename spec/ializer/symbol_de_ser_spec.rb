# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Ializer::SymbolDeSer do
  describe '#serialize' do
    it 'serializes values to symbol' do
      expect(described_class.serialize(:symbol)).to eq 'symbol'
    end
  end

  describe '#parse' do
    it 'parses values to symbol' do
      expect(described_class.parse('symbol')).to eq :symbol
      expect(described_class.parse(nil)).to eq nil

      # parse failures
      expect(described_class.parse(4)).to eq 4
    end
  end
end
