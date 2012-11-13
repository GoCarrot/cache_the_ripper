# -*- encoding: utf-8 -*-
require File.expand_path('../lib/cache_the_ripper/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Alex Scarborough"]
  gem.email         = ["alex@gocarrot.com"]
  gem.description   = %q{Automatic versioning of Rails templates for key-based cache expiration}
  gem.summary       = %q{Automatic versioning of Rails templates for key-based cache expiration}
  gem.homepage      = "https://github.com/GoCarrot/cache_the_ripper"

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "cache_the_ripper"
  gem.require_paths = ["lib"]
  gem.version       = CacheTheRipper::VERSION

  gem.add_dependency('sorcerer')
end
