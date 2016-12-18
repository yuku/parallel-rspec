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
end
