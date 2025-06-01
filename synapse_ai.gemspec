# frozen_string_literal: true

require_relative "lib/synapse_ai/version"

Gem::Specification.new do |spec|
  spec.name = "synapse_ai"
  spec.version = SynapseAi::VERSION
  spec.authors = ["Loi"]
  spec.email = ["ducloi221@gmail.com"]

  spec.summary = "A gem for interacting with the AI functionality in a Rails-way"
  spec.description = "A gem for interacting with the AI functionality in a Rails-way"
  spec.homepage = "https://github.com/dautroc/synapse_ai"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.1.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/dautroc/synapse_ai"
  spec.metadata["changelog_uri"] = "https://github.com/dautroc/synapse_ai/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.bindir = "bin"
  spec.executables = spec.files.grep(%r{\Abin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html

  spec.add_dependency "gemini-ai", "~> 4.2.0"
  spec.add_dependency "ruby-openai"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "vcr"
  spec.add_development_dependency "webmock"
end
