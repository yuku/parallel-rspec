module RSpec
  module Parallel
    class Iterator
      include Enumerable

      # @param socket_builder [RSpec::Parallel::SocketBuilder]
      def initialize(socket_builder)
        @socket_builder = socket_builder
      end

      # @yield [RSpec::Parallel::Suite]
      def each
        loop do
          socket = connect_to_distributor
          break if socket.nil?
          _, _, es = IO.select([socket], nil, [socket])
          break unless es.empty?
          break unless (data = socket.read(65_536))
          socket.close
          break unless (suite = Marshal.load(data))
          yield suite
        end
      end

      private

      # @return [RSpec::Parallel::SocketBuilder]
      attr_reader :socket_builder

      # @return [BasicSocket, nil]
      def connect_to_distributor
        return unless (socket = socket_builder.run)
        socket.puts("POP")
        socket
      rescue
        nil
      end
    end
  end
end
