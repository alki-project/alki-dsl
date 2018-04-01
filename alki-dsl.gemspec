# coding: utf-8
require_relative 'lib/alki/dsl/version'

Gem::Specification.new do |spec|
  spec.name          = "alki-dsl"
  spec.version       = Alki::Dsl::VERSION
  spec.authors       = ["Matt Edlefsen"]
  spec.email         = ["matt.edlefsen@gmail.com"]
  spec.summary       = %q{Alki dsl library}
  spec.description   = %q{Library for defining and using DSLs}
  spec.homepage      = "http://alki.io/projects/alki-dsl"
  spec.license       = "MIT"
  spec.required_ruby_version = '>= 2.1.0'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.bindir        = 'exe'
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'alki-support', '~> 0.7', ">= 0.7.1"
  spec.add_dependency 'alki-loader', '~> 0.2', '>= 0.2.4'
end
