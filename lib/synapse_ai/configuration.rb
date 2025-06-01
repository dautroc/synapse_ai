# frozen_string_literal: true

# This class represents the configuration for the Synapse AI gem.
# It contains the provider, API key, log level, and default timeout.
# It also provides a method to configure the gem.
module SynapseAi
  # Holds configuration settings for the SynapseAI gem.
  class Configuration
    # Specifies the default AI provider to use (e.g., :openai, :google_gemini).
    attr_accessor :provider, :openai_api_key, :google_gemini_api_key, :log_level, :default_timeout

    # Initializes a new Configuration object.
    #
    # @param provider [Symbol] The provider to use for AI interactions.
    # @param openai_api_key [String] The API key for the OpenAI provider.
    # @param google_gemini_api_key [String] The API key for the Google Gemini provider.
    # @param log_level [Symbol] The log level to use for logging.
    def initialize
      @provider = :openai # Default provider
      @openai_api_key = ENV.fetch("OPENAI_API_KEY", nil)
      @google_gemini_api_key = ENV.fetch("GOOGLE_GEMINI_API_KEY", nil)

      @log_level = :info
      @default_timeout = 60 # seconds
    end
  end

  class << self
    attr_writer :configuration

    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration)
    end
  end
end
