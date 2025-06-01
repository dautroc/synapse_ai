# frozen_string_literal: true

# This class represents a response from the AI provider.
# It contains the content, error, token usage, raw response, and status of the response.
# It also provides methods to check if the response is successful or failed.
module SynapseAi
  # Represents a standardized response from an AI provider.
  # Encapsulates success status, content, error messages, token usage, and the raw response.
  class Response
    attr_reader :success, :content, :error_message, :raw_response, :token_usage

    # Initializes a new Response object.
    #
    # @param success [Boolean] Indicates if the operation was successful.
    # @param content [Object] The primary content of the response (e.g., text, embedding vector).
    # @param error_message [String] An error message if the operation failed.
    # @param raw_response [Object] The original, unprocessed response from the AI provider.
    # @param token_usage [Hash] Details token usage (e.g., { prompt_tokens: X, ... }).
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
