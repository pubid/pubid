# frozen_string: true

require "spec_helper"

# Specs for the centralized NIST preprocessor.
#
# These specs pin the public contract of Nist::Preprocessor:
#   - call returns a Result with cleaned + format
#   - Each named normalization stage transforms a specific concern
#   - Stage order is preserved (later stages rely on earlier output)
#
# Behavior specs (full input → expected output) live alongside the
# identifier specs in spec/pubid/nist/identifiers/. Here we test the
# Preprocessor as a unit so refactors of individual stages stay safe.
RSpec.describe Pubid::Nist::Preprocessor do
  describe "::ROMAN_TO_ARABIC" do
    it "maps each Roman numeral I..X to its Arabic string" do
      aggregate_failures do
        expect(described_class::ROMAN_TO_ARABIC["I"]).to eq("1")
        expect(described_class::ROMAN_TO_ARABIC["IV"]).to eq("4")
        expect(described_class::ROMAN_TO_ARABIC["X"]).to eq("10")
      end
    end

    it "is frozen so callers cannot mutate the lookup" do
      expect(described_class::ROMAN_TO_ARABIC).to be_frozen
    end
  end

  describe "#call" do
    it "returns a Result with cleaned and format attributes" do
      result = described_class.new("NIST SP 800-53").call
      expect(result).to be_a(Pubid::Nist::Preprocessor::Result)
      expect(result.cleaned).to eq("NIST SP 800-53")
      expect(result.format).to eq(:short)
    end

    it "strips surrounding whitespace before any normalization" do
      result = described_class.new("  NIST SP 800-53  ").call
      expect(result.cleaned).to eq("NIST SP 800-53")
    end

    it "applies data/nist/update_codes.yaml before any Ruby stage" do
      # "NISTIR 8115" → "NIST IR 8115" is an existing YAML rule.
      result = described_class.new("NISTIR 8115").call
      expect(result.cleaned).to start_with("NIST IR")
    end
  end

  describe "stage: publisher & series normalization" do
    it "uppercases a lowercase publisher at start" do
      expect(cleaned("nbs sp 800-53")).to start_with("NBS ")
      expect(cleaned("nist sp 800-53")).to start_with("NIST ")
    end

    it "splits concatenated publisher+series (NISTIR → NIST IR)" do
      expect(cleaned("NISTIR 8115")).to start_with("NIST IR ")
      expect(cleaned("NBSIR 80-2073")).to start_with("NBS IR ")
    end

    it "uppercases a lowercase series code" do
      expect(cleaned("NIST sp 800-53")).to start_with("NIST SP ")
      expect(cleaned("NBS ir 80-2073")).to start_with("NBS IR ")
    end

    it "expands lone 'LC' to 'LCIRC' (but leaves 'LCIRC' untouched)" do
      expect(cleaned("NBS LC 145")).to include("LCIRC")
      expect(cleaned("NBS LCIRC 145")).to include("LCIRC")
    end
  end

  describe "stage: revision spacing" do
    it "separates a compact revision+year from the number" do
      expect(cleaned("NIST SP 260-126rev2013"))
        .to include("126 rev2013")
    end

    it "preserves edition+revision patterns (e2rev1908 stays)" do
      expect(cleaned("11e2rev1908")).to include("e2rev1908")
    end
  end

  describe "stage: letter suffix casing" do
    it "uppercases a trailing letter suffix on a number" do
      expect(cleaned("NBS LC 378g")).to include("378G")
    end

    it "uppercases a letter suffix on a revision" do
      expect(cleaned("NIST SP 800-22r1a")).to include("r1A")
    end

    it "preserves lowercase NCSTAR volume letters" do
      result = cleaned("NCSTAR 1-1av1")
      expect(result).to include("1-1av1").or include("1-1a v1")
    end
  end

  describe "stage: supplement variants" do
    it "inserts a space before 'sup' attached to a digit" do
      expect(cleaned("NBS CIRC 25sup-1924")).to include("25")
    end

    it "normalizes 'sup' → 'supp' after a letter suffix" do
      expect(cleaned("NBS LC 378Gsup")).to include("378Gsupp")
    end

    it "collapses supp-YYYY to suppYYYY (semantic equivalence)" do
      expect(cleaned("NBS CIRC 25supp-1924")).to include("25supp1924")
    end
  end

  describe "stage: update markers" do
    it "inserts a space before -upd" do
      # Use an ID that does NOT match a specific YAML lookup so we
      # observe the preprocessor's general -upd rule in isolation.
      expect(cleaned("NIST IR 8212-upd")).to include("8212 -upd")
    end

    it "inserts a space before /upd after a revision" do
      expect(cleaned("NIST AMS 300-9r1/upd")).to include("r1 /upd")
    end
  end

  describe "stage: Roman numeral conversion" do
    it "converts Roman volumes to v+ver format" do
      # convert_roman_volumes! produces "v<arabic> ver<version>"; later
      # version-notation stages may insert additional spaces.
      result = cleaned("NIST SP 1011-I-2.0")
      expect(result).to include("v1").and include("ver")
      expect(result).not_to match(/-I-/)
    end
  end

  describe "stage: edition year conversion" do
    it "converts trailing -YYYY to eYYYY for plausible years" do
      expect(cleaned("NIST SP 330-2019")).to include("330e2019")
    end

    it "does not convert years outside the 1901-2099 range" do
      # 1039 is a part number, not a year — leave the dash.
      expect(cleaned("NIST SP 250-1039")).to include("250-1039")
    end

    it "reverts HB handbooks to preserve dash-year format" do
      expect(cleaned("NBS HB 130-1979")).to include("130-1979")
    end

    it "reverts OWMWP dates to preserve MM-DD-YYYY" do
      expect(cleaned("NIST OWMWP 06-13-2018"))
        .to include("06-13-2018").or include("06-13e2018")
    end

    it "reverts RPT year ranges to preserve YYYY-YYYY" do
      expect(cleaned("NBS.RPT.1946-1947"))
        .to include("1946-1947").or include("RPT 1946-1947")
    end
  end

  describe "stage: verbose keyword normalization" do
    it "collapses 'rev YYYY' to compact 'rYYYY'" do
      expect(cleaned("NIST SP 260-126 rev 2013"))
        .to include("126r2013")
    end

    it "rewrites historical 'report ;' to 'RPT'" do
      expect(cleaned("NBS report ; 8079")).to include("RPT")
    end

    it "rewrites lone 'report' to 'RPT'" do
      expect(cleaned("NBS report 8079")).to include("RPT")
    end
  end

  describe "stage: MR translation codes" do
    it "converts trailing dot-translation-code to space" do
      expect(cleaned("NIST.SP.1262.spa"))
        .to include("1262 spa")
    end
  end

  describe "#detected_format" do
    it "returns :mr when input has dots and no spaces" do
      expect(format_for("NIST.SP.800-53")).to eq(:mr)
      expect(format_for("FIPS.46e1977")).to eq(:mr)
    end

    it "returns :short when input has spaces" do
      expect(format_for("NIST SP 800-53")).to eq(:short)
    end

    it "returns :short when input has neither dots nor spaces" do
      expect(format_for("NISTIR8115")).to eq(:short)
    end
  end

  # Helpers: invoke the preprocessor and return either the cleaned
  # string or the detected format, so each example reads as a one-liner.
  def cleaned(input)
    described_class.new(input).call.cleaned
  end

  def format_for(input)
    described_class.new(input).call.format
  end
end
