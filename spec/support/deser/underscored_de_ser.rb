# frozen_string_literal: true

class BaseUnderscoredDeSer < De::Ser::Ializer
  setup do |config|
    config.key_transform = :underscore
  end
end

class UnderscoredDeSer < BaseUnderscoredDeSer
  string :string_prop
  symbol :symbol_prop
end
