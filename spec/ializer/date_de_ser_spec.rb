# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Ializer::DateDeSer do
  describe '#serialize' do
    it 'serializes values to string' do
      expect(described_class.serialize(Date.new(2018, 4, 4))).to eq '2018-04-04'
    end
  end

  describe '#parse' do
    it 'parses values to date' do
      expect(described_class.parse('2018-04-04')).to eq Date.new(2018, 4, 4)

      # parse failures
      expect(described_class.parse('asdf')).to eq 'asdf'
      expect(described_class.parse(nil)).to eq nil
    end
  end
end
