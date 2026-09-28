# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name = 'ruby_llm-providers-qiniu'
  spec.version = '0.1.0'
  spec.authors = ['OuYangJinTing']
  spec.email = ['ou.yang.jin.ting.x@gmail.com']

  spec.summary = 'RubyLLM provider for Qiniu (Modelink).'
  spec.description = 'Adds Qiniu (Modelink) provider support to RubyLLM.'
  spec.homepage = 'https://github.com/Mihuashi/ruby_llm-providers-qiniu'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 3.1'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri'] = "#{spec.homepage}/releases"
  spec.metadata['bug_tracker_uri'] = "#{spec.homepage}/issues"
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = Dir.glob('{lib,spec}/**/*') +
               Dir.glob('.github/workflows/*.yml') +
               Dir.glob('models.json') +
               %w[.flayignore .overcommit.yml .rspec .rubocop.yml Archspec.rb LICENSE README.md]
  spec.require_paths = ['lib']

  spec.add_dependency 'ruby_llm', '>= 2.0.0.rc1'
end
