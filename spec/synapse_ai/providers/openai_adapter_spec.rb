# frozen_string_literal: true

require "spec_helper"

RSpec.describe SynapseAi::Providers::OpenAIAdapter, :vcr do
  let(:api_key) { ENV.fetch("OPENAI_API_KEY", "test_api_key_not_set") }
  let(:valid_messages) { [{ role: "user", content: "Hello, world!" }] }
  let(:valid_prompt) { "Translate 'hello' to Spanish." }

  describe "#initialize" do
    context "with a valid API key" do
      it "initializes without error" do
        expect { described_class.new(api_key: api_key) }.not_to raise_error
      end
    end

    context "without an API key" do
      it "raises an ArgumentError if api_key is nil" do
        expect { described_class.new(api_key: nil) }.to raise_error(ArgumentError, /OpenAI API key is required/)
      end

      it "raises an ArgumentError if api_key is empty" do
        expect { described_class.new(api_key: "") }.to raise_error(ArgumentError, /OpenAI API key is required/)
      end
    end
  end

  describe "#chat", :vcr do
    subject(:adapter) { described_class.new(api_key: api_key) }

    context "with valid parameters" do
      it "returns a successful response with content" do
        response = adapter.chat(messages: valid_messages)
        expect(response).to be_a(SynapseAi::Response)
        expect(response).to be_success
        expect(response.content).not_to be_empty
        expect(response.token_usage).to include("prompt_tokens", "completion_tokens", "total_tokens")
      end
    end

    context "with an invalid API key (simulated by VCR)" do
      # This cassette spec/fixtures/vcr_cassettes/openai_chat_failure_invalid_key.yml
      # should be manually edited after first recording to represent an authentication error
      # if the live call with "sk-invalidkey123" doesn't produce the expected error naturally.
      it "returns an error response", vcr: { cassette_name: "openai_chat_failure_invalid_key" } do
        # Use a known bad key for recording this specific test, then VCR takes over.
        # Note: The actual error message from OpenAI might vary slightly.
        bad_key_adapter = described_class.new(api_key: "sk-invalidkey123")
        response = bad_key_adapter.chat(messages: valid_messages)
        expect(response).to be_a(SynapseAi::Response)
        expect(response).to be_failure
        expect(response.error).to match(/server responded with status 401|Incorrect API key|Invalid API key/i)
      end
    end
  end

  describe "#generate_text", :vcr do
    subject(:adapter) { described_class.new(api_key: api_key) }

    context "with valid parameters (using chat model by default)" do
      it "returns a successful response with content" do
        response = adapter.generate_text(prompt: valid_prompt)
        expect(response).to be_a(SynapseAi::Response)
        expect(response).to be_success
        expect(response.content).not_to be_empty
        expect(response.token_usage).to include("prompt_tokens", "completion_tokens", "total_tokens")
      end
    end

    # Example for testing a legacy completion model if ever needed
    # context "with a legacy completion model", vcr: { cassette_name: 'openai_generate_text_legacy' } do
    #   it "returns a successful response using the completions endpoint"
    #     response = adapter.generate_text(prompt: "Once upon a time", model: "text-ada-001", max_tokens: 5)
    #     expect(response).to be_success
    #     expect(response.content).not_to be_empty
    #   end
    # end
  end

  # TODO: Add tests for other methods like #embed, #generate_image when implemented
  # TODO: Add tests for specific error types (network errors, rate limits, etc.)
end
