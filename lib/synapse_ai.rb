# frozen_string_literal: true

require_relative "synapse_ai/version"
require_relative "synapse_ai/configuration"
require_relative "synapse_ai/response"
require_relative "synapse_ai/providers/base"
require_relative "synapse_ai/providers/openai_adapter"

require_relative "synapse_ai/railtie" if defined?(Rails::Railtie)
require "zeitwerk"
loader = Zeitwerk::Loader.for_gem
loader.ignore("#{__dir__}/generators")
loader.setup

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

    def current_provider(requested_provider = nil)
      provider_key = requested_provider || configuration.provider

      case provider_key
      when :openai
        Providers::OpenAIAdapter.new(api_key: configuration.openai_api_key)
      else
        raise ConfigurationError, "Unsupported AI provider: #{provider_key}. Only :openai is supported."
      end
    rescue ArgumentError => e
      raise ConfigurationError, "API key not configured for #{provider_key}: #{e.message}"
    end

    def chat(messages:, **options)
      provider_override = options.delete(:provider)
      current_provider(provider_override).chat(messages: messages, **options)
    rescue StandardError => e
      Response.new(success: false, error_message: e.message, raw_response: e)
    end

    def generate_text(prompt:, **options)
      provider_override = options.delete(:provider)
      current_provider(provider_override).generate_text(prompt: prompt, **options)
    rescue StandardError => e
      Response.new(success: false, error_message: e.message, raw_response: e)
    end

    def embed(text:, **options)
      provider_override = options.delete(:provider)
      current_provider(provider_override).embed(text: text, **options)
    rescue StandardError => e
      Response.new(success: false, error_message: e.message, raw_response: e)
    end
  end
end
