# frozen_string_literal: true

require 'bundler/setup'

require 'simplecov'
SimpleCov.start 'test_frameworks'

require 'ializer'

::Ializer.config.key_transform = :dasherize

Dir[File.dirname(__FILE__) + '/support/model/*.rb'].sort.each { |f| require f }
Dir[File.dirname(__FILE__) + '/support/**/*.rb'].sort.each { |f| require f }

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
