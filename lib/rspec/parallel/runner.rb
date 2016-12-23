require "English"

require_relative "master"
require_relative "socket_builder/unix_socket"
require_relative "worker"

module RSpec
  module Parallel
    class Runner
      # @return [Array<Integer>] array of pids of spawned worker processes
      attr_reader :pids

      # @param args [Array<String>] command line arguments
      def initialize(args)
        @args = args
        @pids = []
      end

      # @return [void]
      def start
        master = Master.new
        master.load_suites(args)
        RSpec::Parallel.configuration.concurrency.times do
          spawn_worker(SocketBuilder::UNIXSocket.new(master.path))
        end
        master.run
        Process.waitall

        pids.each.with_index do |pid, index|
          puts "----> output from worker[#{index}]"
          File.open(output_file_path(pid)) do |file|
            puts file.read
          end
        end
      end

      private

      # @return [Array<String>]
      attr_reader :args

      # @param socket_builder [RSpec::Parallel::SocketBuilder::Base]
      def spawn_worker(socket_builder)
        pid = Kernel.fork do
          sleep 0.1 # Make sure that master is readly
          RSpec.reset # Avoid to share rspec state with master process
          worker = Worker.new(args, socket_builder, pids.size)
          $0 = "rspec-parallel worker [#{worker.number}]"
          RSpec::Parallel.configuration.after_fork_block.call(worker.number)

          File.open(output_file_path($PID), "w") do |file|
            # Redirect stdout and stderr to temp file
            $stdout.reopen(file)
            $stderr.reopen($stdout)
            $stdout.sync = $stderr.sync = true
            worker.run
          end

          Kernel.exit! # avoid running any `at_exit` functions.
        end
        pids << pid
        Process.detach(pid)
      end

      # @param pid [Integer]
      # @return [String]
      def output_file_path(pid)
        "/tmp/rspec-parallel-worker-#{pid}"
      end
    end
  end
end
