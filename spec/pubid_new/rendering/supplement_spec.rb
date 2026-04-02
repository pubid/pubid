# frozen_string_literal: true

require "rspec"
require_relative "../../../lib/pubid_new/rendering/supplement"
require_relative "../../../lib/pubid_new/components/date"

RSpec.describe PubidNew::Rendering::Supplement do
  # Mock TypedStage class
  class MockTypedStage
    def initialize(abbr)
      @abbr = abbr
    end

    def abbreviation(format_long: false)
      @abbr
    end
  end

  let(:test_class) do
    Class.new do
      include PubidNew::Rendering::Supplement

      attr_accessor :base_identifier, :supplements

      def to_s(**options)
        "ISO 9001:2015"
      end
    end
  end

  let(:instance) { test_class.new }

  describe "#render_supplements" do
    it "returns base to_s when no supplements" do
      base = double("base", to_s: "ISO 9001:2015")
      expect(instance.render_supplements(base, nil)).to eq("ISO 9001:2015")
    end

    it "renders base with amendment" do
      base = double("base", to_s: "ISO 9001:2015")
      supplements = [{ typed_stage: MockTypedStage.new("Amd"), type: "amendment", number: "1", date: PubidNew::Components::Date.new(year: 2020) }]
      result = instance.render_supplements(base, supplements)
      expect(result).to include("ISO 9001:2015")
      expect(result).to include("Amd")
      expect(result).to include("1")
      expect(result).to include("2020")
    end

    it "renders multiple supplements" do
      base = double("base", to_s: "ISO 9001:2015")
      supplements = [
        { typed_stage: MockTypedStage.new("Amd"), type: "amendment", number: "1", date: PubidNew::Components::Date.new(year: 2020) },
        { typed_stage: MockTypedStage.new("Cor"), type: "corrigendum", number: "1", date: PubidNew::Components::Date.new(year: 2021) }
      ]
      result = instance.render_supplements(base, supplements)
      expect(result).to include("Amd")
      expect(result).to include("Cor")
    end

    it "uses custom separator" do
      base = double("base", to_s: "ISO 9001:2015")
      supplements = [{ typed_stage: MockTypedStage.new("Amd"), type: "amendment", number: "1", date: PubidNew::Components::Date.new(year: 2020) }]
      result = instance.render_supplements(base, supplements, supplement_separator: " — ")
      expect(result).to include("— Amd")
    end
  end
end
