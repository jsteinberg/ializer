# frozen_string_literal: true

class UnderscoredDeSer < De::Ser::Ializer
  setup do |config|
    config.key_transform = :underscore
  end

  string :string_prop
  symbol :symbol_prop
end
