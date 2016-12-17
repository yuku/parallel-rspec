require "rspec/parallel"
require "rspec/parallel/configuration"

RSpec.describe RSpec::Parallel do
  describe ".configuration" do
    subject { described_class.configuration }

    it { should be_a RSpec::Parallel::Configuration }
  end

  describe ".configure" do
    specify do
      expect { |b| described_class.configure(&b) }.to yield_with_args(described_class.configuration)
    end
  end
end
