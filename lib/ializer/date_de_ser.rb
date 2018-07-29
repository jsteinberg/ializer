# frozen_string_literal: true

require 'date'

module Ializer
  class DateDeSer
    def self.serialize(value)
      value.to_s
    end

    def self.parse(value)
      Date.parse(value)
    rescue ArgumentError
      nil
    end
  end
end

Ser::Ializer.register('date', Ializer::DateDeSer, Date, :date)
