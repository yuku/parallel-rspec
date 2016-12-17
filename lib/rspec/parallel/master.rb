require_relative "distributor"
require_relative "socket_builder/tcp_socket"
require_relative "socket_builder/unix_socket"
require_relative "worker"

module RSpec
  module Parallel
    class Master
      HOST_PORT_REGEXP = /\A(?<host>[0-9a-zA-Z\-.]+):(?<port>\d+)\z/

      # @return [Array<Integer>] array of pids of spawned worker processes
      attr_reader :pids

      # @param concurrency [Integer, nil]
      # @param upstream [String]
      # @param bind [String]
      def initialize(concurrency: nil, upstream: nil, bind: nil)
        @pids = []
        @concurrency = concurrency

        if (match = HOST_PORT_REGEXP.match(upstream))
          @upstream = match[:host], match[:port].to_i
        else
          match = HOST_PORT_REGEXP.match(bind)
          bind = match[:host], match[:port].to_i if match
          @distributor = Distributor.new(bind)
        end
      end

      # @return [void]
      def start
        concurrency.times do
          pid = spawn_worker
          pids << pid
          Process.detach(pid)
        end
        distributor.run if central?
        Process.waitall
      end

      private

      # @return [RSpec::Parallel::Distributor, nil]
      attr_reader :distributor

      # @return [Array<(String, Integer)>, nil] pair of host and port of upstream server
      attr_reader :upstream

      # @return [true, false] whether it is central master process
      def central?
        upstream.nil?
      end

      # @return [Integer]
      def concurrency
        @concurrency ||=
          if File.exist?("/proc/cpuinfo")
            File.read("/proc/cpuinfo").split("\n").grep(/processor/).size
          elsif RUBY_PLATFORM =~ /darwin/
            `/usr/sbin/sysctl -n hw.activecpu`.to_i
          else
            2
          end
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
