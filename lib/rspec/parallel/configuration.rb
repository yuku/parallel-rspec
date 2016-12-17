module RSpec
  module Parallel
    # Stores runtime configuration information.
    class Configuration
      DEFULT_AFTER_FORK = ->(_worker) {}

      def after_fork(&block)
        @after_fork_block = block_given? ? block : DEFULT_AFTER_FORK
      end

      def after_fork_block
        @after_fork_block ||= DEFULT_AFTER_FORK
      end
    end
  end
end
