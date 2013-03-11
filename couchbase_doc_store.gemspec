# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'couchbase_doc_store/version'

Gem::Specification.new do |gem|
  gem.name          = "couchbase-docstore"
  gem.version       = CouchbaseDocStore::VERSION
  gem.authors       = ["Jasdeep Jaitla"]
  gem.email         = ["jasdeep@scalabl3.com"]
  gem.description   = %q{A Convenient Wrapper for the Couchbase gem, uses Map gem and adds new functionality}
  gem.summary       = %q{You simply use the Couchbase gem, or you can use this wrapper that encapsulates the gem and adds some subjective conveniences. }
  gem.homepage      = "https://github.com/scalabl3/couchbase-docstore"

  gem.add_dependency('couchbase-settings', '>= 0.1.4')
  gem.add_dependency('couchbase', '>= 1.2')
  
  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
end
