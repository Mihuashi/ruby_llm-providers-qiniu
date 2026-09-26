# frozen_string_literal: true

RSpec.shared_context 'with configured RubyLLM' do
  before do
    RubyLLM.configure do |config|
      config.qiniu_api_key = ENV.fetch('QINIU_API_KEY', 'test')
      config.qiniu_api_base = ENV.fetch('QINIU_BASE_URL', 'https://api.qnaigc.com')
      config.max_retries = 0
      config.retry_backoff_factor = 0
      config.retry_interval = 0
      config.retry_interval_randomness = 0
    end
  end
end
