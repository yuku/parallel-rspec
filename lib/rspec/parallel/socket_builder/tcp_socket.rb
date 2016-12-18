require "socket"
require_relative "base"

module RSpec
  module Parallel
    module SocketBuilder
      class TCPSocket < Base
        private

        # @note Implement {RSpec::Parallel::SocketBuilder::Base#build}.
        def build
          ::TCPSocket.new(*info)
        end
      end
    end
  end
end
