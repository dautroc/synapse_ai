# frozen_string_literal: true

require "rails/generators/base"

module SynapseAi
  module Generators
    # Installs SynapseAI configuration files.
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("templates", __dir__)

      def copy_initializer_file
        copy_file "synapse_ai.rb", "config/initializers/synapse_ai.rb"
      end

      # You could add more here, like checking for dependencies or printing instructions.
      def show_readme
        readme "USAGE"
      end
    end
  end
end
