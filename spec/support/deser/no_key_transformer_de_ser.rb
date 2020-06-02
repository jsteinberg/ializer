# frozen_string_literal: true

class NoKeyTransformerDeSer < De::Ser::Ializer
  setup do |config|
    config.key_transform = nil
  end

  string :string_prop
  symbol :symbol_prop
end
