# frozen_string_literal: true

require 'bundler/setup'
require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'

RSpec::Core::RakeTask.new(:spec)
RuboCop::RakeTask.new(:rubocop)

desc 'Refresh the Qiniu model catalog'
task :models do
  require 'dotenv/load'
  require_relative 'lib/ruby_llm/providers/qiniu'

  RubyLLM.configure do |config|
    config.qiniu_api_key = ENV.fetch('QINIU_API_KEY', nil)
    config.qiniu_api_base = ENV.fetch('QINIU_BASE_URL', 'https://api.qnaigc.com')
  end

  provider = RubyLLM::Provider.resolve!(:qiniu).new(RubyLLM.config)
  models = provider.list_models
  abort 'Qiniu returned no models' if models.empty?

  RubyLLM::Models.new(models).save_to_json(File.expand_path('models.json', __dir__))
end

desc 'Run Flay duplicate detection'
task :flay do
  sh 'bundle exec flay --mass 70 lib spec'
end

desc 'Run ArchSpec architecture checks'
task :archspec do
  sh 'bundle exec archspec check'
end

task default: %i[rubocop flay archspec spec]
