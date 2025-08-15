# frozen_string_literal: true

module SynapseAi
  class Response
    attr_reader :success, :content, :error_message, :raw_response, :token_usage

    def initialize(success:, content: nil, error_message: nil, raw_response: nil, token_usage: {})
      @success = success
      @content = content
      @error_message = error_message
      @raw_response = raw_response
      @token_usage = token_usage
    end

    def success?
      success
    end

    def failure?
      !success
    end
  end
end
