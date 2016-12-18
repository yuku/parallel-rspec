RSpec.describe RSpec::Parallel::Configuration do
  let(:configuration) { described_class.new }

  describe "#after_fork" do
    subject { configuration.after_fork(&block) }
    let(:block) { -> {} }

    it "should change #after_fork_block to the given block" do
      expect { subject }.to change(configuration, :after_fork_block).to block
    end
  end

  describe "#after_fork_block" do
    subject { configuration.after_fork_block }

    it { should be_a Proc }
  end

  describe "#concurrency=" do
    subject { configuration.concurrency = value }
    let(:value) { 1 }

    it "should change #concurrency the the given value" do
      expect { subject }.to change(configuration, :concurrency).from(a_kind_of(Integer)).to(value)
    end
  end

  describe "#upstream=" do
    subject { configuration.upstream = value }
    let(:value) { ["localhost", 3000] }

    it "should change #upstream the the given value" do
      expect { subject }.to change(configuration, :upstream).from(nil).to(value)
    end
  end

  describe "#bind=" do
    subject { configuration.bind = value }
    let(:value) { ["localhost", 3000] }

    it "should change #bind the the given value" do
      expect { subject }.to change(configuration, :bind).from(nil).to(value)
    end
  end
end
