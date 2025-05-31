# frozen_string_literal: true

# This class represents the base class for all AI providers.
# It provides a common interface for all AI providers.
module SynapseAi
  module Providers
    class Base
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
