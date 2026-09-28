# ruby_llm-providers-qiniu (modelink)

RubyLLM provider gem for Qiniu's model gateway (documented at
[docs.modelink.ai](https://docs.modelink.ai) — Modelink is the overseas
brand of the same service).

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

## Endpoints

Pick one regional entry point per deployment; all of them serve the same
protocols:

| Region | Base URL | Use when |
| ------ | -------- | -------- |
| Mainland China | `https://api.qnaigc.com` | default; lowest latency for China deployments |
| Overseas | `https://api.modelink.ai` | overseas deployment or cross-border access |
| Hybrid | `https://xapi.qnaigc.com` | sharing one entry across protocol-different clients |

`qiniu_api_base` is used verbatim — pass the bare host, since each protocol
path already carries its own version segment (`/v1`, `/bypass/…/v1`, …).

## Protocols

One provider, several wire formats. For chat, RubyLLM prefers each vendor's
native bypass channel — Claude models use Anthropic Messages, Gemini models
use GenerateContent, GPT models use Responses — while every other model and
all auxiliary operations use the OpenAI-compatible endpoint. Override
globally with `config.qiniu_protocol = :anthropic` or per call:

```ruby
RubyLLM.chat(model: 'deepseek-v3', provider: :qiniu, protocol: :chat_completions)
```

| Protocol | Path | Notes |
| -------- | ---- | ----- |
| `:chat_completions` (default) | `POST /v1/chat/completions` | All models; also serves model listing at `GET /v1/models` |
| `:anthropic` | `POST /v1/messages` | Anthropic Messages compat; accepts every model, gateway adapts per channel |
| `:anthropic_bypass` | `POST /bypass/anthropic/v1/messages` | Claude only; vendor-native Messages semantics |
| `:gemini_bypass` | `POST /bypass/vertex/v1/models/{model}:{func}` | Gemini only; native GenerateContent (generateContent / streamGenerateContent) |
| `:responses` | `POST /bypass/openai/v1/responses` | GPT family; OpenAI Responses API |

Only chat is wired up for now — embeddings, images, audio, video, rerank
and other capabilities raise `RubyLLM::Error` until the corresponding
endpoints are added.

Prefer the compatible dialects for unified multi-model access. Reach for a
bypass protocol when you depend on vendor-native fields, streaming events,
or extended capabilities (Extended Thinking, Prompt Caching, Gemini-native
tools, Responses). Bypass requests still pass through the gateway's auth,
routing, rate limiting, and billing — "bypass" only skips the unified
protocol conversion.

Authentication is `Authorization: Bearer <api_key>` everywhere (the
Anthropic paths also accept `X-Api-Key`; Bearer alone is sufficient).

## Usage

```ruby
model = RubyLLM.models.by_provider(:qiniu).chat_models.first
chat = RubyLLM.chat(model: model.id)
response = chat.ask('Hello')
puts response.content
```

## Notes

- `GET /v1/models` may be called anonymously; the provider still sends
  credentials when configured. The listing is only a partial catalog — it
  omits whole vendors such as Claude, Gemini and GPT and exposes no
  capabilities or pricing — which is why `models.json` is maintained by
  hand from the official docs.
- Batch inference (`/v1/batchjob/inference`), FAL-format async media
  (`/queue/...`), AK/SK management endpoints, and Volcengine asset signing
  are service-specific APIs this provider does not wrap.
- The hybrid endpoint converts between protocols but may not preserve every
  vendor-native field or streaming event; verify tool calls, thinking,
  caching, structured output, and multimodal inputs with real requests
  before production use.

## Development

The generator installs the bundle and creates an ignored `.env`. Edit the generated `op read` reference so it points to your 1Password credential. If you do not use the 1Password CLI, replace the expression with the provider key.

```sh
bundle exec rake
```

The packaged `models.json` at the gem root is maintained by hand from the official catalog at [modelink.ai/models](https://modelink.ai/models) — `GET /v1/models` is too thin to generate it, since the listing omits whole vendors (no Claude, Gemini or GPT entries) and carries no context windows, capabilities or pricing. RubyLLM loads that catalog as a fallback when this provider is registered, so applications do not need to combine registry files. The main RubyLLM registry always wins when both catalogs carry the same model. If the API grows a richer listing path, update `models_url` in `lib/ruby_llm/providers/qiniu.rb`.

Edit `models.json` directly when you want to update the packaged catalog. `RubyLLM.models.refresh` updates the application's main registry and does not refresh provider gem catalogs.

If the packaged catalog is ever dropped, uncomment `assume_models_exist?` in the provider so chats can start against unlisted models.

The suite always runs the provider integration specs. The first local run calls the API and records VCR cassettes; CI only replays committed cassettes. A failing example deletes its cassette so the next local run tests the live API again.

After updating the catalog, add real model IDs to `spec/support/models.rb`. Keep only the operation matrices the provider supports. The portable contract specs are adapted from [RubyLLM's live specs](https://github.com/crmne/ruby_llm/tree/main/spec/ruby_llm); use those as the reference when your provider needs coverage for another feature or dialect.
