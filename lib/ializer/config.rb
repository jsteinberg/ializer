# frozen_string_literal: true

module Ializer
  class Config
    def initialize
      self.key_transform = :dasherize
    end

    ##
    # :key_transform=: key_transform
    #
    # symbol of string transform to call on field keys
    # default is +:dasherize+.
    def key_transform=(key_transform)
      self.key_transformer = key_transform.to_proc
    end

    ##
    # :attr_accessor: key_transformer
    #
    # object that responds_to :call with arity 1
    # the Field name is passed into the key_transformer
    # A key_transformer has higher precedence than key_transform
    # default is +nil+.
    attr_accessor :key_transformer
  end
end
