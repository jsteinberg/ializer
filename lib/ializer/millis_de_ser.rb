# frozen_string_literal: true

require 'time'

module Ializer
  class MillisDeSer
    def self.serialize(value, _context = nil)
      (value.to_f * 1000).to_i
    end

    def self.parse(value)
      return nil if value.nil?

      Time.at(value / 1000.0)
    end
  end
end

Ser::Ializer.register('millis', Ializer::MillisDeSer, :Millis, :millis)
