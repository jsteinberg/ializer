# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Ializer::FixNumDeSer do
  describe '#serialize' do
    it 'serializes values to string' do
      expect(described_class.serialize(4)).to eq 4
    end
  end

  describe '#parse' do
    it 'parses values to string' do
      expect(described_class.parse('4')).to eq 4
      expect(described_class.parse(4)).to eq 4
    end
  end
end
