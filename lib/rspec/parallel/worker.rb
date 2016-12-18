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
          break unless (data = socket.read(65_536))
          socket.close
          break unless (item = Marshal.load(data))
          break if item.nil?
          process(item)
        end
      end

      private

      def process(item)
        puts "Worker[#{number}] #{item}"
      end

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
