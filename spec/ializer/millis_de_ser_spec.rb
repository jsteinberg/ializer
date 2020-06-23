# frozen_string_literal: true

require 'spec_helper'
require 'active_support'

RSpec.describe Ializer::MillisDeSer do
  let(:time) { Time.new(2018, 4, 4, 12, 30, 15, '+00:00') }
  let(:datetime) { DateTime.new(2018, 4, 4, 12, 30, 15, '+00:00') }
  let(:millis) { 1_522_845_015_000 }

  before do
    ActiveSupport.to_time_preserves_timezone = true
  end

  describe '#serialize' do
    it 'serializes values to millis' do
      expect(described_class.serialize(time)).to eq millis
    end

    it 'serializes DateTime same as Time' do
      expect(described_class.serialize(datetime)).to eq millis
    end
  end

  describe '#parse' do
    it 'parses values to Time' do
      Time.zone = 'UTC'

      expect(described_class.parse(millis)).to eq time

      # parse failures
      expect(described_class.parse('asdf')).to eq 'asdf'
      expect(described_class.parse(nil)).to eq nil
    end
  end
end
