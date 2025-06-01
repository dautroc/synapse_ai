# frozen_string_literal: true

require "openai"

module SynapseAi
  module Providers
    class OpenAIAdapter < Base
      attr_reader :client

      def initialize(api_key: SynapseAi.configuration.openai_api_key, client_options: {})
        super()
        if api_key.nil? || api_key.empty?
          raise ArgumentError, "OpenAI API key is required. Set it via SynapseAI.configure or pass it directly."
        end

        @client = ::OpenAI::Client.new(access_token: api_key, **client_options)
      end

      # Implements the chat functionality using the OpenAI API.
      #
      # @param messages [Array<Hash>] An array of message objects (e.g., [{ role: "user", content: "Hello!" }]).
      # @param model [String] The model to use for chat completion (e.g., "gpt-3.5-turbo"). Defaults to "gpt-3.5-turbo".
      # @param options [Hash] Additional options to pass to the OpenAI client.
      # @return [SynapseAi::Response] A standardized response object.
      def chat(messages:, model: "gpt-3.5-turbo", **options)
        raw_response = client.chat(
          parameters: {
            model: model,
            messages: messages
          }.merge(options)
        )

        if raw_response.key?("choices") && raw_response["choices"].any?
          content = raw_response.dig("choices", 0, "message", "content")
          token_usage = raw_response.dig("usage") || {}
          SynapseAi::Response.new(
            content: content,
            token_usage: token_usage,
            raw_response: raw_response,
            status: :success
          )
        elsif raw_response.key?("error")
          SynapseAi::Response.new(
            error: raw_response["error"]["message"],
            raw_response: raw_response,
            status: :error
          )
        else
          SynapseAi::Response.new(
            error: "Unknown error or malformed response from OpenAI.",
            raw_response: raw_response,
            status: :error
          )
        end
      rescue ::OpenAI::Error => e
        SynapseAi::Response.new(error: e.message, raw_response: e.response, status: :error)
      rescue StandardError => e
        SynapseAi::Response.new(error: "SynapseAI client error in chat: #{e.message}", status: :error)
      end

      # Implements text generation (completion) functionality using the OpenAI API.
      # This is a simplified interface. For more complex scenarios, using #chat is often preferred.
      #
      # @param prompt [String] The prompt to generate text from.
      # @param model [String] The model to use (e.g., "text-davinci-003" or a chat model like "gpt-3.5-turbo"). Defaults to "gpt-3.5-turbo".
      # @param options [Hash] Additional options to pass to the OpenAI client.
      # @return [SynapseAi::Response] A standardized response object.
      def generate_text(prompt:, model: "gpt-3.5-turbo", max_tokens: 150, **options)
        # For newer models, chat completion endpoint is preferred even for single prompts.
        if model.start_with?("gpt-3.5-turbo") || model.start_with?("gpt-4")
          messages = [{ role: "user", content: prompt }]
          chat(messages: messages, model: model, max_tokens: max_tokens, **options)
        else
          # Legacy completion endpoint (less common now)
          begin
            raw_response = client.completions(
              parameters: {
                model: model,
                prompt: prompt,
                max_tokens: max_tokens
              }.merge(options)
            )
            if raw_response.key?("choices") && raw_response["choices"].any?
              content = raw_response.dig("choices", 0, "text")
              token_usage = raw_response.dig("usage") || {}
              SynapseAi::Response.new(
                content: content,
                token_usage: token_usage,
                raw_response: raw_response,
                status: :success
              )
            elsif raw_response.key?("error")
              SynapseAi::Response.new(
                error: raw_response["error"]["message"],
                raw_response: raw_response,
                status: :error
              )
            else
              SynapseAi::Response.new(
                error: "Unknown error or malformed response from OpenAI.",
                raw_response: raw_response,
                status: :error
              )
            end
          rescue ::OpenAI::Error => e
            SynapseAi::Response.new(error: e.message, raw_response: e.response, status: :error)
          rescue StandardError => e
            SynapseAi::Response.new(error: "SynapseAI client error: #{e.message}", status: :error)
          end
        end
      end

      # Generates embeddings for a given text using the OpenAI API.
      #
      # @param text [String] The text to generate embeddings for.
      # @param model [String] The model to use for embeddings. Defaults to "text-embedding-3-small".
      # @param options [Hash] Additional options to pass to the OpenAI client.
      # @return [SynapseAi::Response] A standardized response object. The content will be the embedding vector (Array<Float>).
      def embed(text:, model: "text-embedding-3-small", **options)
        raw_response = client.embeddings(
          parameters: {
            input: text,
            model: model
          }.merge(options)
        )

        if raw_response.key?("data") && raw_response["data"].any? && raw_response["data"][0].key?("embedding")
          embedding_vector = raw_response.dig("data", 0, "embedding")
          token_usage = raw_response.dig("usage") || {}
          SynapseAi::Response.new(
            content: embedding_vector,
            token_usage: token_usage,
            raw_response: raw_response,
            status: :success
          )
        elsif raw_response.key?("error")
          SynapseAi::Response.new(
            error: raw_response["error"]["message"],
            raw_response: raw_response,
            status: :error
          )
        else
          SynapseAi::Response.new(
            error: "Unknown error or malformed embedding response from OpenAI.",
            raw_response: raw_response,
            status: :error
          )
        end
      rescue ::OpenAI::Error => e
        SynapseAi::Response.new(error: e.message, raw_response: e.response, status: :error)
      rescue StandardError => e
        SynapseAi::Response.new(error: "SynapseAI client error in embed: #{e.message}", status: :error)
      end
    end
  end
end
