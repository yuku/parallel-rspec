module RSpec
  module Parallel
    Suite = Struct.new(:name, :path) do
      @loaded_example_groups = {}

      # Convert a suite to a rspec core example group object.
      #
      # @param suite [RSpec::Parallel::Suite]
      # @return [RSpec::Core::ExampleGroup]
      def self.convert(suite)
        unless @loaded_example_groups[suite.name]
          RSpec.world.example_groups.clear
          Kernel.load(suite.path)
          RSpec.world.example_groups.each do |example_group|
            @loaded_example_groups[example_group.id] = example_group
          end
        end
        @loaded_example_groups[suite.name]
      end

      # @return [RSpec::Core::ExampleGroup]
      def to_example_group
        self.class.convert(self)
      end
    end
  end
end
