# frozen_string_literal: true

VCR.configure do |config|
  config.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  config.hook_into :webmock
  config.default_cassette_options = { record: ENV['CI'] ? :none : :once }
  config.allow_http_connections_when_no_cassette = true
  config.filter_sensitive_data('<QINIU_API_KEY>') { ENV.fetch('QINIU_API_KEY', nil) }
  config.filter_sensitive_data('<QINIU_BASE_URL>') { ENV.fetch('QINIU_BASE_URL', 'https://api.qnaigc.com') }

  config.before_record do |interaction|
    next unless interaction.request.headers['Authorization']

    interaction.request.headers['Authorization'] = ['Bearer <AUTH_TOKEN>']
  end
end
