# frozen_string_literal: true

require "spec_helper"

# pubid#488: CEI is IEC's French spelling — French-language IEC documents
# print "CEI …" identifiers. It parses as the IEC publisher and prints IEC.
# The token list is asserted in full so a grammar rewrite cannot silently
# drop a publisher spelling again.
RSpec.describe Pubid::Iec::Identifier do
  describe "publisher spellings" do
    SOLE_PUBLISHER_TOKENS = %w[
      IECQ\ OD IECQ\ CS IEC\ CAB IEC\ CA IECRE CISPR IECEE IECEx IECQ IEC ISO CEI
    ].freeze

    it "parses every sole-publisher token" do
      SOLE_PUBLISHER_TOKENS.each do |token|
        expect(described_class.parse("#{token} 1000-1:2020").to_s)
          .to eq(token == "CEI" ? "IEC 1000-1:2020" : "#{token} 1000-1:2020")
      end
    end

    it "parses the French CEI spelling and prints IEC" do
      expect(described_class.parse("CEI 62303:2008").to_s).to eq("IEC 62303:2008")
      expect(described_class.parse("CEI 62303").to_s).to eq("IEC 62303")
    end
  end

  # pubid#491: IEC house style joins multiple language codes with '-'
  # ("IEC 60050-103:2020(en-fr)"), matching pubid-iec 1.x and
  # metanorma-iec's fixtures; the ',' spelling stays accepted.
  describe "language joining" do
    it "renders the house-style dash join" do
      expect(described_class.parse("IEC 60050-103:2020(en-fr)").to_s)
        .to eq("IEC 60050-103:2020(en-fr)")
    end

    it "canonicalizes the comma spelling onto the dash join" do
      expect(described_class.parse("IEC 60050-103:2020(en,fr)").to_s)
        .to eq("IEC 60050-103:2020(en-fr)")
    end
  end
end
