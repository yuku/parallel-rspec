require_relative "protocol"

module RSpec
  module Parallel
    class Worker
      # @return [Integer]
      attr_reader :number

      # @param args [Array<String>]
      # @param socket_builder [RSpec::Parallel::SocketBuilder::Base]
      # @param number [Integer]
      def initialize(args, socket_builder, number)
        @args = args
        @iterator = Iterator.new(socket_builder)
        @number = number
      end

      # @return [void]
      def run
        SpecRunner.new(args).run_specs(iterator).to_i
      end

      private

      attr_reader :iterator, :args

      class Iterator
        include Enumerable

        # @param socket_builder [RSpec::Parallel::SocketBuilder]
        def initialize(socket_builder)
          @socket_builder = socket_builder
        end

        # @yield [RSpec::Core::ExampleGroup]
        def each
          loop do
            socket = connect_to_distributor
            break if socket.nil?
            _, _, es = IO.select([socket], nil, [socket])
            break unless es.empty?
            break unless (data = socket.read(65_536))
            socket.close
            break unless (suite = Marshal.load(data))
            yield suite.to_example_group
          end
        end

        private

        # @return [RSpec::Parallel::SocketBuilder]
        attr_reader :socket_builder

        # @return [BasicSocket, nil]
        def connect_to_distributor
          return unless (socket = socket_builder.run)
          socket.puts(Protocol::POP)
          socket
        rescue
          nil
        end
      end

      class SpecRunner < RSpec::Core::Runner
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
end
