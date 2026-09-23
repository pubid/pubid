# frozen_string_literal: true

require "spec_helper"

# Every flavor reads the "(all parts)" print and round-trips it: parse
# wraps in the flavor's all-parts class (or the generic one), and parsing
# the wrapper's own print yields the wrapper again. The shared Grammar
# strips the trailing suffix; every Builder routes the marker to
# #to_all_parts (Pubid::Builder::AllPartsWrap).
RSpec.describe "all parts in every flavor" do
  SAMPLES = {
    "Pubid::Iso::Identifier" => "ISO 123",
    "Pubid::Iec::Identifier" => "IEC 60050",
    "Pubid::Ieee::Identifier" => "IEEE Std 802.1",
    "Pubid::Gost::Identifier" => "GOST R 34.12",
    "Pubid::Iala::Identifier" => "IALA S1070 Ed 9.0",
    "Pubid::Ccsds::Identifier" => "CCSDS 130.0-G-2",
    "Pubid::Nist::Identifier" => "NIST SP 800-53",
    "Pubid::Bsi::Identifier" => "BS 5250",
    "Pubid::Iho::Identifier" => "IHO S-5",
    "Pubid::Itu::Identifier" => "ITU-T G.650",
    "Pubid::Iana::Identifier" => "IANA IPv4-special-registry",
    "Pubid::Adobe::Identifier" => "Adobe TN 5014",
    "Pubid::CenCenelec::Identifier" => "EN 13480",
  }.freeze

  SAMPLES.each do |klass_name, reference|
    describe klass_name do
      let(:klass) { Object.const_get(klass_name) }

      it "parses '#{reference} (all parts)' into an all-parts identifier" do
        identifier = klass.parse("#{reference} (all parts)")

        expect(identifier.all_parts?).to be(true)
        expect(identifier.to_s).to end_with("(all parts)")
      end

      it "round-trips the wrapper's own print" do
        once = klass.parse("#{reference} (all parts)")

        expect(klass.parse(once.to_s).all_parts?).to be(true)
      end

      it "does not mark the bare reference" do
        expect(klass.parse(reference).all_parts?).to be(false)
      end
    end
  end
end
