# frozen_string_literal: true

require 'date'

module Ializer
  class DateDeSer
    def self.serialize(value, _context = nil)
      value.to_s
    end

    def self.parse(value)
      Date.parse(value)
    rescue ArgumentError, TypeError
      value
    end
  end
end

Ser::Ializer.register('date', Ializer::DateDeSer, Date, :date)
