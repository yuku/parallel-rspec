module RSpec
  module Parallel
    module SocketBuilder
      # @abstract
      class Base
        def initialize(*info)
          @info = info
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

        # @return [BasicSocket]
        def build
          raise NotImplementedError
        end

        # @return [Array]
        attr_reader :info
      end
    end
  end
end
