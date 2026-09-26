# frozen_string_literal: true

require 'ruby_llm'

module RubyLLM
  module Providers
    # Qiniu API integration.
    class Qiniu < Provider
      # Qiniu's ChatCompletions protocol.
      class ChatCompletions < Protocols::ChatCompletions
        def models_url
          'models'
        end
      end

      protocol :chat_completions, ChatCompletions

      def api_base
        @config.qiniu_api_base || 'https://api.qnaigc.com'
      end

      def headers
        { 'Authorization' => "Bearer #{@config.qiniu_api_key}" }
      end

      class << self
        def configuration_options
          %i[qiniu_api_key qiniu_api_base]
        end

        def configuration_requirements
          %i[qiniu_api_key]
        end

        # Use this only when the provider has no model-listing endpoint.
        # def assume_models_exist?
        #   true
        # end
      end
    end
  end
end

RubyLLM::Provider.register :qiniu, RubyLLM::Providers::Qiniu,
                           models: File.expand_path('../../../models.json', __dir__)
