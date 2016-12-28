require "English"
require "fileutils"
require "rspec/core"
require "socket"

require_relative "errors"
require_relative "protocol"
require_relative "socket_builder"
require_relative "suite"

module RSpec
  module Parallel
    class Master
      # @param args [Array<String>]
      attr_reader :args

      # @param args [Array<String>] command line arguments
      def initialize(args)
        @args = args
        @path = "/tmp/rspec-parallel-#{$PID}.sock"
        @queue = []
        @server = ::UNIXServer.new(@path)
      end

      # @return [void]
      def close
        server.close
      end

      # @return [void]
      def run
        until queue.empty?
          rs, _ws, _es = IO.select([server])
          rs.each do |s|
            socket = s.accept
            method, _data = socket.gets.strip.split("\t", 2)
            case method
            when Protocol::POP
              suite = queue.pop
              puts "Deliver #{suite.name}"
              socket.write(Marshal.dump(suite))
            when Protocol::PING
              socket.write("ok")
            end
            socket.close
          end
        end
        close
        remove_socket_file
      end

      # @raise [RSpec::Parallel::EmptyQueue]
      # @return [void]
      def load_suites
        files_to_run.each { |path| Kernel.load(path) }
        @queue = ::RSpec.world.example_groups.map do |example_or_group|
          Suite.add_example_group(example_or_group)
          Suite.new(example_or_group.id, example_or_group.metadata[:file_path])
        end
        raise EmptyQueue if @queue.empty?
      end

      # Create a socket builder which builds a socket to
      # connect with the master process.
      #
      # @return [RSpec::Parallel::SocketBuilder]
      def socket_builder
        SocketBuilder.new(path)
      end

      private

      # @return [String, nil] path to unix domain socket
      attr_reader :path

      # @return [Array<RSpec::Parallel::Suite>]
      attr_reader :queue

      # @return [UNIXServer]
      attr_reader :server

      # @return [void]
      def remove_socket_file
        FileUtils.rm(path, force: true)
      end

      # @example
      #   files_to_run
      #   #=> ["spec/rspec/parallel_spec.rb", "spec/rspec/parallel/configuration_spec.rb"]
      # @return [Array<String>]
      def files_to_run
        ::RSpec.configuration.files_to_run.uniq
      end
    end
  end
end
