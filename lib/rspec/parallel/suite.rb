module RSpec
  module Parallel
    Suite = Struct.new(:name, :path) do
      @loaded_example_groups = {}

      # @param example_group [RSpec::Core::ExampleGroup]
      def self.add_example_group(example_group)
        @loaded_example_groups[example_group.id] = example_group
      end

      # Convert a suite to a rspec core example group object.
      #
      # @param suite [RSpec::Parallel::Suite]
      # @return [RSpec::Core::ExampleGroup]
      def self.convert(suite)
        @loaded_example_groups[suite.name]
      end

      # @return [RSpec::Core::ExampleGroup]
      def to_example_group
        self.class.convert(self)
      end
    end
  end
end
