require "rspec/parallel/configuration"

module RSpec
  module Parallel
    # @return [RSpec::Parallel::Configuration]
    def self.configuration
      @configuration ||= RSpec::Parallel::Configuration.new
    end

    # Yields the global configuration to a block.
    #
    # @yield [RSpec::Parallel::Configuration]
    # @example
    #   RSpec::Parallel.configure do |config|
    #     config.bind = "0.0.0.0:8000"
    #   end
    def self.configure
      yield configuration if block_given?
    end
  end
end
