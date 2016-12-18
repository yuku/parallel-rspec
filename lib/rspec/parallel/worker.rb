require_relative "iterator"

module RSpec
  module Parallel
    class Worker
      # @return [Integer]
      attr_reader :number

      # @param socket_builder [RSpec::Parallel::SocketBuilder::Base]
      # @param number [Integer]
      def initialize(socket_builder, number)
        @iterator = Iterator.new(socket_builder)
        @number = number
      end

      # @return [void]
      def run
        iterator.each do |suite|
          puts "Worker[#{number}] #{suite.inspect}"
        end
      end

      private

      # @return [RSpec::Parallel::Iterator]
      attr_reader :iterator
    end
  end
end
