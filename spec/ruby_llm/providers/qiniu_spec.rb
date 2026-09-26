# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RubyLLM::Providers::Qiniu do
  subject(:provider) { described_class.new(config) }

  let(:config) do
    RubyLLM::Configuration.new.tap do |provider_config|
      provider_config.qiniu_api_key = 'test-key'
      provider_config.qiniu_api_base = 'https://example.test/v1'
    end
  end

  it 'is registered with RubyLLM' do
    expect(RubyLLM::Provider.resolve(:qiniu)).to eq(described_class)
  end

  it 'registers a default protocol' do
    expect(described_class.protocols).to include(chat_completions: described_class::ChatCompletions)
  end

  it 'declares provider configuration' do
    expect(described_class.configuration_options).to eq(%i[qiniu_api_key qiniu_api_base])
    expect(described_class.configuration_requirements).to eq(%i[qiniu_api_key])
  end

  it 'uses configured API base and bearer token' do
    expect(provider.api_base).to eq('https://example.test/v1')
    expect(provider.headers).to eq('Authorization' => 'Bearer test-key')
  end
end
