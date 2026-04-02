# frozen_string_literal: true

require "rspec"
require_relative "../../../lib/pubid_new/rendering/language"
require_relative "../../../lib/pubid_new/components/language"

RSpec.describe PubidNew::Rendering::Language do
  let(:test_class) do
    Class.new do
      include PubidNew::Rendering::Language

      attr_accessor :languages
    end
  end

  let(:instance) { test_class.new }

  describe "#render_languages" do
    it "renders single language" do
      languages = [PubidNew::Components::Language.new(code: "en")]
      expect(instance.render_languages(languages)).to eq("(en)")
    end

    it "renders multiple languages" do
      languages = [
        PubidNew::Components::Language.new(code: "en"),
        PubidNew::Components::Language.new(code: "fr")
      ]
      expect(instance.render_languages(languages)).to eq("(en/fr)")
    end

    it "renders three languages" do
      languages = [
        PubidNew::Components::Language.new(code: "en"),
        PubidNew::Components::Language.new(code: "fr"),
        PubidNew::Components::Language.new(code: "ru")
      ]
      expect(instance.render_languages(languages)).to eq("(en/fr/ru)")
    end

    it "returns empty string for nil languages" do
      expect(instance.render_languages(nil)).to eq("")
    end

    it "returns empty string for empty array" do
      expect(instance.render_languages([])).to eq("")
    end
  end
end
