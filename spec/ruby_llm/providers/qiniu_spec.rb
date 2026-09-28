# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RubyLLM::Providers::Qiniu do
  subject(:provider) { described_class.new(config) }

  let(:config) do
    RubyLLM::Configuration.new.tap do |provider_config|
      provider_config.qiniu_api_key = 'test-key'
      provider_config.qiniu_api_base = 'https://example.test'
    end
  end

  it 'is registered with RubyLLM' do
    expect(RubyLLM::Provider.resolve(:qiniu)).to eq(described_class)
  end

  it 'registers the documented access protocols' do
    expect(described_class.protocols.keys).to eq(
      %i[chat_completions anthropic responses anthropic_bypass gemini_bypass]
    )
    expect(described_class.default_protocol).to eq(:chat_completions)
  end

  it 'declares provider configuration' do
    expect(described_class.configuration_options).to eq(%i[qiniu_api_key qiniu_api_base])
    expect(described_class.configuration_requirements).to eq(%i[qiniu_api_key])
  end

  it 'uses configured API base and bearer token' do
    expect(provider.api_base).to eq('https://example.test')
    expect(provider.headers).to eq('Authorization' => 'Bearer test-key')
  end

  it 'defaults to the mainland China endpoint' do
    config.qiniu_api_base = nil
    expect(provider.api_base).to eq('https://api.qnaigc.com')
  end

  it 'uses the configured base URL verbatim' do
    config.qiniu_api_base = 'https://api.modelink.ai/v1'
    expect(provider.api_base).to eq('https://api.modelink.ai/v1')
  end

  describe 'protocol paths' do
    let(:model) { RubyLLM::Model.new(id: 'deepseek-v3', provider: :qiniu) }

    def url_for(protocol_name, seam, model: self.model)
      described_class.protocols[protocol_name].new(provider, model).send(seam)
    end

    it 'serves the OpenAI-compatible dialect under /v1' do
      expect(url_for(:chat_completions, :completion_url)).to eq('v1/chat/completions')
      expect(url_for(:chat_completions, :models_url)).to eq('v1/models')
    end

    it 'serves Anthropic-compatible messages at /v1/messages' do
      expect(url_for(:anthropic, :completion_url)).to eq('v1/messages')
    end

    it 'serves native bypass endpoints under /bypass' do
      expect(url_for(:anthropic_bypass, :completion_url)).to eq('bypass/anthropic/v1/messages')
      expect(url_for(:responses, :completion_url)).to eq('bypass/openai/v1/responses')

      gemini = RubyLLM::Model.new(id: 'gemini-3.1-pro-preview', provider: :qiniu)
      expect(url_for(:gemini_bypass, :completion_url, model: gemini))
        .to eq('bypass/vertex/v1/models/gemini-3.1-pro-preview:generateContent')
      expect(url_for(:gemini_bypass, :stream_url, model: gemini))
        .to eq('bypass/vertex/v1/models/gemini-3.1-pro-preview:streamGenerateContent?alt=sse')
    end
  end

  describe 'protocol routing' do
    it 'prefers the vendor-native bypass channel for chat' do
      {
        'claude-4.6-sonnet' => :anthropic_bypass,
        'anthropic/claude-4.5-haiku' => :anthropic_bypass,
        'gemini-3.1-pro-preview' => :gemini_bypass,
        'gpt-5.2' => :responses,
        'openai/o4-mini' => :responses
      }.each do |model_id, protocol|
        model = RubyLLM::Model.new(id: model_id, provider: :qiniu)
        expect(provider.protocol_for(model)).to(
          eq(described_class.protocols[protocol]), "#{model_id} should route to #{protocol}"
        )
      end
    end

    it 'keeps other models on the OpenAI-compatible dialect' do
      other = RubyLLM::Model.new(id: 'deepseek-v3', provider: :qiniu)
      expect(provider.protocol_for(other)).to eq(described_class.protocols[:chat_completions])
    end

    it 'keeps auxiliary operations on the compatible layout' do
      gemini = RubyLLM::Model.new(id: 'gemini-3.1-pro-preview', provider: :qiniu)
      %i[embed paint speak transcribe animate].each do |operation|
        expect(provider.protocol_for(gemini, operation:))
          .to eq(described_class.protocols[:chat_completions])
      end
    end
  end
end
