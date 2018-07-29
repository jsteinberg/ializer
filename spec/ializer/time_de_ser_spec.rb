# frozen_string_literal: true

require 'spec_helper'
require 'active_support'

RSpec.describe Ializer::TimeDeSer do
  let(:time) { Time.new(2018, 4, 4, 12, 30, 15, '+00:00') }
  let(:datetime) { DateTime.new(2018, 4, 4, 12, 30, 15, '+00:00') }
  let(:date_string) { '2018-04-04T12:30:15.000+00:00' }

  before do
    ActiveSupport.to_time_preserves_timezone = true
  end

  describe '#serialize' do
    it 'serializes values to isoo8601 string' do
      expect(described_class.serialize(time)).to eq date_string
    end

    it 'serializes DateTime same as Time' do
      expect(described_class.serialize(datetime)).to eq date_string
    end
  end

  describe '#parse' do
    it 'parses values to string' do
      Time.zone = 'UTC'

      expect(described_class.parse(date_string)).to eq time
    end
  end
end
