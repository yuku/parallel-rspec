require "fileutils"
require "socket"

RSpec.describe RSpec::Parallel::SocketBuilder do
  describe "#run" do
    subject { builder.run(1) }
    let(:builder) { described_class.new(path) }

    context "with valid info" do
      before { @server = UNIXServer.new(path) }

      after do
        @server.close
        FileUtils.safe_unlink(path)
      end

      let(:path) { "/tmp/unix-soket-#{rand}" }

      it { should be_a ::UNIXSocket }
    end

    context "with invalid info" do
      let(:path) { nil }

      it { should be_nil }
    end
  end
end
