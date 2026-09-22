# frozen_string_literal: true

require "spec_helper"

# `Identifier.all_parts_edition_keys` defaults to %i[date year edition
# version] (lib/pubid/identifier.rb). OGC (spec/pubid/ogc/all_parts_spec.rb)
# and 3GPP (spec/pubid/tgpp/all_parts_spec.rb) each needed an override
# because their real edition/version discriminator lives under a
# non-default attribute name. Review of this change found the same shape
# in two more flavors outside the hand-off's original audit list: IEEE
# (`revision`, `reaffirmed`, `edition_month`) and AMCA (`revision` on
# Publication, `reaffirmed` on the shared base, covering Standard too). A
# first review pass caught `revision` on both but missed the other two —
# proof that "one attribute found, audit closed" is not a safe stopping
# point; a flavor with N candidate discriminator-shaped attributes needs
# each one checked against its renderer/builder, not just the first hit.
#
# The hand-off that raised OGC/3GPP also asked to audit every other
# flavor that falls back to the generic Pubid::AllPartsIdentifier for the
# same class of gap. This spec is that audit, made durable: one case per
# flavor, each building two identifiers of the SAME base document that
# differ only in the flavor's date/edition/version discriminator (so they
# are NOT equal before wrapping) and asserting #to_all_parts collapses
# them to the same identity. A future change that reintroduces the gap in
# any of these flavors turns this spec red.
RSpec.describe "all_parts_edition_keys audit" do
  def assert_collapses(ref, other)
    expect(ref).not_to eq(other)
    expect(ref.to_all_parts.to_s).to eq(other.to_all_parts.to_s)
    expect(ref.to_all_parts === other).to be true
  end

  # Confirmed fine: each of these already names its discriminator `date`,
  # `year`, `edition` or `version`, so the default list already covers it.
  it "BSI (date)" do
    assert_collapses(Pubid::Bsi::Identifier.parse("BS EN 1325-1:1996"),
                     Pubid::Bsi::Identifier.parse("BS EN 1325-1:2004"))
  end

  it "CEN/CENELEC (year)" do
    assert_collapses(Pubid::CenCenelec::Identifier.parse("EN 1325-1:1996"),
                     Pubid::CenCenelec::Identifier.parse("EN 1325-1:2004"))
  end

  it "GOST (year)" do
    assert_collapses(Pubid::Gost::Identifier.parse("GOST 14946-82"),
                     Pubid::Gost::Identifier.parse("GOST 14946-91"))
  end

  it "IALA (edition)" do
    assert_collapses(Pubid::Iala::Identifier.parse("IALA C0103-1 Ed 3.0"),
                     Pubid::Iala::Identifier.parse("IALA C0103-1 Ed 2.0"))
  end

  it "CCSDS (edition)" do
    assert_collapses(Pubid::Ccsds::Identifier.parse("CCSDS 120.0-G-4"),
                     Pubid::Ccsds::Identifier.parse("CCSDS 120.0-G-5"))
  end

  it "ADOBE (version)" do
    assert_collapses(Pubid::Adobe::Identifiers::Publication.parse("adobe-japan1-6"),
                     Pubid::Adobe::Identifiers::Publication.parse("adobe-japan1-7"))
  end

  it "IHO (version)" do
    assert_collapses(Pubid::Iho::Identifier.parse("IHO S-100 Part 1 1.0.0"),
                     Pubid::Iho::Identifier.parse("IHO S-100 Part 1 2.0.0"))
  end

  it "OIML (date)" do
    assert_collapses(Pubid::Oiml::SingleIdentifier.parse("OIML B 18:2018"),
                     Pubid::Oiml::SingleIdentifier.parse("OIML B 18:2004"))
  end

  it "EASC (year)" do
    assert_collapses(Pubid::Easc::Identifier.parse("PMG 03-2025"),
                     Pubid::Easc::Identifier.parse("PMG 03-2013"))
  end

  it "ECMA (edition)" do
    assert_collapses(Pubid::Ecma::Identifier.parse("ECMA-262 ed1"),
                     Pubid::Ecma::Identifier.parse("ECMA-262 ed2"))
  end

  it "JCGM (date)" do
    assert_collapses(Pubid::Jcgm::SingleIdentifier.parse("JCGM 100:2008"),
                     Pubid::Jcgm::SingleIdentifier.parse("JCGM 100:2012"))
  end

  # NOT already fine: NIST's Letter Circular / Circular "rJun1992"-style
  # revision parses into `update`/`update_component` (Components::Update),
  # a discriminator the default list misses entirely (`edition` alone does
  # not cover it — see Pubid::Nist::Identifier.all_parts_edition_keys).
  it "NIST (update/update_component)" do
    assert_collapses(Pubid::Nist::Identifier.parse("NBS LC 800 rJun1992"),
                     Pubid::Nist::Identifier.parse("NBS LC 800 rJul1995"))
  end

  # NIST's `edition_year` looked like a second gap but is not: the builder
  # sets it only ever alongside the real `edition` component (never as its
  # sole carrier), so stripping `edition` already collapses this case with
  # no NIST-specific key needed for it.
  it "NIST (edition_year is redundant with edition, not a separate gap)" do
    assert_collapses(Pubid::Nist::Identifier.parse("NIST TN 2000-1993"),
                     Pubid::Nist::Identifier.parse("NIST TN 2000-1994"))
  end

  # Not on the hand-off's original list, found by review: IEEE's `revision`
  # (e.g. "2" in "P802.16Rev2") is a separate discriminator from
  # `edition`/`year` and the default list missed it.
  it "IEEE (revision)" do
    assert_collapses(Pubid::Ieee::Identifier.parse("IEEE P802.16Rev2"),
                     Pubid::Ieee::Identifier.parse("IEEE P802.16Rev3"))
  end

  # Found in code review of the first pass: `revision` was not IEEE's only
  # gap. `reaffirmed` (the "(R2010)" year) is read by renderer.rb and
  # urn_generator.rb, so two reaffirmations of the same standard failed to
  # collapse.
  it "IEEE (reaffirmed)" do
    assert_collapses(
      Pubid::Ieee::Identifier.parse(
        "IEEE Std 218-1956 (R1980) (Revision of IEEE Std 218-1956)",
      ),
      Pubid::Ieee::Identifier.parse(
        "IEEE Std 218-1956 (R1990) (Revision of IEEE Std 218-1956)",
      ),
    )
  end

  # Found in code review: `edition_month`, the month half of "Edition N
  # YYYY-MM" (renderer.rb), survived even though its sibling `year` is
  # already in the default list.
  it "IEEE (edition_month)" do
    assert_collapses(
      Pubid::Ieee::Identifier.parse("IEEE Std 802.11 Edition 3.0 2015-03"),
      Pubid::Ieee::Identifier.parse("IEEE Std 802.11 Edition 3.0 2015-06"),
    )
  end

  # Not on the hand-off's original list, found by review: AMCA
  # Publication's `revision` is a separate discriminator the default list
  # missed. Declared only on Identifiers::Publication (not the shared
  # base), since Standard/Interpretation don't carry it.
  it "AMCA (revision)" do
    assert_collapses(
      Pubid::Amca::Identifier.parse("AMCA Publication 211-22 (Rev. 01-23)"),
      Pubid::Amca::Identifier.parse("AMCA Publication 211-22 (Rev. 02-23)"),
    )
  end

  # Found in code review of the first pass: `reaffirmed` (the "(R2010)"
  # year) is declared on the shared Pubid::Amca::Identifier base and read
  # by Renderer#render_base for BOTH Standard and Publication, so it needed
  # its own override there, not just Publication's `revision` one.
  it "AMCA Standard (reaffirmed)" do
    assert_collapses(Pubid::Amca::Identifier.parse("AMCA 210-16 (R2010)"),
                     Pubid::Amca::Identifier.parse("AMCA 210-16 (R2015)"))
  end

  it "AMCA Publication (reaffirmed)" do
    assert_collapses(
      Pubid::Amca::Identifier.parse("AMCA Publication 311-16 (R2020)"),
      Pubid::Amca::Identifier.parse("AMCA Publication 311-16 (R2021)"),
    )
  end
end
