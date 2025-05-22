# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'simple_json/version'

Gem::Specification.new do |spec|
  spec.name          = 'simple_json'
  spec.version       = SimpleJson::VERSION
  spec.authors       = ['Jingyuan Zhao']
  spec.email         = ['jingyuan.zhao@aktsk.jp']

  spec.summary       = 'Faster and simpler Jbuilder alternative'
  spec.description   = 'Faster and simpler JSON renderer for Rails'
  spec.homepage      = 'https://github.com/aktsk/simple_json'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'oj', '~> 3.13'

  spec.add_development_dependency 'action_args'
  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'debug'
  spec.add_development_dependency 'rails', '~> 8.0'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'selenium-webdriver'
  spec.add_development_dependency 'test-unit-rails'
  spec.add_development_dependency 'mutex_m'

  spec.required_ruby_version = '>= 3.2.0'
end
