lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require "rspec/parallel/version"

Gem::Specification.new do |spec|
  spec.name                  = "rspec-parallel"
  spec.authors               = ["Yuku Takahashi"]
  spec.email                 = ["taka84u9@gmail.com"]
  spec.version               = RSpec::Parallel::VERSION
  spec.summary               = "Parallel spec runner for RSpec 3"
  spec.license               = "MIT"
  spec.required_ruby_version = ">= 2.0"
  spec.homepage              = "https://github.com/yuku-t/rspec-parallel"

  spec.executables           = ["rspec-parallel"]
  spec.files                 = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^spec/}) }

  spec.add_dependency "rspec-core", "~> 3.0"

  spec.add_development_dependency "rake", "~> 11.3"
  spec.add_development_dependency "rspec", "~> 3.5.0"
  spec.add_development_dependency "rubocop", "~> 0.45.0"
  spec.add_development_dependency "simplecov", "~> 0.12.0"
end
