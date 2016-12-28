require "English"

require_relative "master"
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
        RSpec::Parallel.configuration.concurrency.times do
          spawn_worker(master)
        end
        master.load_suites(args)
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

      # @param master [RSpec::Parallel::Master]
      def spawn_worker(master)
        pid = Kernel.fork do
          RSpec.reset # Avoid to share rspec state with master process
          master.close
          worker = Worker.new(args, master.socket_builder, pids.size)
          $0 = "rspec-parallel worker [#{worker.number}]"
          RSpec::Parallel.configuration.after_fork_block.call(worker)

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
