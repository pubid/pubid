# frozen_string_literal: true

require "spec_helper"

Pubid.eager_load_flavors!

# Prefix auto-routing (pubid#360 item 6b).
#
# `Pubid.parse` used to raise `No flavor specified` for any human-readable
# string, so there was no way to parse a reference whose flavor you did not
# already know. pubid 1.x had `Pubid::Registry.parse`, which isodoc still
# calls (isodoc's presentation_function/docid_semantic.rb).
#
# The routing table is not new — `Pubid.prefix_flavors` already maps every
# leading prefix token to its owning flavor(s). This wires it to `parse`.
RSpec.describe "Pubid.parse prefix routing" do
  {
    "ISO 1234-1:2013" => Pubid::Iso,
    "IEC 60038:2009" => Pubid::Iec,
    "IEEE Std 802.11-2020" => Pubid::Ieee,
    "ITU-T G.711" => Pubid::Itu,
    "ETSI EN 300 175-1 V2.1.1" => Pubid::Etsi,
    "JCGM 100:2008" => Pubid::Jcgm,
    "BS 5555:1981" => Pubid::Bsi,
  }.each do |ref, mod|
    it "routes #{ref} to #{mod}" do
      expect(Pubid.parse(ref)).to be_a(mod.const_get(:Identifier))
    end

    it "#{ref} renders back byte-identically" do
      expect(Pubid.parse(ref).to_s).to eq(ref)
    end
  end

  # A co-published prefix belongs to more than one flavor. Whichever wins, the
  # result must render back to the input — that is the property a consumer
  # depends on, not the class.
  it "routes a co-published prefix" do
    expect(Pubid.parse("ISO/IEC 2131:2013").to_s).to eq("ISO/IEC 2131:2013")
  end

  it "still routes a URN" do
    expect(Pubid.parse("urn:iso:std:iso:1234:-1:ed-1")).to be_a(Pubid::Iso::Identifier)
  end

  it "raises Parslet::ParseFailed when no flavor can parse it" do
    expect { Pubid.parse("@@@ not an identifier @@@") }
      .to raise_error(Parslet::ParseFailed)
  end

  # Routing must not become a place where a real defect looks like a rejection.
  # Only Parslet::ParseFailed means "not this flavor"; a blanket
  # `rescue StandardError` in the candidate loop would swallow the
  # `ArgumentError: unknown attribute…` that the constructor contract raises —
  # the error that turned three silent data-loss bugs into visible ones — and
  # report it as "no registered flavor could parse". The previous version of
  # this file could not tell the two apart, because the observable outcome is
  # the same either way.
  describe "does not disguise a defect as a rejection" do
    it "propagates a non-parse error raised by a candidate flavor" do
      allow(Pubid::Iso).to receive(:parse)
        .and_raise(ArgumentError, "unknown attribute for X: bogus")

      expect { Pubid.parse("ISO 1234:2013") }
        .to raise_error(ArgumentError, /unknown attribute/)
    end

    it "still reports a genuine rejection as Parslet::ParseFailed" do
      expect { Pubid.parse("@@@ still not an identifier @@@") }
        .to raise_error(Parslet::ParseFailed)
    end
  end

  it "keeps the input guards" do
    expect { Pubid.parse(nil) }.to raise_error(ArgumentError)
    expect { Pubid.parse("A#{'9' * Pubid::MAX_INPUT_LENGTH}") }
      .to raise_error(ArgumentError)
  end

  it "never returns nil" do
    expect(Pubid.parse("ISO 1234:2013")).not_to be_nil
  end

  # Some grammars accept any slug by design (adobe, iana). Without a
  # preference for an exact round trip, whichever of those comes first in
  # registry order claims every string no prefix matched — inventing structure
  # the input never had.
  describe "prefers the flavor that reproduces the input exactly" do
    {
      "ECMA-262" => Pubid::Ecma,
      "JIS B 0001:2019" => Pubid::Jis,
    }.each do |ref, mod|
      it "routes #{ref} to #{mod.name.split('::').last} and round-trips it" do
        parsed = Pubid.parse(ref)

        expect(parsed).to be_a(mod.const_get(:Identifier))
        expect(parsed.to_s).to eq(ref)
      end
    end

    # A flavor that normalises on render still wins on its own prefix — OGC
    # prints `06-121r9` for `OGC 06-121r9`, so the round trip cannot be a
    # requirement, only a preference.
    it "still routes a flavor that normalises its own rendering (OGC)" do
      expect(Pubid.parse("OGC 06-121r9")).to be_a(Pubid::Ogc::Identifier)
    end

    # `adobe` and `iana` accept any slug by design, so before they were
    # excluded from the fallback whichever came first in registry order
    # claimed this and answered `IANA iec.60050`.
    it "reports failure rather than inventing a flavor for an unclaimed string" do
      expect { Pubid.parse("iec.60050") }.to raise_error(Parslet::ParseFailed)
    end

    # The any-slug flavors are found by probing, not by a hardcoded list, so
    # this stays correct if a grammar changes. They must still parse their own
    # identifiers when asked directly.
    it "still lets an any-slug flavor parse through its own module" do
      expect(Pubid::Iana.parse("IANA iec.60050")).to be_a(Pubid::Iana::Identifier)
    end
  end

  # `Pubid::Parsers::MrString.detect_flavor` falls back to :iso for a publisher
  # it does not know, and `Pubid::Iso.parse` sends an MR-shaped string straight
  # back to it — so a string that survives conversion unchanged used to recurse
  # until the stack blew. `ECMA-426` is the standing example: "ECMA" is absent
  # from FLAVOR_MAP and the string matches the MR shape heuristic.
  describe "MR detection cannot recurse forever" do
    it "raises ParseFailed instead of SystemStackError on a fixed point" do
      expect { Pubid::Iso.parse("ECMA-426 ed1") }
        .to raise_error(Parslet::ParseFailed, /not an MR string/)
    end

    it "lets the routed parse reach the flavor that owns it" do
      expect(Pubid.parse("ECMA-426 ed1")).to be_a(Pubid::Ecma::Identifier)
    end

    it "still parses a genuine MR string" do
      expect(Pubid.parse("IEC.60050").to_s).to eq("IEC 60050")
    end
  end
end

# The v1 name isodoc still calls. It delegates; it is not a second
# implementation.
RSpec.describe "Pubid::Registry.parse" do
  it "parses a human-readable identifier" do
    expect(Pubid::Registry.parse("ISO 1234-1:2013"))
      .to be_a(Pubid::Iso::Identifier)
  end

  it "agrees with Pubid.parse" do
    expect(Pubid::Registry.parse("IEC 60038:2009").to_s)
      .to eq(Pubid.parse("IEC 60038:2009").to_s)
  end

  it "raises Parslet::ParseFailed for junk, like every flavor parse" do
    expect { Pubid::Registry.parse("@@@ not an identifier @@@") }
      .to raise_error(Parslet::ParseFailed)
  end

  it "leaves the flavor-name registry intact" do
    expect(Pubid::Registry.flavor_names).to include("iso", "iec")
    expect(Pubid::Registry.get("iso")).to eq(Pubid::Iso)
  end
end
