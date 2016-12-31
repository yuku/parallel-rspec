require_relative "protocol"

module RSpec
  module Parallel
    class Worker
      # @return [Integer]
      attr_reader :number

      # @param master [RSpec::Parallel::Master]
      # @param number [Integer]
      def initialize(master, number)
        RSpec::Parallel.configuration.logger.info("Initialize Iterator")
        @iterator = Iterator.new(master.socket_builder)
        @number = number
        RSpec::Parallel.configuration.logger.info("Initialize SpecRunner")
        @spec_runner = SpecRunner.new(master.args)
      end

      # @return [void]
      def run
        iterator.ping
        spec_runner.run_specs(iterator).to_i
      end

      private

      attr_reader :iterator, :spec_runner

      class Iterator
        include Enumerable

        # @param socket_builder [RSpec::Parallel::SocketBuilder]
        def initialize(socket_builder)
          @socket_builder = socket_builder
        end

        # @return [void]
        def ping
          loop do
            socket = connect_to_distributor
            if socket.nil?
              RSpec::Parallel.configuration.logger.info("Sleep a little to wait master process")
              sleep 0.5
              next
            end
            RSpec::Parallel.configuration.logger.info("Send PING request")
            socket.puts(Protocol::PING)
            # TODO: handle socket error and check pong message
            IO.select([socket])
            socket.read(65_536)
            socket.close
            break
          end
        end

        # @yield [RSpec::Core::ExampleGroup]
        def each
          loop do
            socket = connect_to_distributor
            break if socket.nil?
            RSpec::Parallel.configuration.logger.info("Send POP request")
            socket.puts(Protocol::POP)
            _, _, es = IO.select([socket], nil, [socket])
            unless es.empty?
              RSpec::Parallel.configuration.logger.error("Socket error occurs")
              break
            end
            path = socket.read(65_536)
            socket.close
            RSpec.world.example_groups.clear
            RSpec::Parallel.configuration.logger.info("Load #{path}")
            Kernel.load path
            RSpec.world.example_groups.each do |example_group|
              yield example_group
            end
          end
        end

        private

        # @return [RSpec::Parallel::SocketBuilder]
        attr_reader :socket_builder

        # @return [BasicSocket, nil]
        def connect_to_distributor
          socket_builder.run
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
          # Reset filter manager to run all specs. Just for simplicity
          # TODO: Support config.run_all_when_everything_filtered = true
          @configuration.filter_manager = RSpec::Core::FilterManager.new

          success = @configuration.reporter.report(0) do |reporter|
            @configuration.with_suite_hooks do
              example_groups.map do |g|
                RSpec::Parallel.configuration.logger.info("Run #{g.inspect}")
                g.run(reporter)
              end.all?
            end
          end && !@world.non_example_failure

          success ? 0 : @configuration.failure_exit_code
        end
      end
    end
  end
end
