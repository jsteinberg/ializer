# frozen_string_literal: true

module Ializer
  class DefaultDeSer
    def self.serialize(value, _context = nil)
      value
    end

    def self.parse(value)
      value
    end
  end
end

Ser::Ializer.register_default(Ializer::DefaultDeSer)
