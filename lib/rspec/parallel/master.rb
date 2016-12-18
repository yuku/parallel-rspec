require_relative "distributor"
require_relative "socket_builder/unix_socket"
require_relative "worker"

module RSpec
  module Parallel
    class Master
      # @return [Array<Integer>] array of pids of spawned worker processes
      attr_reader :pids

      # @param args [Array<String>] command line arguments
      def initialize(args)
        @args = args
        @pids = []
      end

      # @return [void]
      def start
        distributor = Distributor.new
        distributor.load_suites(args)
        RSpec::Parallel.configuration.concurrency.times do
          spawn_worker(SocketBuilder::UNIXSocket.new(distributor.path))
        end
        distributor.run
        Process.waitall
      end

      private

      # @return [Array<String>]
      attr_reader :args

      # @param socket_builder [RSpec::Parallel::SocketBuilder::Base]
      def spawn_worker(socket_builder)
        pid = Kernel.fork do
          sleep 0.1 # Make sure that distributor is readly
          RSpec.reset # Avoid to share rspec state with master process
          worker = Worker.new(socket_builder, pids.size)
          $0 = "rspec-parallel worker [#{worker.number}]"
          RSpec::Parallel.configuration.after_fork_block.call(worker.number)
          worker.run
          Kernel.exit! # avoid running any `at_exit` functions.
        end
        pids << pid
        Process.detach(pid)
      end
    end
  end
end
