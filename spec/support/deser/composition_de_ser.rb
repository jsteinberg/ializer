# frozen_string_literal: true

class BaseCompositionDeSer < De::Ser::Ializer
  string      :string_prop
  symbol      :symbol_prop
end

class CompositionDeSer < BaseCompositionDeSer
  with        BaseCompositionDeSer
  integer     :integer_prop
end
