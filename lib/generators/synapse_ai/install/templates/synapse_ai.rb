# frozen_string_literal: true

SynapseAi.configure do |config|
  # ==> AI Provider Configuration
  # Specify the default AI provider. Supported: :openai
  # config.provider = :openai

  # ==> API Keys
  # Provide API keys for the services you want to use.
  # It's highly recommended to use Rails credentials or environment variables.
  config.openai_api_key = ENV.fetch("OPENAI_API_KEY", nil)

  # ==> Logging
  # Set the log level for SynapseAI operations. Options: :debug, :info, :warn, :error, :fatal
  # config.log_level = :info

  # ==> Timeouts
  # Configure the default timeout for API requests (in seconds).
  # config.default_timeout = 60

  # ==> Other Provider Specific Settings
end
