# frozen_string_literal: true

require "spec_helper"

# Round-trip coverage for the identifier families added to support
# relaton-data-cie index-v2 (see HANDOFFS/metanorma__pubid.md):
#   1+2 proceedings papers, 3 techstreet /slug conference variant,
#   4 D-series, 5 S-series /<year>, 6 CIE ISO TS.
RSpec.describe "Pubid::Cie grammar extensions" do
  # id => expected concrete Identifiers::* class
  cases = {
    # Family 1 — x-prefixed conference proceedings papers
    "CIE x043-OP01" => Pubid::Cie::Identifiers::Proceedings,
    "CIE x043-PO05" => Pubid::Cie::Identifiers::Proceedings,
    "CIE x043-PP12" => Pubid::Cie::Identifiers::Proceedings,
    "CIE x043-WP03" => Pubid::Cie::Identifiers::Proceedings,
    "CIE x043-IP01" => Pubid::Cie::Identifiers::Proceedings,
    "CIE x049-P03" => Pubid::Cie::Identifiers::Proceedings, # single-letter code
    # Family 2 — standalone proceedings papers
    "CIE OP02 1-5" => Pubid::Cie::Identifiers::Proceedings,
    "CIE PO01 404-407" => Pubid::Cie::Identifiers::Proceedings,
    "CIE IP04 10-16" => Pubid::Cie::Identifiers::Proceedings,
    # Family 3 — techstreet /slug conference variant
    "CIE x051:2025/2aue4q" => Pubid::Cie::Identifiers::Conference,
    "CIE x051:2025/33bx34" => Pubid::Cie::Identifiers::Conference,
    # Family 4 — D-series
    "CIE D001-2006" => Pubid::Cie::Identifiers::Standard,
    "CIE D002:2004" => Pubid::Cie::Identifiers::Standard,
    # Family 5 — S-series /<year> without language letter
    "CIE S 007/1998" => Pubid::Cie::Identifiers::Standard,
    "CIE S 006.1/1998" => Pubid::Cie::Identifiers::Standard,
    # Family 6 — CIE ISO Technical Specification
    "CIE ISO TS 22012:2019" => Pubid::Cie::Identifiers::JointPublished,
  }

  cases.each do |id, klass|
    context "for #{id.inspect}" do
      let(:parsed) { Pubid::Cie.parse(id) }

      it "parses to #{klass}" do
        expect(parsed).to be_a(klass)
      end

      it "renders back to the original string (to_s == id)" do
        expect(parsed.to_s).to eq(id)
      end

      it "round-trips through from_hash(to_hash) idempotently" do
        h = parsed.to_hash
        restored = Pubid::Cie::Identifier.from_hash(h)
        expect(restored.class).to eq(parsed.class)
        expect(restored.to_s).to eq(parsed.to_s)
        expect(restored.to_hash).to eq(h)
      end
    end
  end

  describe "Proceedings attributes" do
    # The paper is the document, so its identity (code + running number) is the
    # flat `number` for both forms; the x-form's parent conference lives in
    # `conference`. This gives every proceedings row a non-empty
    # relaton-index binary-search key (see index_number_spec).
    it "captures the paper as number and the conference for x-prefixed" do
      id = Pubid::Cie.parse("CIE x043-OP01")
      expect(id.number).to eq("OP01")
      expect(id.conference).to eq("043")
      expect(id.page).to be_nil
    end

    it "captures the paper as number and the page range for standalone" do
      id = Pubid::Cie.parse("CIE OP02 1-5")
      expect(id.number).to eq("OP02")
      expect(id.conference).to be_nil
      expect(id.page).to eq("1-5")
    end

    it "captures a single-letter paper code as part of number" do
      id = Pubid::Cie.parse("CIE x049-P03")
      expect(id.number).to eq("P03")
      expect(id.conference).to eq("049")
    end
  end

  describe "Conference /slug variant" do
    it "captures the verbatim slug" do
      id = Pubid::Cie.parse("CIE x051:2025/2aue4q")
      expect(id.variant).to eq("2aue4q")
    end
  end

  describe "style as the sole separator field (no date_separator)" do
    it "maps colon/dash/slash to current/legacy/slash and drops the default" do
      colon = Pubid::Cie.parse("CIE 015:2018")
      dash  = Pubid::Cie.parse("CIE 016-1970")
      slash = Pubid::Cie.parse("CIE S 007/1998")

      expect(colon.style).to eq("current")
      expect(dash.style).to eq("legacy")
      expect(slash.style).to eq("slash")

      # No date_separator attribute exists any more.
      expect(colon).not_to respond_to(:date_separator)

      # current (default) is dropped from to_hash; legacy/slash are kept.
      expect(colon.to_hash).not_to have_key("style")
      expect(dash.to_hash["style"]).to eq("legacy")
      expect(slash.to_hash["style"]).to eq("slash")
    end
  end
end
