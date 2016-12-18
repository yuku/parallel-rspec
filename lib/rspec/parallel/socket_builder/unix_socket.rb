require "socket"
require_relative "base"

module RSpec
  module Parallel
    module SocketBuilder
      class UNIXSocket < Base
        private

        # @note Implement {RSpec::Parallel::SocketBuilder::Base#build}.
        def build
          ::UNIXSocket.new(info.first)
        end
      end
    end
  end
end
