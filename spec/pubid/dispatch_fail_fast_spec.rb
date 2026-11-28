# frozen_string_literal: true

require "spec_helper"

Pubid.eager_load_flavors!

# Issue #803: the flavor dispatcher prunes the flavors the input is known to
# be incompatible with, keeping the full dispatch order — a filter over the
# existing walk, never a reorder. The prune applies only to strings a
# declared prefix owns: a string no prefix owns keeps the full walk, because
# flavors accept leading tokens their prefix tables never declared there.
# Within a pruned walk a flavor is dropped only when its grammar cannot
# accept the string: it declares prefix tokens, accepts no bare (unprefixed)
# form, and none of its prefixes occurs anywhere in the string. A flavor
# that accepts a bare form is never dropped, so sole-owner, ambiguous and
# prefixed strings alike walk the survivors in the original order. The
# one-time calibration that classifies each flavor (accepts_bare?,
# accepts_anything?) is settled by {warm_calibration} before the spies are
# installed, so the counts are routing invocations only.
RSpec.describe "Pubid.parse sound flavor-dispatch prune (#803)" do
  # Settle the probe memos and the artifact loads: one prefixed parse probes
  # every non-owning candidate's bare acceptance, one no-owner rejection
  # settles the anything-goes classification, one normalizing owner parse
  # settles its own.
  def warm_calibration
    ["ISO 9001:2015", "iec.60050", "OGC 06-121r9"]
      .each { |s| parse_calibrating(s) }
  end

  def parse_calibrating(shape)
    Pubid.parse(shape)
  rescue Pubid::Errors::ParseError
    nil
  end

  # Install the counting spy on every registered flavor's module-level
  # parse, recording into +counts+.
  def install_counting_spies(counts)
    spied = {}
    Pubid::Registry.flavor_names.each do |name|
      mod = Pubid::Registry.get(name)
      next if spied.key?(mod)

      spied[mod] = true
      allow(mod).to receive(:parse).and_wrap_original do |orig, *a, **k, &b|
        counts[mod] += 1
        orig.call(*a, **k, &b)
      end
    end
  end

  # A counting spy over every registered flavor's module-level parse.
  # Returns the per-module invocation counts recorded while the block runs,
  # in invocation order; only modules actually invoked appear as keys.
  def dispatch_counts
    warm_calibration
    counts = Hash.new(0)
    install_counting_spies(counts)
    yield
    counts
  end

  # The full dispatch order for +string+ — prefix owners (longest match
  # first, umbrella last) then every other flavor in registry order — what
  # the walk would be before the prune filters it.
  def full_dispatch_order(string)
    owners = Pubid.send(:candidates_by_prefix, string)
    owners + Pubid.send(:other_candidates, owners)
  end

  # The flavors the prune keeps for +string+: the full order, filtered by
  # the compatibility derivation, order preserved. A walk that returns early
  # on an exact round trip invokes a leading section of it.
  def compatible_order(string)
    lowered = string.downcase
    full_dispatch_order(string)
      .select { |mod| Pubid.send(:flavor_compatible?, mod, lowered) }
  end

  # The flavors measured to accept a bare form (each probe shape's coverage
  # is recorded on Pubid::BARE_FORM_PROBES' comment). Reads the memo only —
  # any calibration parse here would run under the installed spies, so
  # {warm_calibration} must have run first (dispatch_counts does).
  def bare_accepting_flavors
    @bare_accepting_flavors ||=
      Pubid::Registry.flavor_names.filter_map do |name|
        mod = Pubid::Registry.get(name)
        next unless mod.respond_to?(:prefixes)

        mod if Pubid.send(:accepts_bare?, mod)
      end
  end

  describe "the bare-acceptance classification" do
    it "matches the measured set exactly" do
      warm_calibration
      expect(bare_accepting_flavors.map(&:prefix_flavor_key)).to eq(
        %i[3gpp adobe ashrae astm doi doi_pfs gb iana iec ieee isbn iso nist
           ogc un],
      )
    end
  end

  describe "a sole-owner prefix" do
    it "invokes only the owning flavor's parser on an exact round trip" do
      counts = dispatch_counts do
        expect(Pubid.parse("ISO 9001:2015").to_s).to eq("ISO 9001:2015")
      end

      expect(counts.keys).to eq([Pubid::Iso])
      expect(counts[Pubid::Iso]).to eq(1)
    end

    it "dispatches a normalizing owner parse to the owner alone" do
      counts = dispatch_counts do
        expect(Pubid.parse("OGC 06-121r9").to_s).to eq("06-121r9")
      end

      expect(counts[Pubid::Ogc]).to eq(1)
      expect(compatible_order("OGC 06-121r9")).to start_with(*counts.keys)
    end

    it "walks only the compatible set when the owner rejects" do
      error = nil
      counts = dispatch_counts do
        Pubid.parse("ISO @@ junk")
      rescue Pubid::Errors::ParseError => e
        error = e
      end
      expect(error).to be_a(Pubid::Errors::ParseError)
      # The owner is tried first, then the compatible remainder — the
      # bare-accepting flavors are never dropped, a prefix-requiring flavor
      # with no prefix in the string (wmo) is.
      expect(counts.keys.first).to eq(Pubid::Iso)
      expect(counts[Pubid::Iso]).to eq(1)
      expect(counts.keys).to eq(compatible_order("ISO @@ junk"))
      missing = bare_accepting_flavors.reject { |m| counts.key?(m) }
      expect(missing).to be_empty
      expect(counts).not_to include(Pubid::Wmo)
    end

    it "reports the rejected input with the owning flavor's error" do
      direct =
        begin
          Pubid::Iso.parse("ISO @@ junk")
        rescue Pubid::Errors::ParseError => e
          e
        end

      expect { Pubid.parse("ISO @@ junk") }.to raise_error(
        Pubid::Errors::ParseError,
      ) { |e|
        expect(e.flavor).to eq("iso")
        expect(e.message).to eq(direct.message)
        expect(e.input).to eq(direct.input)
      }
    end
  end

  describe "a dual-published form with the other publisher's prefix" do
    it "keeps the co-published flavor and lands the attested answer" do
      parsed = nil
      counts = dispatch_counts do
        parsed = Pubid.parse("API 579-2 /ASME PTB-14-2009")
      end

      # The co-published tail keeps asme compatible — ASME occurs after the
      # slash — and its parse wins, exactly as the full dispatch did.
      expect(parsed).to be_a(Pubid::Asme::Identifiers::Standard)
      expect(counts[Pubid::Api]).to eq(1)
      expect(counts[Pubid::Asme]).to eq(1)
      expect(compatible_order("API 579-2 /ASME PTB-14-2009"))
        .to start_with(*counts.keys)
      expect(counts).not_to include(Pubid::Wmo)
    end

    it "keeps a flavor whose prefix is glued to the type token" do
      parsed = nil
      counts = dispatch_counts do
        parsed = Pubid.parse("ISO/ASTMTR52905-EB")
      end

      # "ISO/ASTMTR52905-EB" carries ASTM directly against the TR token; the
      # occurrence test needs no trailing boundary to keep astm in the walk.
      expect(parsed).to be_a(Pubid::Astm::Identifiers::TechnicalReport)
      expect(counts[Pubid::Astm]).to eq(1)
      expect(compatible_order("ISO/ASTMTR52905-EB")).to start_with(*counts.keys)
    end
  end

  describe "an ambiguous prefix (more than one owner)" do
    it "routes a co-published identifier unchanged" do
      expect(Pubid.parse("ISO/IEC 2131:2013").to_s).to eq("ISO/IEC 2131:2013")
    end

    it "walks the compatible set in the original owner-first order" do
      error = nil
      counts = dispatch_counts do
        Pubid.parse("ISO/IEC @@ not an identifier @@")
      rescue Pubid::Errors::ParseError => e
        error = e
      end

      expect(error).to be_a(Pubid::Errors::ParseError)
      # Longest-match owners first (iec sorts before iso on the joint
      # prefix), then the compatible remainder.
      expect(counts.keys.first(2)).to eq([Pubid::Iec, Pubid::Iso])
      # >= 1, not == 1: flavors with a foreign-adoption lookup (GOST) call
      # the ISO parser again from inside their own parse.
      expect(counts[Pubid::Iso]).to be >= 1
      expected = compatible_order("ISO/IEC @@ not an identifier @@")
      expect(counts.keys).to eq(expected)
      expect(counts.keys.length).to be > 10
    end
  end

  describe "a string no prefix owns" do
    it "walks the full dispatch order unchanged" do
      error = nil
      counts = dispatch_counts do
        Pubid.parse("iec.60050")
      rescue Pubid::Errors::ParseError => e
        error = e
      end

      expect(error).to be_a(Pubid::Errors::ParseError)
      # The anything-goes flavors are still consulted — and still refused as
      # a fallback, which is why the string stays rejected.
      expect(counts[Pubid::Iana]).to eq(1)
      expect(counts[Pubid::Adobe]).to eq(1)
      # No prefix owns the string, so no prune applies: the full walk runs —
      # flavors accept leading tokens their prefix tables never declared
      # there (BSI committee documents, CEN stage prefixes, IALA numbers),
      # so only the grammar itself can reject the string.
      expect(counts.keys).to eq(full_dispatch_order("iec.60050"))
    end

    it "never drops a bare-accepting flavor from an unprefixed walk" do
      counts = dispatch_counts { reject("@@ no prefix owns this @@") }

      expect(counts.keys).to include(*bare_accepting_flavors)
    end

    it "walks the full order for a flavor form with an undeclared token" do
      # A BSI committee document: the grammar accepts "14/30300822 DC" but
      # no declared prefix leads it, so the full walk must run and BSI wins.
      parsed = nil
      counts = dispatch_counts do
        parsed = Pubid.parse("14/30300822 DC")
      end

      expect(parsed).to be_a(Pubid::Bsi::Identifiers::CommitteeDocument)
      # The walk is the full order, stopping at BSI's exact round trip.
      expect(full_dispatch_order("14/30300822 DC")).to start_with(*counts.keys)
    end
  end

  # Pubid.parse of +input+, rescuing the dispatch rejection the way the
  # examples that only need the invocation record do.
  def reject(input)
    Pubid.parse(input)
  rescue Pubid::Errors::ParseError
    nil
  end

  describe "the compatibility derivation" do
    it "does not prune a string with no declared prefix owner" do
      expect(Pubid.send(:dispatch_candidates, "AMD 11015", [])).to eq(
        [] + Pubid.send(:other_candidates, []),
      )
    end

    it "matches a prefix occurring after a separator (co-published tail)" do
      expect(Pubid.send(:flavor_compatible?, Pubid::Asme,
                        "api 579-2 /asme ptb-14-2009")).to be(true)
    end

    it "refuses a prefix glued inside a longer word" do
      expect(Pubid.send(:flavor_compatible?, Pubid::Wmo,
                        "xwmo-no. 1")).to be(false)
    end

    it "accepts a prefix at a token start anywhere in the string" do
      expect(Pubid.send(:flavor_compatible?, Pubid::Wmo,
                        "see /wmo-no. 51 for the list")).to be(true)
    end

    it "matches prefixes case-insensitively" do
      expect(Pubid.send(:flavor_compatible?, Pubid::Asme,
                        "API 579-2 /asme ptb-14-2009")).to be(true)
    end

    it "never drops a bare-accepting flavor, whatever the string" do
      expect(Pubid.send(:flavor_compatible?, Pubid::Astm, "@@@ @@")).to be(true)
      expect(Pubid.send(:flavor_compatible?, Pubid::Iso, "@@@ @@")).to be(true)
    end
  end
end
