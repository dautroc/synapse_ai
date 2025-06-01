# frozen_string_literal: true

require_relative "synapse_ai/version"
require_relative "synapse_ai/configuration"
require_relative "synapse_ai/response"
require_relative "synapse_ai/providers/base"
require_relative "synapse_ai/providers/openai_adapter"
# Add other providers here as they are created, e.g.:
# require_relative "synapse_ai/providers/google_adapter"

require_relative "synapse_ai/railtie" if defined?(Rails::Railtie)

module SynapseAi
  class Error < StandardError; end
  class ConfigurationError < Error; end
  class ProviderError < Error; end

  class << self
    # Provides access to the currently configured provider instance.
    # Raises ConfigurationError if the provider is not configured or supported.
    #
    # @param requested_provider [Symbol, String] The specific provider to use (optional).
    # @return [SynapseAi::Providers::Base] An instance of the AI provider adapter.
    def current_provider(requested_provider = nil)
      provider_name = requested_provider || configuration.provider
      api_key = nil

      case provider_name.to_sym
      when :openai
        api_key = configuration.openai_api_key
        Providers::OpenAIAdapter.new(api_key: api_key)
        # when :google
        # api_key = configuration.google_api_key
        # Providers::GoogleAdapter.new(api_key: api_key) # Example for future
      else
        raise ConfigurationError, "Unsupported AI provider: #{provider_name}"
      end
    rescue ArgumentError => e # Catches API key missing from adapter constructor
      raise ConfigurationError, e.message
    end

    # Generates a chat completion using the configured AI provider.
    #
    # @param messages [Array<Hash>] An array of message objects.
    # @param options [Hash] Provider-specific options.
    # @option options [Symbol, String] :provider Override the default provider for this call.
    # @return [SynapseAi::Response] A standardized response object.
    def chat(messages:, **options)
      provider_override = options.delete(:provider)
      current_provider(provider_override).chat(messages: messages, **options)
    rescue StandardError => e
      SynapseAi::Response.new(error: "SynapseAI.chat failed: #{e.message}", status: :error)
    end

    # Generates text using the configured AI provider.
    #
    # @param prompt [String] The prompt to generate text from.
    # @param options [Hash] Provider-specific options.
    # @option options [Symbol, String] :provider Override the default provider for this call.
    # @return [SynapseAi::Response] A standardized response object.
    def generate_text(prompt:, **options)
      provider_override = options.delete(:provider)
      current_provider(provider_override).generate_text(prompt: prompt, **options)
    rescue StandardError => e
      SynapseAi::Response.new(error: "SynapseAI.generate_text failed: #{e.message}", status: :error)
    end

    # Generates an embedding for the given text using the configured AI provider.
    #
    # @param text [String] The text to embed.
    # @param options [Hash] Provider-specific options.
    # @option options [String] :model The specific embedding model to use.
    # @option options [Symbol, String] :provider Override the default provider for this call.
    # @return [SynapseAi::Response] A standardized response object containing the embedding vector.
    def embed(text:, **options)
      provider_override = options.delete(:provider)
      # model = options.delete(:model) # model is passed through in options if present
      current_provider(provider_override).embed(text: text, **options)
    rescue StandardError => e
      SynapseAi::Response.new(error: "SynapseAI.embed failed: #{e.message}", status: :error)
    end
  end
end
