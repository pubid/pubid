# frozen_string_literal: true

require "spec_helper"

Pubid.eager_load_flavors!

# Issue #644: `Pubid.parse` — the all-flavor prefix router — rejected printed
# forms that their OWN flavors parse fine. metanorma consumes pubid as the
# single source of truth, so a router-level rejection breaks consumers who
# only know the printed string. Each filed form here failed differently:
#
#   * "IETF RFC 2119"        — "IETF" was not a prefix, so the flavor's
#                              normalizing parse (external spelling in,
#                              canonical "RFC 2119" out) never earned the
#                              prefix-owner fallback the router reserves for
#                              flavors with a claim on the string;
#   * "3GPP TS 38.101"       — the routing table attributed "3GPP" to the
#                              derived key :tgpp while the flavor is
#                              registered as "3gpp", so the prefix resolved
#                              to no module at all;
#   * "BSI BS 5950"          — the flavor's own BSI-prefix strip accepted
#                              PAS/PD/DD/BIP but not the BS series, so the
#                              flavor itself rejected the prefixed spelling;
#   * BIPM "The International System of Units"
#                            — the quoted-title spelling had no mapping onto
#                              the parseable SI Brochure form.
#
# All of these are NORMALIZING parses on prefixed/title spellings: the input
# is a legitimate printed form, the canonical render differs from it, and the
# identifier reparses stably from its own canonical render. The byte-exact
# round trip the router prefers is preserved wherever the flavor's canonical
# render equals the input.
RSpec.describe "Pubid.parse routes flavor-legit printed forms (#644)" do
  # form => owning flavor module. Every entry asserts: the router hands the
  # string to the owning flavor, the canonical render reparses to an equal
  # identifier, and the with_publisher render (where the flavor defines one)
  # reproduces the input's own spelling.
  {
    "IETF RFC 2119" => Pubid::Ietf,
    "IETF RFC 8341" => Pubid::Ietf,
    "BSI BS 5950" => Pubid::Bsi,
    "BSI PAS 2031:2019" => Pubid::Bsi,
    "3GPP TS 38.101" => Pubid::Tgpp,
    "3GPP TS 23.207" => Pubid::Tgpp,
    'BIPM "The International System of Units"' => Pubid::Bipm,
    # Adjacent BIPM routing gaps fixed with the same prefix-table entries:
    # these printed forms parsed directly but the router could not route them.
    "SI Brochure 9e v3.01 (2019/2024, E)" => Pubid::Bipm,
    "SI Brochure Part 1" => Pubid::Bipm,
    "SI MEP 10" => Pubid::Bipm,
  }.each do |form, flavor|
    it "routes #{form.inspect} to #{flavor.name.split('::').last}" do
      parsed = Pubid.parse(form)

      expect(parsed).to be_a(flavor.const_get(:Identifier))
    end

    it "#{form.inspect} reparses stably from its canonical render" do
      parsed = Pubid.parse(form)
      reparsed = Pubid.parse(parsed.to_s)

      expect(reparsed).to eq(parsed)
    end

    it "#{form.inspect} round-trips through with_publisher when it " \
       "prints the prefix" do
      parsed = Pubid.parse(form)

      expect(parsed.to_s(with_publisher: true))
        .to(eq(parsed.to_s).or(eq(form)))
    end
  end

  # The exact-input round trips among them — where the flavor's canonical
  # render equals the printed input byte for byte. 3GPP and IETF print the
  # bare designation as their canonical form (the prefix is the publisher,
  # restored only by with_publisher: true), and the quoted title normalizes
  # onto the SI Brochure section form.
  {
    "3GPP TS 23.207" => "TS 23.207",
    "IETF RFC 2119" => "RFC 2119",
    "BSI BS 5950" => "BS 5950",
    'BIPM "The International System of Units"' => "BIPM SI Brochure",
    "SI Brochure Part 1" => "BIPM SI Brochure Part 1",
    "SI MEP 10" => "SI MEP 10",
  }.each do |form, rendered|
    it "renders #{form.inspect} canonically as #{rendered.inspect}" do
      expect(Pubid.parse(form).to_s).to eq(rendered)
    end
  end

  # The external spellings the flavor itself prints back: with_publisher: true
  # reproduces the input byte for byte where the prefix is part of the
  # external form (the IETF and 3GPP prefixed spellings; the BSI BS series is
  # never printed with the BSI prefix, and the quoted title normalizes).
  {
    "IETF RFC 2119" => Pubid::Ietf,
    "3GPP TS 38.101" => Pubid::Tgpp,
    "BSI PAS 2031:2019" => Pubid::Bsi,
  }.each do |form, flavor|
    it "#{form.inspect} is the with_publisher external form of " \
       "#{flavor.name.split('::').last}" do
      expect(Pubid.parse(form).to_s(with_publisher: true)).to eq(form)
    end
  end

  # Controls from the issue that must keep passing unchanged.
  {
    "ISO 123" => Pubid::Iso,
    "IEEE Std 802.11-2020" => Pubid::Ieee,
    "ITU-T G.711" => Pubid::Itu,
    "NIST SP 800-53" => Pubid::Nist,
    "CIE S 026:2018" => Pubid::Cie,
    "CCSDS 100.0-G-1" => Pubid::Ccsds,
    "OGC 06-121r9" => Pubid::Ogc,
    "BS 5950" => Pubid::Bsi,
    "RFC 2119" => Pubid::Ietf,
    "Metrologia 55 1A 06007" => Pubid::Bipm,
    "CCTF REC 2 (1999)" => Pubid::Bipm,
  }.each do |ref, flavor|
    it "still routes the control #{ref.inspect} to " \
       "#{flavor.name.split('::').last}" do
      expect(Pubid.parse(ref)).to be_a(flavor.const_get(:Identifier))
    end
  end

  # The unclaimed-string guarantees the router documents must survive the new
  # prefixes: an added prefix never turns a prefix into a wildcard. (Bare
  # "BSI" already parsed as a degenerate British Standard before #644 and is
  # left as it is.)
  it "still rejects strings no flavor owns" do
    expect { Pubid.parse("IETF") }.to raise_error(Pubid::Errors::ParseError)
    expect { Pubid.parse("3GPP") }.to raise_error(Pubid::Errors::ParseError)
    expect { Pubid.parse("BIPM") }.to raise_error(Pubid::Errors::ParseError)
    expect { Pubid.parse("SI") }.to raise_error(Pubid::Errors::ParseError)
    expect { Pubid.parse("SI Index") }.to raise_error(Pubid::Errors::ParseError)
    expect { Pubid.parse("SI BrochureX") }.to raise_error(Pubid::Errors::ParseError)
    expect { Pubid.parse('BIPM "Some Other Title"') }
      .to raise_error(Pubid::Errors::ParseError)
  end
end
