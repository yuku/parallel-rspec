module RSpec
  module Parallel
    class Engine < ::Rails::Railtie
      rake_tasks do
        require "rspec/parallel/rake_task"
      end
    end
  end
end
