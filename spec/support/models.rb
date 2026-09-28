# frozen_string_literal: true

# Remove chat-derived matrices the model does not support and add real ids for the empty operation matrices.
# See RubyLLM's full live matrix and specs: https://github.com/crmne/ruby_llm/tree/main/spec
PROVIDER = :qiniu
CHAT_MODELS = [
  { provider: PROVIDER, model: 'anthropic/claude-sonnet-5' },
  { provider: PROVIDER, model: 'gemini-3.1-flash-lite-preview' },
  { provider: PROVIDER, model: 'google/gemini-3.1-flash-lite' },
  { provider: PROVIDER, model: 'google/gemini-3.8-flash' },
  { provider: PROVIDER, model: 'openai/gpt-5.2' },
  { provider: PROVIDER, model: 'openai/gpt-5.4' },
  { provider: PROVIDER, model: 'openai/gpt-5.4-mini' },
  { provider: PROVIDER, model: 'deepseek/deepseek-v4.1-flash' }
].freeze
TOOL_MODELS = CHAT_MODELS
STRUCTURED_OUTPUT_MODELS = CHAT_MODELS

EMBEDDING_MODELS = [].freeze
IMAGE_GENERATION_MODELS = [].freeze
SPEECH_MODELS = [].freeze
VIDEO_GENERATION_MODELS = [].freeze
MODERATION_MODELS = [].freeze
RERANK_MODELS = [].freeze

def each_model(models)
  models.each { |model_info| yield model_info[:provider], model_info[:model], model_info }
end
