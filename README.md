# Setup

``` ruby
gem 'synapse_ai', path: '../synapse_ai'
```

## Configuration

``` bash
$ rails generate synapse_ai:install
```

This will create `config/initializers/synapse_ai.rb`. Open this file to configure your API keys and other settings (OpenAI only):

``` ruby
# config/initializers/synapse_ai.rb
SynapseAi.configure do |config|
  config.provider = :openai
  config.openai_api_key = ENV['OPENAI_API_KEY']
  config.log_level = :info # or :debug
  config.default_timeout = 60
end
```

## Usage

Here's how you might use SynapseAI within a Rails model to generate a summary for an article:

``` ruby
class Article < ApplicationRecord
  def generate_summary_with_synapse
    prompt_text = "Summarize the content: #{self.content}"

    response = SynapseAi.generate_text(
      prompt: prompt_text,
      model: "gpt-3.5-turbo", 
      max_tokens: 100        
    )

    puts response.content.strip
  end
end
```
