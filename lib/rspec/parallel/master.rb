require "English"
require "fileutils"
require "rspec/core"
require "socket"

require_relative "errors"
require_relative "protocol"
require_relative "socket_builder"

module RSpec
  module Parallel
    class Master
      # @param args [Array<String>]
      attr_reader :args

      # @note RSpec must be configured ahead
      # @param args [Array<String>] command line arguments
      def initialize(args)
        @args = args
        @path = "/tmp/rspec-parallel-#{$PID}.sock"
        @files_to_run = ::RSpec.configuration.files_to_run.uniq
        @server = ::UNIXServer.new(@path)
      end

      # @return [void]
      def close
        server.close
      end

      # @return [void]
      def run
        until files_to_run.empty?
          rs, _ws, _es = IO.select([server])
          rs.each do |s|
            socket = s.accept
            method, _data = socket.gets.strip.split("\t", 2)
            case method
            when Protocol::POP
              path = files_to_run.pop
              RSpec::Parallel.configuration.logger.info("Deliver #{path}")
              socket.write(path)
            when Protocol::PING
              socket.write("ok")
            end
            socket.close
          end
        end
        close
        remove_socket_file
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

      # @example
      #   files_to_run
      #   #=> ["spec/rspec/parallel_spec.rb", "spec/rspec/parallel/configuration_spec.rb"]
      # @return [Array<String>]
      attr_reader :files_to_run

      # @return [UNIXServer]
      attr_reader :server

      # @return [void]
      def remove_socket_file
        FileUtils.rm(path, force: true)
      end
    end
  end
end
