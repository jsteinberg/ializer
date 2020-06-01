# frozen_string_literal: true

require 'active_support/time'

module Ializer
  class TimeDeSer
    def self.serialize(value, _context = nil)
      value.to_time.iso8601(3) # to_time to force consistent serialization
    end

    def self.parse(value)
      DateTime.iso8601 value
    rescue ArgumentError
      nil
    end
  end
end

Ser::Ializer.register('timestamp', Ializer::TimeDeSer, Time, DateTime, :timestamp)
