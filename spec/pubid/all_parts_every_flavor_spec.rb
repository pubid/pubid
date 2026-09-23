# frozen_string_literal: true

require "spec_helper"

# Every flavor reads the "(all parts)" print and round-trips it: parse
# wraps in the flavor's all-parts class (or the generic one), and parsing
# the wrapper's own print yields the wrapper again. The shared Grammar
# strips the trailing suffix; every Builder routes the marker to
# #to_all_parts (Pubid::Builder::AllPartsWrap). Samples come from each
# flavor's own suite fixtures.
RSpec.describe "all parts in every flavor" do
  SAMPLES = {
"Pubid::Adobe::Identifier" => "Adobe TN 5014",
"Pubid::Amca::Identifier" => "AMCA Publication 311-16",
"Pubid::Ansi::Identifier" => "ANSI X3.4:1963",
"Pubid::Api::Identifier" => "API RP 500",
"Pubid::Ashrae::Identifier" => "ASHRAE Guideline 14-2002 Errata (October 10, 2008)",
"Pubid::Asme::Identifier" => "ASME B16.5-2020",
"Pubid::Astm::Identifier" => "ASTM 52303-24e1",
"Pubid::Bipm::Identifier" => "CCTF REC 2 (2012)",
"Pubid::Calconnect::Identifier" => "CC/WD 51017:2024-07-23",
"Pubid::Ccsds::Identifier" => "CCSDS 120.0-G-4",
"Pubid::CenCenelec::Identifier" => "EN 13480",
"Pubid::Cie::Identifier" => "CIE 015",
"Pubid::Csa::Identifier" => "CSA Z299.1",
"Pubid::Doi::Identifier" => "doi:10.1000/182",
"Pubid::Easc::Identifier" => "ПМГ 03-2025",
"Pubid::Ecma::Identifier" => "ECMA-269 ed3",
"Pubid::Etsi::Identifier" => "ETSI EN 300 058-3 V1.2.4 (1998-06)",
"Pubid::Evs::Identifier" => "EVS-EN 18216:2026",
"Pubid::Gb::Identifier" => "GB/T 20223-2006",
"Pubid::Gost::Identifier" => "GOST R 34.12-2015",
"Pubid::Iala::Identifier" => "IALA S1070 Ed 9.0",
"Pubid::Iana::Identifier" => "IANA IPv4-special-registry",
"Pubid::Idf::Identifier" => "IDF 125:1988/AMD 1:2023",
"Pubid::Iec::Identifier" => "IEC 80000",
"Pubid::Ieee::Identifier" => "AIEE No 431 (105) -1958",
"Pubid::Ietf::Identifier" => "RFC 1",
"Pubid::Iho::Identifier" => "IHO S-5",
"Pubid::Isbn::Identifier" => "ISBN 978-3-16-148410-0",
"Pubid::Iso::Identifier" => "ISO 9001:2015/Add 1:2020",
"Pubid::Itu::Identifier" => "ITU-T G.650",
"Pubid::Jcgm::Identifier" => "JCGM 11st Meeting",
"Pubid::Jis::Identifier" => "JIS C 0617-2",
"Pubid::Nist::Identifier" => "NIST SP 800-53r5",
"Pubid::Oasis::Identifier" => "OASIS amqp-core",
"Pubid::Ogc::Identifier" => "OGC 06-121r3",
"Pubid::Oiml::Identifier" => "OIML R 106",
"Pubid::Omg::Identifier" => "OMG AMI4CCM 1.0",
"Pubid::Sae::Identifier" => "SAE J300",
"Pubid::Tgpp::Identifier" => "3GPP TS 23.207:REL-4/4.0.0",
"Pubid::Un::Identifier" => "TRADE/CEFACT/2004/32",
"Pubid::W3c::Identifier" => "W3C WD-charmod-19991129",
"Pubid::Xsf::Identifier" => "XEP 0060",
  }.freeze

  SAMPLES.each do |klass_name, reference|
    describe klass_name do
      let(:klass) { Object.const_get(klass_name) }

      it "parses '#{reference} (all parts)' into an all-parts identifier" do
        identifier = klass.parse("#{reference} (all parts)")

        # JIS prints its own all-parts suffix; the semantic contract is the flag.
        expect(identifier.all_parts?).to be(true)
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
