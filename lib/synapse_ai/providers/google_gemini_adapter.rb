# frozen_string_literal: true

require "gemini-ai"
require_relative "../response"
require_relative "base"

module SynapseAi
  module Providers
    # Adapter for the Google Gemini API.
    class GoogleGeminiAdapter < Base
      DEFAULT_EMBEDDING_MODEL = "text-embedding-004"
      DEFAULT_CHAT_MODEL = "gemini-pro"

      def initialize(api_key: SynapseAi.configuration.google_gemini_api_key)
        super()
        raise ArgumentError, "Google Gemini API key is required." unless api_key

        # The 'gemini-ai' gem client initialization
        # It expects credentials in a specific hash structure.
        @client = Gemini::Client.new(
          credentials: {
            service: "generative-language-api",
            api_key: api_key
          },
          options: { model: DEFAULT_CHAT_MODEL, server_sent_events: false } # SSE can be true if we handle streaming
        )
      rescue Gemini::Errors::GeminiError => e
        # Catch client initialization errors and wrap them
        raise SynapseAi::Errors::ConfigurationError, "Failed to initialize Google Gemini client: #{e.message}"
      end

      # Performs a chat completion.
      #
      # @param messages [Array<Hash>] A list of message objects, e.g., [{role: 'user', parts: [{text: 'Hello'}]}]
      # @param model [String] The model to use for chat completion.
      # @param temperature [Float] The temperature for sampling.
      # @param options [Hash] Additional options for the provider.
      # @return [SynapseAi::Response] The standardized response object.
      def chat(messages:, _model: DEFAULT_CHAT_MODEL, temperature: 0.7, **options)
        # Adapt SynapseAI message format to Gemini format if necessary
        # Gemini expects: { contents: [{ role: 'user', parts: { text: 'Hello!' } }] }
        # or an array for history: { contents: [ {role: 'user', parts: ...}, {role: 'model', parts: ...} ] }

        gemini_messages = messages.map do |msg|
          {
            role: msg[:role],
            parts: msg[:parts].map { |part| { text: part[:text] } } # Ensure parts is an array of hashes with text
          }
        end

        payload = {
          contents: gemini_messages,
          generation_config: {
            temperature: temperature
            # model: model # The model is often set at client level or can be overridden here if API supports
          }
        }.merge(options)

        raw_response = @client.generate_content(payload) # or stream_generate_content if streaming

        # Ensure 'candidates' and the nested structure exist before accessing them
        first_candidate = raw_response["candidates"]&.first
        content = first_candidate&.dig("content", "parts")&.map { |p| p["text"] }&.join

        # Placeholder for token usage - Gemini API response structure for this needs to be checked
        # For generate_content, usageMetadata might be available directly in raw_response or within candidates.
        # Example: raw_response.dig('usageMetadata', 'totalTokenCount')
        # For stream_generate_content, it's usually in the last event.
        prompt_tokens = raw_response.dig("usageMetadata", "promptTokenCount")
        completion_tokens = raw_response.dig("usageMetadata", "candidatesTokenCount")
        total_tokens = raw_response.dig("usageMetadata", "totalTokenCount")

        SynapseAi::Response.new(
          content: content,
          error: nil,
          token_usage: {
            prompt_tokens: prompt_tokens,
            completion_tokens: completion_tokens,
            total_tokens: total_tokens
          },
          raw_response: raw_response,
          status: :success
        )
      rescue Gemini::Errors::RequestError => e
        SynapseAi::Response.new(
          content: nil,
          error: { type: e.class.name, message: e.message },
          raw_response: e.response, # The gem might store the response in the error object
          status: :error
        )
      rescue StandardError => e
        SynapseAi::Response.new(
          content: nil,
          error: { type: e.class.name, message: e.message },
          raw_response: nil,
          status: :error
        )
      end

      # Generates text (similar to chat, but might use a different endpoint or model type in some providers).
      # For Gemini, generate_content is versatile.
      #
      # @param prompt [String] The prompt to generate text from.
      # @param model [String] The model to use.
      # @param temperature [Float] The temperature for sampling.
      # @param options [Hash] Additional options.
      # @return [SynapseAi::Response] The standardized response object.
      def generate_text(prompt:, model: DEFAULT_CHAT_MODEL, temperature: 0.7, **options)
        chat(
          messages: [{ role: "user", parts: [{ text: prompt }] }],
          model: model,
          temperature: temperature,
          **options
        )
      end

      # Generates embeddings for the given text.
      #
      # @param text [String] The text to embed.
      # @param model [String] The embedding model to use.
      # @param options [Hash] Additional options.
      # @return [SynapseAi::Response] The standardized response object.
      def embed(text:, model: DEFAULT_EMBEDDING_MODEL, **options)
        # The 'gemini-ai' gem uses embed_content for Generative Language API service
        payload = {
          content: { parts: [{ text: text }] }
          # model: model # Model for embedding can be passed if API supports it per call, or set in client
        }.merge(options)

        # We might need a separate client or client configuration for embedding models
        # as the 'gemini-ai' client takes a model in its options during initialization.
        # For now, assuming the client can use a different model if specified in the method call or
        # we re-initialize a client for embeddings if needed.
        # Let's check if the gem allows model override per call for embeddings.
        # According to gemini-ai docs, for Generative Language API,
        # it's client.embed_content and model is passed in options.

        embedding_client = Gemini::Client.new(
          credentials: {
            service: "generative-language-api",
            api_key: SynapseAi.configuration.google_gemini_api_key
          },
          options: { model: model, server_sent_events: false }
        )

        raw_response = embedding_client.embed_content(payload)

        # According to gemini-ai docs, for Generative Language API,
        # it's client.embed_content and model is passed in options.
        if raw_response.is_a?(Hash) && raw_response["embedding"]
          embedding_vector = raw_response.dig("embedding", "values")
        end

        # Token usage for embeddings might not be directly provided or be relevant in the same way.
        # Check Gemini API documentation for how it reports usage for embeddings.
        # For now, we'll leave it nil or use what's available.

        SynapseAi::Response.new(
          content: embedding_vector, # The embedding itself
          error: nil,
          token_usage: nil, # Placeholder
          raw_response: raw_response,
          status: :success
        )
      rescue Gemini::Errors::RequestError => e
        SynapseAi::Response.new(
          content: nil,
          error: { type: e.class.name, message: e.message },
          raw_response: e.response,
          status: :error
        )
      rescue StandardError => e
        SynapseAi::Response.new(
          content: nil,
          error: { type: e.class.name, message: e.message },
          raw_response: nil,
          status: :error
        )
      end
    end
  end
end
