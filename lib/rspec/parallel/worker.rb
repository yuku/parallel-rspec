module RSpec
  module Parallel
    class Worker
      # @return [Integer]
      attr_reader :number

      # @param socket_builder [RSpec::Parallel::SocketBuilder]
      # @param number [Integer]
      def initialize(socket_builder, number)
        @socket_builder = socket_builder
        @number = number
      end

      # @return [void]
      def run
        loop do
          socket = connect_to_distributor
          break if socket.nil?
          _, _, es = IO.select([socket], nil, [socket])
          break unless es.empty?
          data = socket.read(65_536)
          break unless data
          socket.close
          item = Marshal.load(data)
          puts "Worker[#{number}] #{item}"
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
      end
    end
  end
end
