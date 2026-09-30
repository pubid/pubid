# frozen_string_literal: true

require "parsanol"

RSpec.describe Pubid::Parg::Backend do
  describe ".parse" do
    it "raises ParseError for a malformed identifier" do
      expect { described_class.parse(:iso, "nonsense") }
        .to raise_error(Pubid::Errors::ParseError)
    end

    it "returns a builder-ready hash whose build renders the input" do
      hash = described_class.parse(:iso, "ISO 8601-1:2019")
      built = Pubid::Iso::Builder.new.build(hash)

      expect(built.to_s).to eq("ISO 8601-1:2019")
    end
  end

  describe Pubid::Parg::Artifact do
    it "loads the vendored iso artifact with a verified checksum" do
      artifact = described_class.for(:iso)

      expect(artifact.checksum).to start_with("sha256:")
    end

    # parsanol renamed its grammar-language namespace from Parsanol::PG to
    # Parsanol::PARG; the loader must use the name parsanol defines.
    it "parses through the Parsanol::PARG runtime" do
      expect(defined?(Parsanol::PARG::Artifact)).to eq("constant")
      expect(Pubid::Xsf::Identifier.parse("XEP 0001").to_s).to eq("XEP 0001")
    end
  end
end
