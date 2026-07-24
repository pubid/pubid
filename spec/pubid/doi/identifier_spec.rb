# frozen_string_literal: true

require "spec_helper"

RSpec.describe Pubid::Doi::Identifier do
  describe ".parse" do
    context "canonical form" do
      subject(:parsed) { described_class.parse("doi:10.1000/182") }

      it "captures prefix" do
        expect(parsed.prefix).to eq("10.1000")
      end

      it "captures suffix" do
        expect(parsed.suffix).to eq("182")
      end

      it "exposes registrar" do
        expect(parsed.registrar).to eq("1000")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq("doi:10.1000/182")
      end
    end

    context "bare form (no scheme prefix)" do
      it "round-trips" do
        parsed = described_class.parse("10.1006/jmbi.1998.2354")
        expect(parsed.to_s).to eq("doi:10.1006/jmbi.1998.2354")
      end
    end

    context "URL resolver form" do
      it "strips the https://doi.org/ prefix" do
        parsed = described_class.parse("https://doi.org/10.1000/182")
        expect(parsed.to_s).to eq("doi:10.1000/182")
      end
    end

    context "uppercase scheme" do
      it "is case-insensitive on the scheme" do
        parsed = described_class.parse("DOI:10.6028/NIST.2022-04-15.001")
        expect(parsed.suffix).to eq("NIST.2022-04-15.001")
      end
    end

    %w[doi: doi:10 doi:10.X/abc doi:10.1000/].each do |bad|
      it "rejects #{bad.inspect}" do
        expect { described_class.parse(bad) }.to raise_error(/Failed to parse/)
      end
    end
  end
end
