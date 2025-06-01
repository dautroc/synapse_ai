# frozen_string_literal: true

require_relative "synapse_ai/version"
require_relative "synapse_ai/configuration"
require_relative "synapse_ai/response"
require_relative "synapse_ai/providers/base"
require_relative "synapse_ai/providers/openai_adapter"
require_relative "synapse_ai/providers/google_gemini_adapter"
# Add other providers here as they are created, e.g.:
# require_relative "synapse_ai/providers/google_adapter"

require_relative "synapse_ai/railtie" if defined?(Rails::Railtie)
require "zeitwerk"
loader = Zeitwerk::Loader.for_gem
loader.ignore("#{__dir__}/generators")
loader.setup

# Main module for the SynapseAI gem.
# Provides top-level methods for configuration and interaction with AI providers.
module SynapseAi
  class Error < StandardError; end
  class ConfigurationError < Error; end
  class ProviderError < Error; end

  class << self
    attr_writer :configuration

    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration)
    end

    # Determines and returns the current AI provider instance based on configuration.
    # It prioritizes the `requested_provider` if provided, otherwise uses the configured default.
    # Raises a `ConfigurationError` if the selected provider is not implemented or if its API key is missing.
    def current_provider(requested_provider = nil)
      provider_key = requested_provider || configuration.provider

      case provider_key
      when :openai
        api_key_to_use = configuration.openai_api_key
        Providers::OpenAIAdapter.new(api_key: api_key_to_use)
      when :google_gemini
        raise ConfigurationError, "Google Gemini provider not yet fully implemented."
      else
        raise ConfigurationError, "Unsupported AI provider: #{provider_key}"
      end
    rescue ArgumentError => e # Catches API key missing from adapter constructor
      raise ConfigurationError, "API key not configured for #{provider_key}: #{e.message}"
    end

    # Delegates the chat request to the current or specified provider.
    #
    # @param messages [Array<Hash>] A list of message objects.
    # @param options [Hash] Additional options for the provider.
    # @option options [Symbol] :provider Override the default provider for this call.
    # @return [SynapseAi::Response] The response from the AI provider.
    def chat(messages:, **options)
      provider_override = options.delete(:provider)
      current_provider(provider_override).chat(messages: messages, **options)
    rescue StandardError => e
      Response.new(success: false, error_message: e.message, raw_response: e)
    end

    # Delegates the text generation request to the current or specified provider.
    #
    # @param prompt [String] The prompt for text generation.
    # @param options [Hash] Additional options for the provider.
    # @option options [Symbol] :provider Override the default provider for this call.
    # @return [SynapseAi::Response] The response from the AI provider.
    def generate_text(prompt:, **options)
      provider_override = options.delete(:provider)
      current_provider(provider_override).generate_text(prompt: prompt, **options)
    rescue StandardError => e
      Response.new(success: false, error_message: e.message, raw_response: e)
    end

    # Delegates the embedding request to the current or specified provider.
    #
    # @param text [String] The text to embed.
    # @param options [Hash] Additional options for the provider.
    # @option options [Symbol] :provider Override the default provider for this call.
    # @return [SynapseAi::Response] The response from the AI provider.
    def embed(text:, **options)
      provider_override = options.delete(:provider)
      current_provider(provider_override).embed(text: text, **options)
    rescue StandardError => e
      Response.new(success: false, error_message: e.message, raw_response: e)
    end
  end
end
