require "english"
require "fileutils"
require "socket"
require "rspec/core"

require_relative "./errors"

module RSpec
  module Parallel
    class Distributor
      # @return [String, nil] path to unix domain socket
      attr_reader :path

      # @param args [Array<String>] command line arguments
      # @param bind [Array<(String, Integer)>, nil]
      # @raise [RSpec::Parallel::EmptyQueue]
      def initialize(args, bind)
        options = ::RSpec::Core::ConfigurationOptions.new(args)
        options.configure(::RSpec.configuration)
        @queue = ::RSpec.configuration.files_to_run.uniq
        raise EmptyQueue if @queue.empty?
        @path = "/tmp/rspec-parallel-#{$PID}.sock"
        @bind = bind
        remove_socket_file
      end

      # @return [void]
      def close
        tcp_server.close if tcp_server
        unix_server.close
        remove_socket_file
      end

      # @return [void]
      def run
        until queue.empty?
          rs, _ws, _es = IO.select(servers)
          rs.each do |server|
            socket = server.accept
            case socket.gets.strip
            when /\APOP/
              socket.write(Marshal.dump(queue.pop))
            end
            socket.close
          end
        end
        close
      end

      private

      # @return [Array<(String, Integer)>, nil]
      attr_reader :bind

      # @example
      #   queue
      #   #=> ["spec/rspec/parallel_spec.rb", "spec/rspec/parallel/configuration_spec.rb"]
      # @return [Array<String>]
      attr_reader :queue

      # @return [Array<BasicSocket>] array of servers
      def servers
        [unix_server, tcp_server].compact
      end

      # @return [UNIXServer]
      def unix_server
        @unix_server ||= UNIXServer.new(path)
      end

      # @return [TCPServer]
      def tcp_server
        @tcp_server ||= bind && TCPServer.new(*bind)
      end

      # @return [void]
      def remove_socket_file
        FileUtils.rm(path, force: true)
      end
    end
  end
end
