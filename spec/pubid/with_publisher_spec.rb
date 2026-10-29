# frozen_string_literal: true

require "spec_helper"

Pubid.eager_load_flavors!

# `to_s(with_publisher:)` is the render half of relaton#49: relaton keeps the
# POLICY (which SDOs cite their own documents without the publisher prefix),
# pubid supplies the MECHANISM (render with or without that prefix).
#
# * `with_publisher: false` drops the publisher token and its separator;
# * `with_publisher: true` renders the full external form, also for a flavor
#   whose default omits the prefix;
# * the option omitted is the default render, byte for byte.
#
# A series token that is part of the designation is NOT a publisher prefix:
# `BS 8611`, `ECMA-262`, `XEP 0001` and `GB/T 20223` keep it.
RSpec.describe "to_s(with_publisher:)" do
  def render(flavor, input, with_publisher)
    Pubid::Registry.get(flavor).parse(input).to_s(with_publisher:)
  end

  {
    # [flavor, input, with_publisher] => expected
    ["nist", "NIST SP 800-113", false] => "SP 800-113",
    ["nist", "NIST SP 800-113", true] => "NIST SP 800-113",
    ["nist", "NBS CIRC 25sup", false] => "CIRC 25sup",
    ["nist", "NIST FIPS 197/Upd1 ipd", false] => "FIPS 197/Upd1 ipd",
    ["bipm", "BIPM SI Brochure Part 1", false] => "SI Brochure Part 1",
    ["bipm", "BIPM SI Brochure Part 1", true] => "BIPM SI Brochure Part 1",
    ["bipm", "CGPM RES (1889)", false] => "CGPM RES (1889)",
    ["ietf", "draft-ietf-quic-transport-34", true] =>
      "IETF Internet-Draft draft-ietf-quic-transport-34",
    ["ietf", "draft-ietf-quic-transport-34", false] =>
      "Internet-Draft draft-ietf-quic-transport-34",
    ["ietf", "RFC 8341", true] => "IETF RFC 8341",
    ["ietf", "RFC 8341", false] => "RFC 8341",
    ["bsi", "BSI PAS 2031:2019", false] => "PAS 2031:2019",
    ["bsi", "PAS 2031:2019", true] => "BSI PAS 2031:2019",
    ["bsi", "PD 6688-1:2011", true] => "BSI PD 6688-1:2011",
    ["bsi", "BS 8611:2016", false] => "BS 8611:2016",
    ["ieee", "IEEE 802.3-2018", false] => "Std 802.3-2018",
    ["3gpp", "3GPP TS 23.207", true] => "3GPP TS 23.207",
    ["3gpp", "3GPP TS 23.207", false] => "TS 23.207",
    ["iso", "ISO 8601-1:2019", false] => "8601-1:2019",
    ["iso", "ISO 8601-1:2019", true] => "ISO 8601-1:2019",
    ["iso", "ISO/IEC 27001:2013", false] => "27001:2013",
    ["iec", "IEC 60050-101:1998", false] => "60050-101:1998",
    ["itu", "ITU-T G.711", false] => "G.711",
    ["etsi", "ETSI EN 300 328 V2.2.2 (2019-07)", false] =>
      "EN 300 328 V2.2.2 (2019-07)",
    ["gb", "GB/T 20223-2006", false] => "GB/T 20223-2006",
    ["oiml", "OIML R 76-1:2006", false] => "R 76-1:2006",
    ["ecma", "ECMA-262", false] => "ECMA-262",
    ["xsf", "XEP 0001", false] => "XEP 0001",
    ["gost", "GOST 26951-2025", false] => "GOST 26951-2025",
    ["cen_cenelec", "EN 13256:2000", false] => "EN 13256:2000",
    ["cen_cenelec", "CEN/TS 16931-3-1:2017", false] => "TS 16931-3-1:2017",
    ["cen_cenelec", "CEN ISO/TS 12180-1:2007", false] => "ISO/TS 12180-1:2007",
    ["csa", "CSA B149.1:20", false] => "B149.1:20",
    ["csa", "CAN/CSA-ISO 11140-4:18 (R2023)", false] =>
      "ISO 11140-4:18 (R2023)",
    ["evs", "EVS-EN 18216:2026", false] => "EN 18216:2026",
    ["omg", "OMG UML 2.5.1", false] => "UML 2.5.1",
    ["amca", "ANSI/AMCA Standard 210-16", false] => "Standard 210-16",
    ["iec", "ISO/IEC 8825-3:2002", false] => "8825-3:2002",
    ["iso", "ISO 10231:2003/Amd 1:2015", false] => "10231:2003/Amd 1:2015",
    ["iso", "ISO Guide 73:2009", false] => "Guide 73:2009",
    ["nist", "NIST.IR.8115r1/Upd1", false] => "IR 8115r1/Upd1",
    ["itu", "ITU-T A.23 Annex A (06/2014)", false] => "A.23 Annex A (06/2014)",
    ["cen_cenelec", "CEN/CLC/ETSI/TR 101551:2026", false] =>
      "TR 101551:2026",
    ["cie", "CIE ISO 10916:2024", false] => "10916:2024",
    ["oiml", "OIML-CS PD-05 Edition 6 (Amendment 1)", false] =>
      "PD-05 Edition 6 (Amendment 1)",
    ["bipm", "BIPM SI MEP Cd1 Appendix 2 Part 7.1", false] =>
      "SI MEP Cd1 Appendix 2 Part 7.1",
  }.each do |(flavor, input, with_publisher), expected|
    it "#{flavor}: #{input.inspect} with_publisher: #{with_publisher}" do
      expect(render(flavor, input, with_publisher)).to eq(expected)
    end
  end

  describe "IETF prefixed input" do
    [
      "IETF Internet-Draft draft-ietf-quic-transport-34",
      "IETF I-D draft-ietf-quic-transport-34",
      "Internet-Draft draft-ietf-quic-transport-34",
      "I-D draft-ietf-quic-transport-34",
    ].each do |input|
      it "parses #{input.inspect} as the bare draft" do
        id = Pubid::Ietf.parse(input)
        expect(id).to eq(Pubid::Ietf.parse("draft-ietf-quic-transport-34"))
        expect(id.to_s).to eq("draft-ietf-quic-transport-34")
      end
    end

    it "parses \"IETF RFC 8341\" as the bare RFC" do
      expect(Pubid::Ietf.parse("IETF RFC 8341").to_s).to eq("RFC 8341")
    end
  end

  describe "BSI prefixed input" do
    it "parses \"BSI PD 6688-1:2011\" as the bare PD" do
      expect(Pubid::Bsi.parse("BSI PD 6688-1:2011"))
        .to eq(Pubid::Bsi.parse("PD 6688-1:2011"))
    end
  end

  it "leaves the machine-readable form alone" do
    id = Pubid::Iso.parse("ISO 8601-1:2019")
    expect(id.render(format: :mr_string, with_publisher: false))
      .to eq(id.to_mr_string)
  end

  it "leaves the NIST MR style alone" do
    id = Pubid::Nist.parse("NIST SP 800-113")
    expect(id.to_s(format: :mr, with_publisher: false))
      .to eq(id.to_s(format: :mr))
  end

  it "composes with annotation" do
    out = Pubid::Iso.parse("ISO 8601-1:2019")
      .to_s(with_publisher: false, annotated: true)
    expect(out.gsub(%r{</?span[^>]*>}, "")).to eq("8601-1:2019")
    expect(out).not_to include("ISO")
  end
end
