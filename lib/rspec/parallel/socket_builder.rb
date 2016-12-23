require "socket"

module RSpec
  module Parallel
    class SocketBuilder
      def initialize(path)
        @path = path
      end

      # @return [BasicSocket, nil]
      def run(retry_counter = 3)
        build
      rescue
        retry_counter -= 1
        if retry_counter > 0
          sleep rand
          retry
        end
        nil
      end

      private

      # @return [UNIXSocket]
      def build
        ::UNIXSocket.new(path)
      end

      # @return [String]
      attr_reader :path
    end
  end
end
