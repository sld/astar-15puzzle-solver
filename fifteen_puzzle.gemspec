# -*- encoding: utf-8 -*-
require File.expand_path('../lib/fifteen_puzzle/version', __FILE__)

Gem::Specification.new do |gem|

  gem.add_development_dependency "rspec"

  gem.authors       = ["MO-524a"]
  gem.email         = ["mo124a@ya.ru"]
  gem.description   = %q{15puzzle solver with A* algorithm}
  gem.summary       = %q{15puzzle solver with A* algorithm}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "fifteen_puzzle"
  gem.require_paths = ["lib"]
  gem.version       = FifteenPuzzle::VERSION
end
