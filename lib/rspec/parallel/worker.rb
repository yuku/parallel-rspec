require_relative "iterator"
require_relative "runner"

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
        Runner.new(args).run_specs(iterator).to_i
      end

      private

      attr_reader :iterator, :args
    end
  end
end
