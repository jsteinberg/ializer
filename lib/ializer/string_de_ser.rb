# frozen_string_literal: true

module Ializer
  class StringDeSer
    def self.serialize(value)
      value.to_s
    end

    def self.parse(value)
      value.to_s
    end
  end
end

Ser::Ializer.register('string', Ializer::StringDeSer, String, :string)
