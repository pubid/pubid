# frozen_string_literal: true

require "spec_helper"

# The GOST wave of the pubid-scheme URN (issue #656). The current urn:gost:
# form of #to_urn is pubid-invented and is not touched here.
RSpec.describe "GOST pubid-scheme URN" do
  def expect_round_trip(string)
    id = Pubid::Gost.parse(string)
    back = Pubid.parse_urn(id.to_pubid_urn)
    expect(back).to be_a(id.class)
    expect(back.to_hash).to eq(id.to_hash)
    expect(back.to_s).to eq(id.to_s)
  end

  {
    "ГОСТ ISO 6848" => "urn:pubid:gost:is:6848:co-ISO",
    "ГОСТ Р 71039—2023" => "urn:pubid:gost:ns:71039:year-2023",
    "ГОСТ Р 58904-2020/ISO/TR 25901-1:2016" =>
      "urn:pubid:gost:ns:58904:year-2020:ia:58904:year-2020:" \
      "adopted-(iso:tr:25901:part-1:year-2016)",
    "ГОСТ 31610.11-2025 (IEC 60079-11:2023)" =>
      "urn:pubid:gost:is:31610.11:year-2025:h:31610.11:year-2025:" \
      "adoptedidentifiers-(iec:is:60079:part-11:year-2023)",
    "ГОСТ 1437-2024 (ASTM D129-18)" =>
      "urn:pubid:gost:is:1437:year-2024:h:1437:year-2024:" \
      "adoptedidentifiers-(astm:std:129:letter-D:year-2018)",
  }.each do |input, urn|
    it "renders #{input} as #{urn}" do
      expect(Pubid::Gost.parse(input).to_pubid_urn).to eq(urn)
    end

    it "round-trips #{input}" do
      expect_round_trip(input)
    end
  end

  # The CEN/CENELEC documents GOST adopts use the partial cencenelec
  # schema, a consolidated one included.
  it "nests an adopted EN and a consolidated EN with the CEN schema" do
    expect(Pubid::Gost.parse("ГОСТ 35311.2-2025 (EN 1129-2:1995)")
      .to_pubid_urn).to end_with(
        "adoptedidentifiers-(cencenelec:en:1129:part-2:year-1995)",
      )
    input = "ГОСТ 35292-2025 (EN 14988:2017+A1:2020)"
    expect(Pubid::Gost.parse(input).to_pubid_urn).to end_with(
      "adoptedidentifiers-(cencenelec:consol:ids-" \
      "(cencenelec:en:14988:year-2017),(cencenelec:amd:1:year-2020))",
    )
    expect_round_trip(input)
  end

  # Adoptions outside the pass fixtures: each nested type of CEN and IEC a
  # GOST adoption can name has a place in the partial schemas.
  {
    "ГОСТ Р 59000-2020/EN ISO 12100:2010" =>
      "adopted-(cencenelec:aen:adopted-(iso:is:12100:year-2010))",
    "ГОСТ 33000-2014 (EN IEC 1234:2010)" =>
      "adoptedidentifiers-(cencenelec:aen:adopted-(iec:is:1234:year-2010))",
    "ГОСТ 33000-2014 (CEN/TS 1234:2010)" =>
      "adoptedidentifiers-(cencenelec:ts:1234:pub-CEN:year-2010)",
    "ГОСТ 33000-2014 (CEN/TR 1234:2010)" =>
      "adoptedidentifiers-(cencenelec:tr:1234:pub-CEN:year-2010)",
    "ГОСТ 33000-2014 (EN 1234:2010/AC:2013)" =>
      "adoptedidentifiers-(cencenelec:en:1234:year-2010:cor:year-2013)",
    "ГОСТ 33000-2014 (EN 1234:2010/A1:2012)" =>
      "adoptedidentifiers-(cencenelec:en:1234:year-2010:amd:1:year-2012)",
    "ГОСТ 33000-2014 (IEC/TS 60079-32-1:2013)" =>
      "adoptedidentifiers-(iec:ts:60079:part-32:subpart-1:year-2013)",
    "ГОСТ 33000-2014 (IEC/TR 60079-32-1:2013)" =>
      "adoptedidentifiers-(iec:tr:60079:part-32:subpart-1:year-2013)",
    "ГОСТ 33000-2014 (IEC 60079-0:2017+AMD1:2020)" =>
      "adoptedidentifiers-(iec:consol:ids-(iec:is:60079:part-0:year-2017)," \
      "(iec:amd:1:year-2020))",
  }.each do |input, tail|
    it "nests the adopted document of #{input}" do
      expect(Pubid::Gost.parse(input).to_pubid_urn).to end_with(tail)
      expect_round_trip(input)
    end
  end

  # Pinned, not fixed here: ForeignReference#raw is not in #to_hash, so two
  # adoptions of different unregistered documents share one hash and one
  # URN. The "raw" atom is declared for the day the hash carries it.
  it "gives two foreign references one URN while to_hash drops raw" do
    a = Pubid::Gost.parse("ГОСТ 34853-2022 (OECD 460:2017)")
    b = Pubid::Gost.parse("ГОСТ 34853-2022 (OECD 999:2020)")
    expect(a.to_s).not_to eq(b.to_s)
    expect(a.to_pubid_urn).to eq(b.to_pubid_urn)
  end
end
