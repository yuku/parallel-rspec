require "socket"

RSpec.describe RSpec::Parallel::SocketBuilder::TCPSocket do
  describe "#run" do
    subject { builder.run }
    let(:builder) { described_class.new(*info) }

    context "with valid info" do
      before { @server = ::TCPServer.new(4629) }
      after { @server.close }
      let(:info) { ["localhost", 4629] }

      it { should be_a ::TCPSocket }
    end

    context "with invalid info" do
      let(:info) { [] }

      it { should be_nil }
    end
  end
end
