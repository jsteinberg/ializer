# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Ializer::BooleanDeSer do
  describe '#serialize' do
    it 'serializes values to boolean' do
      expect(described_class.serialize(true)).to eq true
      expect(described_class.serialize(false)).to eq false
    end
  end

  describe '#parse' do
    it 'parses values to boolean' do
      expect(described_class.parse(true)).to eq true
      expect(described_class.parse(false)).to eq false
      expect(described_class.parse('true')).to eq true
      expect(described_class.parse('false')).to eq false
      expect(described_class.parse(1)).to eq false
      expect(described_class.parse('asdf')).to eq false
    end
  end
end
