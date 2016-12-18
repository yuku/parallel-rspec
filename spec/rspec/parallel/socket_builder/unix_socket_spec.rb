require "fileutils"
require "socket"

RSpec.describe RSpec::Parallel::SocketBuilder::UNIXSocket do
  describe "#run" do
    subject { builder.run }
    let(:builder) { described_class.new(*info) }

    context "with valid info" do
      before { @server = UNIXServer.new(path) }

      after do
        @server.close
        FileUtils.safe_unlink(path)
      end

      let(:path) { "/tmp/unix-soket-#{rand}" }
      let(:info) { [path] }

      it { should be_a ::UNIXSocket }
    end

    context "with invalid info" do
      let(:info) { [] }

      it { should be_nil }
    end
  end
end
