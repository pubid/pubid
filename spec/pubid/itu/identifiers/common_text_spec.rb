# frozen_string_literal: true

require "spec_helper"

RSpec.describe "ITU common-text identifier — issue #234" do
  describe "Recommendation ITU-T X | ISO/IEC Y" do
    let(:identifier) do
      "Recommendation ITU-T H.222.0 (2021) | ISO/IEC 13818-1:2022"
    end
    let(:parsed) { Pubid::Itu.parse(identifier) }

    it "parses as a Recommendation" do
      expect(parsed).to be_a(Pubid::Itu::Identifiers::Recommendation)
    end

    it "parses the ITU half" do
      expect(parsed.series.series).to eq("H")
      expect(parsed.code.number).to eq("222")
      expect(parsed.code.subseries).to eq("0")
      expect(parsed.date.year).to eq("2021")
    end

    it "captures the common-text twin as an ISO identifier" do
      twin = parsed.common_text_twin
      expect(twin).to be_a(Pubid::Iso::Identifiers::InternationalStandard)
      expect(twin.publisher.publisher).to eq("ISO")
      expect(twin.copublishers.first.publisher).to eq("IEC")
      expect(twin.number.value).to eq("13818")
      expect(twin.part.value).to eq("1")
      expect(twin.date.year).to eq("2022")
    end

    it "round-trips" do
      # The "Recommendation " prefix is normalized away (same as #233).
      expect(parsed.to_s)
        .to eq("ITU-T H.222.0 (2021) | ISO/IEC 13818-1:2022")
    end
  end

  describe "without the verbose prefix" do
    it "parses ITU-T H.222.0 (2021) | ISO/IEC 13818-1:2022" do
      parsed = Pubid::Itu.parse("ITU-T H.222.0 (2021) | ISO/IEC 13818-1:2022")
      expect(parsed.common_text_twin).to be_a(Pubid::Iso::Identifier)
      expect(parsed.to_s).to eq("ITU-T H.222.0 (2021) | ISO/IEC 13818-1:2022")
    end
  end

  describe "without a twin (regression check)" do
    it "leaves common_text_twin nil" do
      parsed = Pubid::Itu.parse("ITU-T H.265 (2021)")
      expect(parsed.common_text_twin).to be_nil
    end
  end

  describe "distinctness" do
    it "treats the common-text form as distinct from its bare ITU half" do
      with_twin = Pubid::Itu.parse("ITU-T H.222.0 (2021) | ISO/IEC 13818-1:2022")
      without_twin = Pubid::Itu.parse("ITU-T H.222.0 (2021)")
      expect(with_twin).not_to eq(without_twin)
    end
  end
end
