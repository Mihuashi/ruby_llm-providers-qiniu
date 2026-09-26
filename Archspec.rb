# frozen_string_literal: true

source 'lib/**/*.rb'

component :provider,
          in: %w[
            lib/ruby_llm/providers/qiniu.rb
            lib/ruby_llm/providers/qiniu/**/*.rb
          ],
          namespace: 'RubyLLM::Providers::Qiniu'

provider.cannot_reference_constants 'RSpec', 'WebMock', 'VCR'

preset :ruby_conventions
