# frozen_string_literal: true

require 'ializer/version'

require 'ser/ializer/field'
require 'ser/ializer'
require 'de/ser/ializer'

require 'ializer/big_decimal_de_ser'
require 'ializer/boolean_de_ser'
require 'ializer/date_de_ser'
require 'ializer/default_de_ser'
require 'ializer/fix_num_de_ser'
require 'ializer/float_de_ser'
require 'ializer/millis_de_ser'
require 'ializer/string_de_ser'
require 'ializer/symbol_de_ser'
require 'ializer/time_de_ser'

require 'ializer/config'

require 'multi_json'

module Ializer
  # Returns the global configuration instance
  def self.config
    @config ||= Ializer::Config.new
  end

  # Initialization block is passed a global Config instance that can be
  # used to configure Ializer behavior.  E.g., if you want to
  # disable automation DefaultDeSer warnings put the following in
  # an initializer: config/initializers/ializer.rb
  #
  #    Ializer.setup do |config|
  #       config.warn_on_default = false
  #    end
  #
  def self.setup
    yield config
  end
end
