module RSpec
  module Parallel
    class Runner < RSpec::Core::Runner
      # @param args [Array<String>]
      def initialize(args)
        options = RSpec::Core::ConfigurationOptions.new(args)
        super(options)
      end

      # @param example_groups [Array<RSpec::Core::ExampleGroup>]
      # @return [Integer] exit status code
      def run_specs(example_groups)
        success = @configuration.reporter.report(0) do |reporter|
          @configuration.with_suite_hooks do
            example_groups.map { |g| g.run(reporter) }.all?
          end
        end && !@world.non_example_failure

        success ? 0 : @configuration.failure_exit_code
      end
    end
  end
end
