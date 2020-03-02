lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "event_dispatcher/version"

Gem::Specification.new do |spec|
  spec.name          = "event_dispatcher"
  spec.version       = EventDispatcher::VERSION
  spec.authors       = ["Lewis Eason"]
  spec.email         = ["me@lewiseason.co.uk"]

  spec.summary       = "Library to help reduce coupling parts of an application by dispatching domain events."
  spec.license       = "MIT"

  spec.files         = Dir["lib/**/*.rb"]
  spec.test_files    = Dir["spec/**/*.rb"]
  spec.require_paths = ["lib"]

  spec.add_dependency "dry-struct", "~> 1.3.0"
  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "byebug"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rubocop", "~> 0.80.0"
  spec.add_development_dependency "rubocop-rspec"
end
