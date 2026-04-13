# frozen_string_literal: true

require "spec_helper"
require "tempfile"

RSpec.describe Pubid::Rewrites do
  describe ".load_yaml" do
    it "returns EMPTY for a missing path" do
      expect(described_class.load_yaml("/no/such/file.yaml")).to be_empty
    end

    it "returns EMPTY for nil path" do
      expect(described_class.load_yaml(nil)).to be_empty
    end

    it "loads entries from a YAML file" do
      Tempfile.create(["rewrites", ".yaml"]) do |f|
        f.write("Foo: Bar\nBaz: Qux\n")
        f.flush
        rewrites = described_class.load_yaml(f.path)
        expect(rewrites.keys).to contain_exactly("Foo", "Baz")
      end
    end
  end

  describe "#apply" do
    let(:rewrites) { described_class.new("Foo" => "Bar", "Hello World" => "Hi") }

    it "rewrites known keys" do
      expect(rewrites.apply("Foo")).to eq("Bar")
    end

    it "passes through unknown keys" do
      expect(rewrites.apply("Unknown")).to eq("Unknown")
    end

    it "strips leading/trailing whitespace before lookup" do
      expect(rewrites.apply("  Foo  ")).to eq("Bar")
    end

    it "passes through nil" do
      expect(rewrites.apply(nil)).to be_nil
    end
  end

  describe "Pubid::Iso integration (283616fe)" do
    it "rewrites ISO/TR 17716.2 to ISO/TR 17716" do
      expect(Pubid::Iso.parse("ISO/TR 17716.2").to_s).to eq("ISO/TR 17716")
    end

    it "rewrites ISO/TR 17716.2(E) to ISO/TR 17716(E)" do
      expect(Pubid::Iso.parse("ISO/TR 17716.2(E)").to_s).to eq("ISO/TR 17716(E)")
    end

    it "leaves ISO/TR 17716 unchanged" do
      expect(Pubid::Iso.parse("ISO/TR 17716").to_s).to eq("ISO/TR 17716")
    end

    it "leaves V2-natively-handled legacy strings alone" do
      # ISO/R 657/IV is parsed natively by V2 (no date added) — the rewrite
      # YAML must not include this entry, otherwise it would override
      # V2's parser behavior with V1's normalized form.
      expect(Pubid::Iso.parse("ISO/R 657/IV").date).to be_nil
    end
  end

  describe "Pubid::Iec integration" do
    it "rewrites IECEx TRF case-correction entry" do
      expect(Pubid::Iec.parse("IECEE TRF cispr 15N:2022").to_s)
        .to eq("IECEE TRF CISPR 15N:2022")
    end
  end
end
