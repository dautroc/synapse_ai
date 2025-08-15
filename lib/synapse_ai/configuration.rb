# frozen_string_literal: true

module SynapseAi
  class Configuration
    attr_accessor :provider, :openai_api_key, :log_level, :default_timeout

    def initialize
      @provider = :openai
      @openai_api_key = ENV.fetch("OPENAI_API_KEY", nil)

      @log_level = :info
      @default_timeout = 60
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
