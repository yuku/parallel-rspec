require "socket"
require_relative "base"

module RSpec
  module Parallel
    module SocketBuilder
      class UNIXSocket < Base
        # @note Implement {RSpec::Parallel::SocketBuilder::Base#build}.
        def run
          ::UNIXSocket.new(info.first)
        rescue
          nil
        end
      end
    end
  end
end
