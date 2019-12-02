# frozen_string_literal: true

::Ializer.config.key_transform = :underscore

class UnderscoredDeSer < De::Ser::Ializer
  string :string_prop
  symbol :symbol_prop
end

::Ializer.config.key_transform = :dasherize
