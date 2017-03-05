# coding: utf-8
require_relative 'lib/alki/dsl/version'

Gem::Specification.new do |spec|
  spec.name          = "alki-dsl"
  spec.version       = Alki::Dsl::VERSION
  spec.authors       = ["Matt Edlefsen"]
  spec.email         = ["matt.edlefsen@gmail.com"]
  spec.summary       = %q{Alki dsl library}
  spec.description   = %q{Library for defining and using DSLs}
  spec.homepage      = "https://github.com/medlefsen/alki-dsl"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.bindir        = 'exe'
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'alki-support', '~> 0.7'
  spec.add_dependency 'alki-loader', '~> 0.2'
  spec.add_development_dependency 'minitest', '~> 5.9', '>= 5.9.1'
end
