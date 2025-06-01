# frozen_string_literal: true

require "spec_helper"

RSpec.describe SynapseAi do
  it "has a version number" do
    expect(SynapseAi::VERSION).not_to be_nil
  end

  describe ".configure" do
    it "yields the configuration object" do
      expect { |b| SynapseAi.configure(&b) }.to yield_with_args(SynapseAi.configuration)
    end

    it "allows setting configuration values" do
      SynapseAi.configure do |config|
        config.provider = :test_provider
        config.openai_api_key = "test_key"
        config.log_level = :debug
      end
      expect(SynapseAi.configuration.provider).to eq(:test_provider)
      expect(SynapseAi.configuration.openai_api_key).to eq("test_key")
      expect(SynapseAi.configuration.log_level).to eq(:debug)

      # Reset to defaults for other tests
      SynapseAi.instance_variable_set(:@configuration, nil)
    end
  end

  describe ".current_provider" do
    let(:mock_openai_adapter_instance) { instance_double(SynapseAi::Providers::OpenAIAdapter) }

    before do
      # Ensure a clean state for configuration for each .current_provider context
      SynapseAi.instance_variable_set(:@configuration, nil)
    end

    context "when provider is :openai (default)" do
      before do
        allow(SynapseAi::Providers::OpenAIAdapter).to receive(:new).and_return(mock_openai_adapter_instance)
      end

      it "returns an instance of OpenAIAdapter" do
        SynapseAi.configure { |c| c.openai_api_key = "fake_key" }
        expect(SynapseAi.current_provider).to eq(mock_openai_adapter_instance)
        expect(SynapseAi::Providers::OpenAIAdapter).to have_received(:new).with(api_key: "fake_key")
      end
    end

    context "when a different provider is configured (but not yet implemented)" do
      it "raises a ConfigurationError" do
        SynapseAi.configure { |c| c.provider = :google }
        expect do
          SynapseAi.current_provider
        end.to raise_error(SynapseAi::ConfigurationError, /Unsupported AI provider: google/)
      end
    end

    context "when an unsupported provider is configured" do
      it "raises a ConfigurationError" do
        SynapseAi.configure { |c| c.provider = :unsupported_foo_provider }
        expect do
          SynapseAi.current_provider
        end.to raise_error(SynapseAi::ConfigurationError, /Unsupported AI provider: unsupported_foo_provider/)
      end
    end

    context "when API key is not configured for the selected provider" do
      it "raises a ConfigurationError because the adapter raises ArgumentError" do
        SynapseAi.configure { |c| c.openai_api_key = nil } # Explicitly set to nil
        expect do
          SynapseAi.current_provider
        end.to raise_error(SynapseAi::ConfigurationError, /OpenAI API key is required/)
      end
    end
  end

  describe ".chat" do
    let(:mock_provider) { instance_double(SynapseAi::Providers::OpenAIAdapter) }
    let(:messages) { [{ role: "user", content: "Hi" }] }
    let(:expected_response) { SynapseAi::Response.new(success: true, content: "Hello there") }

    before do
      SynapseAi.instance_variable_set(:@configuration, nil)
      SynapseAi.configure { |c| c.openai_api_key = "fake_key" }
      allow(SynapseAi).to receive(:current_provider).and_return(mock_provider)
      allow(mock_provider).to receive(:chat).and_return(expected_response)
    end

    it "delegates to the current provider's chat method" do
      response = SynapseAi.chat(messages: messages, model: "test-model")
      expect(mock_provider).to have_received(:chat).with(messages: messages, model: "test-model")
      expect(response).to eq(expected_response)
    end

    it "allows overriding the provider for a specific call" do
      mock_other_provider = instance_double(SynapseAi::Providers::OpenAIAdapter, chat: expected_response)
      allow(SynapseAi).to receive(:current_provider).with(:other_provider).and_return(mock_other_provider)

      SynapseAi.chat(messages: messages, provider: :other_provider)
      expect(mock_other_provider).to have_received(:chat).with(messages: messages)
    end

    it "rescues standard errors and returns a failure response" do
      allow(mock_provider).to receive(:chat).and_raise(StandardError, "Something went wrong")
      response = SynapseAi.chat(messages: messages)
      expect(response).to be_failure
      expect(response.error_message).to eq("Something went wrong")
    end
  end

  describe ".generate_text" do
    let(:mock_provider) { instance_double(SynapseAi::Providers::OpenAIAdapter) }
    let(:prompt) { "Summarize this" }
    let(:expected_response) { SynapseAi::Response.new(success: true, content: "Summary.") }

    before do
      SynapseAi.instance_variable_set(:@configuration, nil)
      SynapseAi.configure { |c| c.openai_api_key = "fake_key" }
      allow(SynapseAi).to receive(:current_provider).and_return(mock_provider)
      allow(mock_provider).to receive(:generate_text).and_return(expected_response)
    end

    it "delegates to the current provider's generate_text method" do
      response = SynapseAi.generate_text(prompt: prompt, model: "test-model")
      expect(mock_provider).to have_received(:generate_text).with(prompt: prompt, model: "test-model")
      expect(response).to eq(expected_response)
    end

    it "rescues standard errors and returns a failure response" do
      allow(mock_provider).to receive(:generate_text).and_raise(StandardError, "Text gen went wrong")
      response = SynapseAi.generate_text(prompt: prompt)
      expect(response).to be_failure
      expect(response.error_message).to eq("Text gen went wrong")
    end
  end

  describe ".embed" do
    let(:mock_provider) { instance_double(SynapseAi::Providers::OpenAIAdapter) }
    let(:text_to_embed) { "Embed this!" }
    let(:embedding_vector) { [0.1, 0.2, 0.3] }
    let(:expected_response) { SynapseAi::Response.new(success: true, content: embedding_vector) }

    before do
      SynapseAi.instance_variable_set(:@configuration, nil) # Reset config
      SynapseAi.configure { |c| c.openai_api_key = "fake_key" }
      allow(SynapseAi).to receive(:current_provider).and_return(mock_provider)
      allow(mock_provider).to receive(:embed).and_return(expected_response)
    end

    it "delegates to the current provider's embed method" do
      response = SynapseAi.embed(text: text_to_embed, model: "text-embedding-3-small")
      expect(mock_provider).to have_received(:embed).with(text: text_to_embed, model: "text-embedding-3-small")
      expect(response).to eq(expected_response)
      expect(response.content).to eq(embedding_vector)
    end

    it "rescues standard errors and returns a failure response" do
      allow(mock_provider).to receive(:embed).and_raise(StandardError, "Embedding went wrong")
      response = SynapseAi.embed(text: text_to_embed)
      expect(response).to be_failure
      expect(response.error_message).to eq("Embedding went wrong")
    end
  end
end
