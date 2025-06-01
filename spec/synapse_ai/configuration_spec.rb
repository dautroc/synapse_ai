# frozen_string_literal: true

require "spec_helper"

RSpec.describe SynapseAi::Configuration do
  describe "#initialize" do
    # Preserve original ENV values around tests that modify them
    around do |example|
      original_openai_key = ENV["OPENAI_API_KEY"]
      original_google_key = ENV["GOOGLE_API_KEY"]
      example.run
    ensure
      ENV["OPENAI_API_KEY"] = original_openai_key
      ENV["GOOGLE_API_KEY"] = original_google_key
    end

    context "when environment variables are NOT set for the test" do
      before do
        ENV.delete("OPENAI_API_KEY")
        ENV.delete("GOOGLE_API_KEY")
      end

      subject(:config) { described_class.new }

      it "defaults provider to :openai" do
        expect(config.provider).to eq(:openai)
      end

      it "defaults openai_api_key to nil" do
        expect(config.openai_api_key).to be_nil
      end

      it "defaults google_api_key to nil" do
        expect(config.google_api_key).to be_nil
      end

      it "defaults log_level to :info" do
        expect(config.log_level).to eq(:info)
      end

      it "defaults default_timeout to 60" do
        expect(config.default_timeout).to eq(60)
      end
    end

    context "when environment variables ARE set for the test" do
      let(:fake_openai_key) { "sk-env-openai-key-for-test" }
      let(:fake_google_key) { "env-google-key-for-test" }

      before do
        ENV["OPENAI_API_KEY"] = fake_openai_key
        ENV["GOOGLE_API_KEY"] = fake_google_key
      end

      subject(:config) { described_class.new }

      it "uses ENV for openai_api_key if set" do
        expect(config.openai_api_key).to eq(fake_openai_key)
      end

      it "uses ENV for google_api_key if set" do
        expect(config.google_api_key).to eq(fake_google_key)
      end
    end
  end
end
