# SynapseAI: Rails-Native AI Integration Layer

SynapseAI provides a seamless and "Rails-way" approach to integrating various AI functionalities into Ruby on Rails applications. It abstracts the complexities of different AI provider APIs (starting with OpenAI) and offers a consistent developer experience.

## Vision

Mission: To provide a seamless and "Rails-way" approach to integrating various AI functionalities into Ruby on Rails applications, abstracting complexities of different AI provider APIs and offering a consistent developer experience.

## Requirements

- Ruby >= 3.1
- Bundler >= 2

## Installation (private)

Add one of the following to your application's Gemfile:

Git (recommended):

```ruby
gem 'synapse_ai', git: 'https://github.com/dautroc/synapse_ai', branch: 'main'
```

Local path (for local development):

```ruby
gem 'synapse_ai', path: '../synapse_ai'
```

## Configuration

After bundling the gem, you can run the install generator to create an initializer file:

```bash
$ rails generate synapse_ai:install
```

This will create `config/initializers/synapse_ai.rb`. Open this file to configure your API keys and other settings (OpenAI only):

```ruby
# config/initializers/synapse_ai.rb
SynapseAi.configure do |config|
  # Default and only supported provider is :openai
  # config.provider = :openai

  config.openai_api_key = ENV['OPENAI_API_KEY']

  config.log_level = :info # Or :debug for more verbose logging from the gem
  config.default_timeout = 60 # Seconds for API calls
end
```

Make sure you have `OPENAI_API_KEY` set in your application's environment (e.g., using `dotenv-rails`, Rails credentials, or your hosting provider's environment variable settings). Only OpenAI is supported.

## Usage Example

Here's how you might use SynapseAI within a Rails model to generate a summary for an article:

```ruby
# app/models/article.rb
class Article < ApplicationRecord
  # Assuming 'content' is an attribute of Article
  # and you want to store the summary in 'summary' (add this column if it doesn't exist)

  def generate_summary_with_synapse
    prompt_text = "Summarize the following text concisely, in no more than 3 sentences:\n\n#{self.content}"

    # Ensure SynapseAi is configured (e.g., via an initializer as shown above)
    response = SynapseAi.generate_text(
      prompt: prompt_text,
      model: "gpt-3.5-turbo", # Or your preferred model
      max_tokens: 100         # Adjust as needed
    )

    if response.success?
      self.summary = response.content.strip
      # self.save # Uncomment if you want to save immediately
      true
    else
      Rails.logger.error "SynapseAI Error generating summary for Article ##{id}: #{response.error}"
      self.summary = "Could not generate summary at this time."
      false
    end
  rescue StandardError => e
    Rails.logger.error "SynapseAI: Unexpected error during summary generation for Article ##{id}: #{e.message}"
    self.summary = "Could not generate summary due to an unexpected issue."
    false
  end
end
```

Then in your controller or console:

```ruby
article = Article.find(your_article_id)
if article.generate_summary_with_synapse
  article.save
  puts "Summary generated: #{article.summary}"
else
  puts "Failed to generate summary."
end
```

### Generating Embeddings

Embeddings convert text into numerical vectors, which are useful for semantic search, clustering, and other machine learning tasks.

```ruby
text_to_embed = "SynapseAI makes AI integration easy."

# Default model for OpenAI is text-embedding-3-small
response = SynapseAi.embed(text: text_to_embed)

if response.success?
  embedding_vector = response.content
  puts "Generated embedding vector (first 5 dimensions): #{embedding_vector.take(5)}..."
  puts "Total dimensions: #{embedding_vector.size}"
  # You can now store this vector in a vector database (e.g., pgvector, Pinecone, Weaviate)
  # or use it for similarity calculations.
else
  puts "Failed to generate embedding: #{response.error}"
end

# You can also specify a model (if supported by the provider):
# response_ada = SynapseAi.embed(text: text_to_embed, model: "text-embedding-ada-002")
# if response_ada.success?
#   puts "ADA-002 embedding (first 5): #{response_ada.content.take(5)}..."
# end
```

## Implemented Features (Phase 1 & early Phase 2)

*   Configuration layer for API keys and defaults.
*   Standardized `SynapseAi::Response` object.
*   OpenAI Provider Integration:
    *   `SynapseAi.chat(messages:, **options)`
    *   `SynapseAi.generate_text(prompt:, **options)`
    *   `SynapseAi.embed(text:, **options)`
*   Basic Railtie for Rails integration with initializer generator (`rails g synapse_ai:install`).
*   RSpec tests with VCR for the OpenAI adapter and core module.

## Development

Use Ruby 3.3.x (or >= 3.1) and Bundler 2.6.x. After checking out the repo, run `bin/setup` to install dependencies. Then, run `bundle exec rspec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To build and install locally into your gemset, run:

```bash
bundle exec rake install
```
