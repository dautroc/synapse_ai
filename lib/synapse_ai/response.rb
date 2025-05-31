# frozen_string_literal: true

# This class represents a response from the AI provider.
# It contains the content, error, token usage, raw response, and status of the response.
# It also provides methods to check if the response is successful or failed.
module SynapseAi
  class Response
    attr_reader :content, :error, :token_usage, :raw_response, :status

    # Initializes a new Response object.
    #
    # @param content [Object] The primary content of the response.
    # @param error [String, StandardError] Any error message or object.
    # @param token_usage [Hash] A hash detailing token usage (e.g., { prompt_tokens: X, completion_tokens: Y, total_tokens: Z }).
    # @param raw_response [Object] The original, unaltered response from the AI provider.
    # @param status [Symbol] The status of the response (:success, :error, :partial_success).
    def initialize(content: nil, error: nil, token_usage: {}, raw_response: nil, status: :error)
      @content = content
      @error = error
      @token_usage = token_usage
      @raw_response = raw_response
      @status = status
    end

    def success?
      status == :success
    end

    def failure?
      status == :error || !error.nil?
    end
  end
end
