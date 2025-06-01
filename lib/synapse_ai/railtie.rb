# frozen_string_literal: true

require "rails/railtie"
require_relative "synapse_ai"

module SynapseAi
  class Railtie < Rails::Railtie
    # Allows configuration of SynapseAI through Rails application's initializers
    # Example: config/initializers/synapse_ai.rb
    #
    #   SynapseAi.configure do |config|
    #     config.openai_api_key = ENV["OPENAI_API_KEY"]
    #     # config.provider = :google # if you want to change default
    #     # config.log_level = :debug
    #   end
    config.before_configuration do
      # You can set up default configurations here if needed before app initializers run
    end

    # Initializers to run after the main application initializers
    # initializer "synapse_ai.configure_ Fokus Ai_client" do |app|
    #   # Code here would run after the application's initializers
    #   # For example, to verify configuration or set up other components.
    #   # if SynapseAi.configuration.openai_api_key.blank? && SynapseAi.configuration.provider == :openai
    #   #   Rails.logger.warn "SynapseAI: OpenAI API key is not set. OpenAI provider may not function."
    #   # end
    # end

    config.after_initialize do
      if SynapseAi.configuration.provider == :openai &&
         (SynapseAi.configuration.openai_api_key.nil? || SynapseAi.configuration.openai_api_key.empty?)
        Rails.logger.warn "[SynapseAI] OpenAI provider is selected, but OPENAI_API_KEY is not configured. SynapseAI may not function correctly."
      end
      # Add checks for other providers as they are implemented
      # if SynapseAi.configuration.provider == :google && SynapseAi.configuration.google_api_key.blank?
      #   Rails.logger.warn "[SynapseAI] Google provider is selected, but GOOGLE_API_KEY is not configured."
      # end
    end

    # You could also add generators or rake tasks here if needed
    generators do
      require_relative "../generators/synapse_ai/install/install_generator" # Adjusted path
    end
  end
end
