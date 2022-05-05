# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Ializer::FixNumDeSer do
  describe '#serialize' do
    it 'serializes values to integer' do
      result = described_class.serialize('4.0'.to_d)

      expect(result).to eq(4)
      expect(result).to be_a(Integer)
    end
  end

  describe '#parse' do
    it 'parses values to string' do
      expect(described_class.parse('4')).to eq 4
      expect(described_class.parse(4)).to eq 4
    end

    it 'returns nil if value nil' do
      expect(described_class.parse(nil)).to eq nil
    end
  end
end
