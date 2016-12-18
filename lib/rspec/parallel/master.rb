require_relative "distributor"
require_relative "socket_builder/tcp_socket"
require_relative "socket_builder/unix_socket"
require_relative "worker"

module RSpec
  module Parallel
    class Master
      # @return [Array<Integer>] array of pids of spawned worker processes
      attr_reader :pids

      def initialize
        @pids = []
      end

      # @return [void]
      def start
        RSpec::Parallel.configuration.concurrency.times do
          pid = spawn_worker
          pids << pid
          Process.detach(pid)
        end
        distributor.run if central?
        Process.waitall
      end

      private

      # @return [RSpec::Parallel::Distributor, nil]
      def distributor
        return @distributor if instance_variable_defined? :@distributor
        @distributor ||= central? ? Distributor.new(RSpec::Parallel.configuration.bind) : nil
      end

      # @return [true, false] whether it is central master process
      def central?
        RSpec::Parallel.configuration.upstream.nil?
      end

      # @return [Integer] pid of the spawned worker process
      def spawn_worker
        Kernel.fork do
          worker = Worker.new(socket_builder, pids.size)
          $0 = "rspec-parallel worker [#{worker.number}]"
          RSpec::Parallel.configuration.after_fork_block.call(worker.number)
          worker.run
          Kernel.exit! # avoid running any `at_exit` functions.
        end
      end

      # @return [RSpec::Parallel::SocketBuilder::Base]
      def socket_builder
        if central?
          SocketBuilder::UNIXSocket.new(distributor.path)
        else
          SocketBuilder::TCPSocket.new(*upstream)
        end
      end
    end
  end
end
