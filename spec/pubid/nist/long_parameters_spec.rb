# frozen_string_literal: true

require "spec_helper"

RSpec.describe "NIST long-form parameters — issue #197" do
  describe "Volume with long-form 'Vol.' prefix" do
    it "parses 'Vol. 4' (period and space)" do
      parsed = Pubid::Nist.parse("NIST IR 8011 Vol. 4")
      expect(parsed.volume.value).to eq("4")
      expect(parsed.to_s).to eq("NIST IR 8011v4")
    end

    it "parses 'Vol.4' (period, no space)" do
      parsed = Pubid::Nist.parse("NIST IR 8011 Vol.4")
      expect(parsed.volume.value).to eq("4")
      expect(parsed.to_s).to eq("NIST IR 8011v4")
    end

    it "parses the short 'v4' form unchanged" do
      parsed = Pubid::Nist.parse("NIST IR 8011v4")
      expect(parsed.volume.value).to eq("4")
      expect(parsed.to_s).to eq("NIST IR 8011v4")
    end
  end

  describe "citation-form comma before long parameter prefixes" do
    it "strips comma before 'Rev.'" do
      parsed = Pubid::Nist.parse("NIST SP 800-53, Rev. 4")
      expect(parsed.revision).to eq("r4")
      expect(parsed.to_s).to eq("NIST SP 800-53 Rev. 4")
    end

    it "strips comma before 'Vol.'" do
      parsed = Pubid::Nist.parse("NIST IR 8011, Vol. 4")
      expect(parsed.volume.value).to eq("4")
      expect(parsed.to_s).to eq("NIST IR 8011v4")
    end

    it "strips comma before 'Part'" do
      parsed = Pubid::Nist.parse("NIST SP 800-57, Part 1")
      expect(parsed.to_s).to eq("NIST SP 800-57pt1")
    end

    it "leaves the no-comma form unchanged" do
      parsed = Pubid::Nist.parse("NIST SP 800-53 Rev. 4")
      expect(parsed.to_s).to eq("NIST SP 800-53 Rev. 4")
    end
  end
end
