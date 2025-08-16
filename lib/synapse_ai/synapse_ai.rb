# frozen_string_literal: true

require_relative "version"
require_relative "configuration"
require_relative "response"
require_relative "providers/base"
require_relative "providers/openai_adapter"

module SynapseAi
  class Error < StandardError; end

  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration)
    end
  end
end
