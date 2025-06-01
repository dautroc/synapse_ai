# frozen_string_literal: true

# This class represents the base class for all AI providers.
# It provides a common interface for all AI providers.
module SynapseAi
  module Providers
    # Abstract base class for AI provider adapters.
    # Defines the interface that all provider-specific adapters should implement.
    class Base
      # Initializes the provider adapter.
      # Subclasses should call super and then perform any provider-specific setup.
      def chat(messages:, **options)
        raise NotImplementedError, "#{self.class.name} must implement #chat"
      end

      def generate_text(prompt:, **options)
        raise NotImplementedError, "#{self.class.name} must implement #generate_text"
      end

      def generate_image(prompt:, **options)
        raise NotImplementedError, "#{self.class.name} must implement #generate_image"
      end

      def embed(text:, model: nil, **options)
        raise NotImplementedError, "#{self.class.name} must implement #embed"
      end
    end
  end
end
