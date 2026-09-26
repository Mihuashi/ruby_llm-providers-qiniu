# ruby_llm-providers-qiniu

RubyLLM provider gem for Qiniu.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ruby_llm-providers-qiniu', require: 'ruby_llm/providers/qiniu'
```

Then configure the provider:

```ruby
require 'ruby_llm/providers/qiniu'

RubyLLM.configure do |config|
  config.qiniu_api_key = ENV['QINIU_API_KEY']
  config.qiniu_api_base = ENV.fetch('QINIU_BASE_URL', 'https://api.qnaigc.com')
end
```

## Usage

```ruby
model = RubyLLM.models.by_provider(:qiniu).chat_models.first
chat = RubyLLM.chat(model: model.id)
response = chat.ask('Hello')
puts response.content
```

## Development

The generator installs the bundle and creates an ignored `.env`. Edit the generated `op read` reference so it points to your 1Password credential. If you do not use the 1Password CLI, replace the expression with the provider key.

```sh
bundle exec rake models
bundle exec rake
```

`rake models` calls only Qiniu's model-listing endpoint and writes `models.json` at the gem root. RubyLLM loads that catalog as a fallback when this provider is registered, so applications do not need to combine registry files. The main RubyLLM registry always wins when both catalogs carry the same model. If the API uses a different path, change `models_url` in `lib/ruby_llm/providers/qiniu.rb`.

Run `rake models` from this provider gem when you want to update its packaged catalog. `RubyLLM.models.refresh` updates the application's main registry and does not refresh provider gem catalogs.

If the provider has no model-listing endpoint, uncomment `assume_models_exist?` in the provider and do not run `rake models`.

The suite always runs the provider integration specs. The first local run calls the API and records VCR cassettes; CI only replays committed cassettes. A failing example deletes its cassette so the next local run tests the live API again.

After refreshing the catalog, add real model IDs to `spec/support/models.rb`. Keep only the operation matrices the provider supports. The portable contract specs are adapted from [RubyLLM's live specs](https://github.com/crmne/ruby_llm/tree/main/spec/ruby_llm); use those as the reference when your provider needs coverage for another feature or dialect.
