require "spec_helper"

RSpec.describe Pubid::Builder::Base do
  let(:test_builder) do
    Class.new(described_class) do
      def self.name
        "TestBuilder"
      end

      def default_identifier_class
        Pubid::Components::Code
      end

      def locate_typed_stage(_)
        nil
      end

      # Expose private helper for testing
      public :parse_number_with_part
      public :normalize_number_with_part
      public :extract_legacy_year
    end
  end

  let(:builder) { test_builder.new }

  describe "#parse_number_with_part" do
    it "splits a plain number" do
      result = builder.parse_number_with_part("1234", code_class: Pubid::Components::Code)
      expect(result[:number].value).to eq("1234")
      expect(result[:part]).to be_nil
      expect(result[:subpart]).to be_nil
    end

    it "splits number and part" do
      result = builder.parse_number_with_part("1234-1", code_class: Pubid::Components::Code)
      expect(result[:number].value).to eq("1234")
      expect(result[:part].value).to eq("1")
      expect(result[:subpart]).to be_nil
    end

    it "splits number, part, and subpart" do
      result = builder.parse_number_with_part("29110-5-1-1", code_class: Pubid::Components::Code)
      expect(result[:number].value).to eq("29110")
      expect(result[:part].value).to eq("5")
      expect(result[:subpart].value).to eq("1-1")
    end

    it "uses the supplied code class" do
      custom_class = Class.new(Pubid::Components::Code)
      result = builder.parse_number_with_part("1234", code_class: custom_class)
      expect(result[:number]).to be_a(custom_class)
    end

    it "converts roman numeral part to integer" do
      result = builder.parse_number_with_part("1234-I", code_class: Pubid::Components::Code)
      expect(result[:part].value).to eq("1")
    end
  end

  describe "template hooks" do
    let(:iso_builder_class) do
      Class.new(described_class) do
        def self.name
          "IsoLikeBuilder"
        end

        def default_identifier_class
          Pubid::Components::Code
        end

        def locate_typed_stage(_)
          nil
        end

        public :parse_number_with_part
        public :normalize_number_with_part
        public :extract_legacy_year
      end
    end

    let(:iso_builder) { iso_builder_class.new }

    describe "#normalize_number_with_part" do
      it "returns the input unchanged by default" do
        expect(iso_builder.normalize_number_with_part("1234-1")).to eq("1234-1")
      end
    end

    describe "#extract_legacy_year" do
      it "returns nil by default" do
        expect(iso_builder.extract_legacy_year("1234", "1979", Pubid::Components::Code)).to be_nil
      end
    end
  end
end
