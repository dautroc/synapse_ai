# frozen_string_literal: true

SynapseAi.configure do |config|
  # ==> AI Provider Configuration
  # Specify the default AI provider. Supported: :openai, :google_gemini
  # config.provider = :openai

  # ==> API Keys
  # Provide API keys for the services you want to use.
  # It's highly recommended to use Rails credentials or environment variables.
  config.openai_api_key = ENV["OPENAI_API_KEY"]
  config.google_gemini_api_key = ENV["GOOGLE_GEMINI_API_KEY"]

  # ==> Logging
  # Set the log level for SynapseAI operations. Options: :debug, :info, :warn, :error, :fatal
  # config.log_level = :info

  # ==> Timeouts
  # Configure the default timeout for API requests (in seconds).
  # config.default_timeout = 60

  # ==> Other Provider Specific Settings (Example)
  # if config.provider == :some_other_provider
  #   config.some_other_provider_setting = "value"
  # end
end
