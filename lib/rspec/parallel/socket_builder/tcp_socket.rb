require "socket"
require_relative "base"

module RSpec
  module Parallel
    module SocketBuilder
      class TCPSocket < Base
        # @note Implement {RSpec::Parallel::SocketBuilder::Base#build}.
        def run
          ::TCPSocket.new(*info)
        rescue
          nil
        end
      end
    end
  end
end
