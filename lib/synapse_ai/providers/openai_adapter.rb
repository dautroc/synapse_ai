# frozen_string_literal: true

require "openai"
require "tiktoken_ruby"

module SynapseAi
  module Providers
    # Adapter for interacting with the OpenAI API.
    # Implements chat, text generation, and embedding functionalities.
    class OpenAIAdapter < Base
      attr_reader :client, :api_key

      # Initializes the OpenAIAdapter.
      #
      # @param api_key [String] The OpenAI API key.
      # @raise [ArgumentError] If the API key is not provided or is empty.
      def initialize(api_key:)
        super()
        raise ArgumentError, "OpenAI API key is required." if api_key.nil? || api_key.empty?

        @api_key = api_key
        @client = OpenAI::Client.new(access_token: api_key)
      end

      # Sends a chat request to the OpenAI API.
      #
      # @param messages [Array<Hash>] A list of message objects (e.g., [{ role: "user", content: "Hello" }]).
      # @param model [String] The model to use (e.g., "gpt-3.5-turbo").
      # @param options [Hash] Additional options to pass to the OpenAI API.
      # @return [SynapseAi::Response] A standardized response object.
      def chat(messages:, model: "gpt-3.5-turbo", **options)
        response_content = nil
        error_message = nil
        raw_response = nil
        token_usage = {}

        begin
          parameters = { model: model, messages: messages }.merge(options)
          raw_response = client.chat(parameters: parameters)

          if raw_response["choices"] && raw_response["choices"].first["message"]["content"]
            response_content = raw_response["choices"].first["message"]["content"]
            token_usage = raw_response["usage"] || {} # Corrected
          else
            error_message = "No content in OpenAI response: #{raw_response}"
          end
        rescue OpenAI::Error => e
          error_message = "OpenAI API Error: #{e.message}"
          raw_response = e.response if e.respond_to?(:response)
        rescue StandardError => e
          error_message = "StandardError during OpenAI chat: #{e.message}"
          raw_response = e
        end

        SynapseAi::Response.new(
          success: error_message.nil?,
          content: response_content,
          error_message: error_message,
          raw_response: raw_response,
          token_usage: {
            prompt_tokens: token_usage["prompt_tokens"],
            completion_tokens: token_usage["completion_tokens"],
            total_tokens: token_usage["total_tokens"]
          }
        )
      end

      # Generates text using the OpenAI API.
      # Supports both completion models and chat models (by adapting the prompt).
      #
      # @param prompt [String] The prompt for text generation.
      # @param model [String] The model to use (e.g., "text-davinci-003" or
      #        "gpt-3.5-turbo"). Defaults to "gpt-3.5-turbo".
      # @param max_tokens [Integer] The maximum number of tokens to generate.
      # @param options [Hash] Additional options to pass to the OpenAI API.
      # @return [SynapseAi::Response] A standardized response object.
      def generate_text(prompt:, model: "gpt-3.5-turbo", max_tokens: 150, **options)
        response_content = nil
        error_message = nil
        raw_response = nil
        token_usage = {}

        begin
          parameters = { model: model }.merge(options)

          if CHAT_MODELS.include?(model)
            # Adapt to chat model if a chat model is specified for generate_text
            chat_messages = [{ role: "user", content: prompt }]
            parameters[:messages] = chat_messages
            parameters[:max_tokens] = max_tokens unless parameters.key?(:max_tokens)
            raw_response = client.chat(parameters: parameters)
            if raw_response["choices"] && raw_response["choices"].first["message"]["content"]
              response_content = raw_response["choices"].first["message"]["content"]
              token_usage = raw_response["usage"] || {} # Corrected
            else
              error_message = "No content in OpenAI chat response (for generate_text): #{raw_response}"
            end
          else
            # Use completions endpoint for non-chat models
            parameters[:prompt] = prompt
            parameters[:max_tokens] = max_tokens unless parameters.key?(:max_tokens)
            raw_response = client.completions(parameters: parameters)
            if raw_response["choices"] && raw_response["choices"].first["text"]
              response_content = raw_response["choices"].first["text"].strip
              token_usage = raw_response["usage"] || {} # Corrected
            else
              error_message = "No content in OpenAI completions response: #{raw_response}"
            end
          end
        rescue OpenAI::Error => e
          error_message = "OpenAI API Error: #{e.message}"
          raw_response = e.response if e.respond_to?(:response)
        rescue StandardError => e
          error_message = "StandardError during OpenAI generate_text: #{e.message}"
          raw_response = e
        end

        SynapseAi::Response.new(
          success: error_message.nil?,
          content: response_content,
          error_message: error_message,
          raw_response: raw_response,
          token_usage: {
            prompt_tokens: token_usage["prompt_tokens"],
            completion_tokens: token_usage["completion_tokens"],
            total_tokens: token_usage["total_tokens"]
          }
        )
      end

      # Creates an embedding for the given text using the OpenAI API.
      #
      # @param text [String] The text to embed.
      # @param model [String] The embedding model to use (e.g., "text-embedding-3-small").
      # @param options [Hash] Additional options to pass to the OpenAI API.
      # @return [SynapseAi::Response] Standardized response. Content is the embedding vector.
      def embed(text:, model: "text-embedding-3-small", **options)
        embedding_vector = nil
        error_message = nil
        raw_response = nil
        token_usage = {}

        begin
          parameters = { model: model, input: text }.merge(options)
          raw_response = client.embeddings(parameters: parameters)

          if raw_response["data"] && raw_response["data"].first["embedding"]
            embedding_vector = raw_response["data"].first["embedding"]
            token_usage = raw_response["usage"] || {} # Corrected
          else
            error_message = "No embedding in OpenAI response: #{raw_response}"
          end
        rescue OpenAI::Error => e
          error_message = "OpenAI API Error: #{e.message}"
          raw_response = e.response if e.respond_to?(:response)
        rescue StandardError => e
          error_message = "StandardError during OpenAI embed: #{e.message}"
          raw_response = e
        end

        SynapseAi::Response.new(
          success: error_message.nil?,
          content: embedding_vector,
          error_message: error_message,
          raw_response: raw_response,
          token_usage: {
            prompt_tokens: token_usage["prompt_tokens"],
            # Embeddings API doesn't return completion_tokens
            total_tokens: token_usage["total_tokens"]
          }
        )
      end

      CHAT_MODELS = [
        "gpt-4",
        "gpt-4-turbo",
        "gpt-4-turbo-preview",
        "gpt-4-0125-preview",
        "gpt-4-1106-preview",
        "gpt-4-vision-preview", # Added for completeness, though vision may need special handling
        "gpt-3.5-turbo",
        "gpt-3.5-turbo-0125",
        "gpt-3.5-turbo-1106"
      ].freeze
    end
  end
end
