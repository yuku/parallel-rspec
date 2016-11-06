module RSpec
  module Parallel
    module SocketBuilder
      # @abstract
      class Base
        def initialize(*info)
          @info = info
        end

        # @return [BasicSocket]
        def run
          raise NotImplementedError
        end

        private

        # @return [Array]
        attr_reader :info
      end
    end
  end
end
