# frozen_string_literal: true

require 'ruby_llm'

module RubyLLM
  module Providers
    # Qiniu API integration (documented at https://docs.modelink.ai —
    # Modelink is the overseas brand of the same gateway).
    #
    # The gateway serves several access styles on the same regional host:
    #
    # - OpenAI Chat Completions compatible API under /v1 (chat and model
    #   listing)
    # - Anthropic Messages compatible API at /v1/messages, which accepts
    #   every chat model and lets the gateway adapt per-channel
    # - Native protocol bypass endpoints that keep vendor-native wire
    #   formats: /bypass/anthropic (Claude only), /bypass/vertex (Gemini),
    #   /bypass/openai (Responses and Images)
    #
    # All regional endpoints speak the same protocols; pick one with
    # qiniu_api_base:
    #
    # - https://api.qnaigc.com   — mainland China (default)
    # - https://api.modelink.ai  — overseas
    # - https://xapi.qnaigc.com  — hybrid multi-protocol entry
    class Qiniu < Provider
      # OpenAI Chat Completions-compatible dialect under /v1. This is the
      # default protocol and the only one used for model listing.
      class ChatCompletions < Protocols::ChatCompletions
        private

        def completion_url
          'v1/chat/completions'
        end

        def models_url
          'v1/models'
        end
      end

      # OpenAI Responses native bypass at /bypass/openai/v1/responses for
      # GPT-family models. count_tokens_url and compaction_url derive from
      # completion_url.
      class ResponsesBypass < Protocols::Responses
        private

        def completion_url
          'bypass/openai/v1/responses'
        end
      end

      # Anthropic native bypass at /bypass/anthropic/v1/messages. Claude
      # models only; request and streaming events stay vendor-native.
      class AnthropicBypass < Protocols::Anthropic
        private

        def completion_url
          'bypass/anthropic/v1/messages'
        end

        def count_tokens_url
          'bypass/anthropic/v1/messages/count_tokens'
        end
      end

      # Vertex/Gemini native bypass at /bypass/vertex/v1/models/{m}:{func}.
      # Gemini models only; keeps the GenerateContent wire format.
      class GeminiBypass < Protocols::Gemini
        private

        def completion_url
          vertex_url(super)
        end

        def stream_url
          vertex_url(super)
        end

        def count_tokens_url
          vertex_url(super)
        end

        def vertex_url(path)
          "bypass/vertex/v1/#{path}"
        end
      end

      protocol :chat_completions, ChatCompletions
      protocol :anthropic, Protocols::Anthropic
      protocol :responses, ResponsesBypass
      protocol :anthropic_bypass, AnthropicBypass
      protocol :gemini_bypass, GeminiBypass

      def api_base
        @config.qiniu_api_base || 'https://api.qnaigc.com'
      end

      def headers
        { 'Authorization' => "Bearer #{@config.qiniu_api_key}" }
      end

      # Chat prefers each vendor's native bypass channel — Claude via
      # Anthropic Messages, Gemini via GenerateContent, GPT via Responses —
      # and everything else uses the OpenAI-compatible endpoint. Auxiliary
      # operations (embeddings, images, audio, …) only exist on the
      # compatible layout. Override globally with config.qiniu_protocol or
      # per call with protocol: (e.g. :anthropic for the Messages compat
      # layer, :chat_completions to force the compatible dialect).
      def protocol_for(model, operation: nil, **)
        return super if operation

        case model_id_for(model).to_s
        when /claude/i then protocols[:anthropic_bypass]
        when /gemini/i then protocols[:gemini_bypass]
        when %r{(?:\A|/)(?:gpt|o\d)}i then protocols[:responses]
        else super
        end
      end

      class << self
        def configuration_options
          %i[qiniu_api_key qiniu_api_base]
        end

        def configuration_requirements
          %i[qiniu_api_key]
        end
      end
    end
  end
end

RubyLLM::Provider.register :qiniu, RubyLLM::Providers::Qiniu,
                           models: File.expand_path('../../../models.json', __dir__)
