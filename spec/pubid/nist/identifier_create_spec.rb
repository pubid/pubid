require "spec_helper"

RSpec.describe Pubid::Nist::Identifier do
  describe ".create" do
    context "series-based dispatch" do
      {
        "SP"   => [Pubid::Nist::Identifiers::SpecialPublication,                  "NIST SP 800-53"],
        "FIPS" => [Pubid::Nist::Identifiers::FederalInformationProcessingStandards, "NIST FIPS 197"],
        "HB"   => [Pubid::Nist::Identifiers::Handbook,                            "NIST HB 150"],
        "IR"   => [Pubid::Nist::Identifiers::InteragencyReport,                   "NIST IR 7298"],
        "TN"   => [Pubid::Nist::Identifiers::TechnicalNote,                       "NIST TN 1900"],
        "MONO" => [Pubid::Nist::Identifiers::Monograph,                           "NIST MONO 1"],
      }.each do |series, (klass, rendered)|
        it "dispatches series: '#{series}' → #{klass.name.split('::').last}" do
          number = rendered.split.last
          id = described_class.create(publisher: "NIST", series: series,
                                      number: number)
          expect(id).to be_a(klass)
          expect(id.to_s).to eq(rendered)
        end
      end

      it "falls back to Base for an unknown series" do
        id = described_class.create(series: "ZZZ", number: "1")
        expect(id).to be_a(Pubid::Nist::Identifiers::Base)
      end
    end

    context "publisher visibility" do
      it "renders the 'NIST' prefix when :publisher is given" do
        id = described_class.create(publisher: "NIST", series: "SP",
                                    number: "800-53")
        expect(id.to_s).to eq("NIST SP 800-53")
      end

      it "omits the 'NIST' prefix when :publisher is not given" do
        id = described_class.create(series: "SP", number: "800-53")
        expect(id.to_s).to eq("SP 800-53")
      end
    end

    context "primitive coercion" do
      it "wraps :series into Nist::Components::Code" do
        id = described_class.create(series: "SP", number: "800-53")
        expect(id.series).to be_a(Pubid::Nist::Components::Code)
        expect(id.series.number).to eq("SP")
      end

      it "wraps :number into Nist::Components::Code" do
        id = described_class.create(series: "SP", number: "800-53")
        expect(id.number).to be_a(Pubid::Nist::Components::Code)
        expect(id.number.number).to eq("800-53")
      end

      it "passes through already-built Components untouched" do
        already_code = Pubid::Nist::Components::Code.new(number: "SP")
        id = described_class.create(series: already_code, number: "1")
        expect(id.series).to equal(already_code)
      end
    end

    context "parse equivalence" do
      [
        "NIST SP 800-53",
        "NIST FIPS 197",
        "NIST HB 150",
        "NIST IR 7298",
      ].each do |string|
        it "round-trips #{string}" do
          parts = string.split
          series = parts[1]
          number = parts[2..].join(" ")
          created = described_class.create(publisher: "NIST",
                                           series: series, number: number)
          parsed = Pubid::Nist.parse(string)
          expect(created.to_s).to eq(parsed.to_s)
        end
      end
    end
  end
end
