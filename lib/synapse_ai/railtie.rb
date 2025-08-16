# frozen_string_literal: true

require "rails/railtie"

module SynapseAi
  class Railtie < Rails::Railtie
    config.before_configuration do
      # left empty for now
    end

    config.after_initialize do
      if SynapseAi.configuration.provider == :openai && SynapseAi.configuration.openai_api_key.nil?
        Rails.logger.warn "[SynapseAI] OpenAI provider selected, but OPENAI_API_KEY is not set. " \
                          "SynapseAI may not function correctly."
      end
    end

    generators do
      require_relative "../generators/synapse_ai/install/install_generator" # Adjusted path
    end
  end
end
