# -*- encoding: utf-8 -*-
require File.expand_path('../lib/kind_editor_white_list/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["lg2046"]
  gem.email         = ["lg2046@gmail.com"]
  gem.description   = %q{kind editor white list}
  gem.summary       = %q{kind editor white list}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "kind_editor_white_list"
  gem.require_paths = ["lib"]
  gem.version       = KindEditorWhiteList::VERSION
end
