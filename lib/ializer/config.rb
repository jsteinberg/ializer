# frozen_string_literal: true

module Ializer
  class Config
    def initialize
      @warn_on_default = true
    end

    ##
    # :key_transform=: key_transform
    #
    # symbol of string transform to call on field keys
    # default is +:dasherize+.
    def key_transform=(key_transform)
      self.key_transformer = key_transform&.to_proc
    end

    ##
    # :attr_accessor: key_transformer
    #
    # object that responds_to :call with arity 1
    # the Field name is passed into the key_transformer
    # A key_transformer has higher precedence than key_transform
    # default is +nil+.
    attr_accessor :key_transformer

    ##
    # :attr_accessor: warn_on_default
    #
    # The DefaultDeSer when converting to JSON will only work properly for standard
    # JSON value types(:string, :number, :boolean)
    # A warning message will be logged if the DefaultDeSer has been used
    # default is +true+.
    attr_accessor :warn_on_default
    alias warn_on_default? warn_on_default

    ##
    # :attr_accessor: raise_on_default
    #
    # The DefaultDeSer when converting to JSON will only work properly for standard
    # JSON value types(:string, :number, :boolean)
    # An error will be raised if the DefaultDeSer has been used
    # default is +nil+.
    attr_accessor :raise_on_default
    alias raise_on_default? raise_on_default
  end
end
