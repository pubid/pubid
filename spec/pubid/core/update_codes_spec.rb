# frozen_string_literal: true

require "spec_helper"

# Unit specs for the centralized pre-parser normalizer.
#
# The shared Core::UpdateCodes loader backs every flavor's
# data/{flavor}/update_codes.yaml. YAML keys may be:
#   - plain strings    → anchored full-line (^...$), literal match
#   - /regex/          → gsub, no flags
#   - /regex/imx       → gsub with IGNORECASE / MULTILINE / EXTENDED
#
# These specs pin all three forms so future format extensions stay
# backward-compatible.
RSpec.describe Pubid::Core::UpdateCodes do
  describe ".compile_pattern" do
    it "anchors plain strings to the full line and escapes meta-chars" do
      pattern = described_class.compile_pattern("NBS MN")
      expect(pattern).to eq(/^NBS\ MN$/)
      expect(pattern.match?("NBS MN")).to be(true)
      expect(pattern.match?("NBS MNE")).to be(false)
      expect(pattern.match?("XX NBS MN")).to be(false)
    end

    it "wraps regex literals in a Regexp without flags" do
      pattern = described_class.compile_pattern("/^NBS CIRC sup$/")
      expect(pattern).to eq(/^NBS CIRC sup$/)
      expect(pattern.casefold?).to be(false)
    end

    it "honors the IGNORECASE flag (i)" do
      # Backslash-b must be escaped in Ruby string literals so it reaches
      # the regex engine as a word-boundary, not a backspace byte.
      pattern = described_class.compile_pattern("/^nbs\\b/i")
      expect(pattern.casefold?).to be(true)
      expect(pattern).to match("NBS FIPS")
      expect(pattern).to match("nbs-foo")
    end

    it "honors the MULTILINE flag (m)" do
      pattern = described_class.compile_pattern("/^x.y$/m")
      expect(pattern.options & Regexp::MULTILINE).to eq(Regexp::MULTILINE)
      expect(pattern).to match("x\ny")
    end

    it "honors the EXTENDED flag (x)" do
      # In EXTENDED mode, literal whitespace is ignored.
      pattern = described_class.compile_pattern("/^ nbs $/x")
      expect(pattern.options & Regexp::EXTENDED).to eq(Regexp::EXTENDED)
      expect(pattern).to match("nbs")
    end

    it "combines multiple flags (im)" do
      pattern = described_class.compile_pattern("/^x$/im")
      expect(pattern.casefold?).to be(true)
      expect(pattern.options & Regexp::MULTILINE).to eq(Regexp::MULTILINE)
    end

    it "ignores unknown flag letters" do
      # Only i/m/x are recognized; unknown letters are silently dropped
      # rather than raising, to keep the YAML format tolerant.
      pattern = described_class.compile_pattern("/^x$/z")
      expect(pattern.options).to eq(0)
    end
  end

  describe ".compile_options" do
    it "returns 0 for empty flag string" do
      expect(described_class.compile_options("")).to eq(0)
    end

    it "maps each letter to its Regexp bit" do
      expect(described_class.compile_options("i")).to eq(Regexp::IGNORECASE)
      expect(described_class.compile_options("m")).to eq(Regexp::MULTILINE)
      expect(described_class.compile_options("x")).to eq(Regexp::EXTENDED)
      expect(described_class.compile_options("imx"))
        .to eq(Regexp::IGNORECASE | Regexp::MULTILINE | Regexp::EXTENDED)
    end
  end

  describe ".apply" do
    it "returns the input untouched when flavor file is absent" do
      result = described_class.apply("NBS 1", :__nonexistent_flavor__)
      expect(result).to eq("NBS 1")
    end

    it "returns the input untouched when flavor has no substitutions" do
      # data/iso/update_codes.yaml only rewrites specific DIS/FDIS long
      # forms; a canonical input must pass through verbatim.
      expect(described_class.apply("ISO 9001:2015", :iso))
        .to eq("ISO 9001:2015")
    end

    it "applies ISO's regex substitution for DIS <type> long forms" do
      # YAML entry: "/DIS (?=ISP|TR|TS|PAS)/": "D" (drops the "IS ")
      expect(described_class.apply("ISO/IEC DIS TR 14143-5", :iso))
        .to eq("ISO/IEC DTR 14143-5")
    end
  end

  describe ".for_flavor" do
    it "caches the loaded YAML so string and symbol keys hit one entry" do
      first = described_class.for_flavor(:iso)
      second = described_class.for_flavor("iso")
      expect(first).to equal(second)
    end

    it "returns nil for flavors with no update_codes file" do
      expect(described_class.for_flavor(:__missing__)).to be_nil
    end
  end

  describe ".flavors" do
    it "includes :iso (has data/iso/update_codes.yaml)" do
      expect(described_class.flavors).to include(:iso)
    end

    it "excludes flavors without an update_codes.yaml" do
      expect(described_class.flavors).not_to include(:__missing__)
    end
  end
end
