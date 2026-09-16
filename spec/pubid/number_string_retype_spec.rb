# frozen_string_literal: true

require "spec_helper"

# The converted flavors of the `number` retype — ansi, api, bsi, cen_cenelec,
# idf and jcgm (tranche 1), plus iec (tranche 2) — hold `number`, `part` and
# `subpart` as plain `:string` attributes instead of a `Pubid::Components::Code`.
#
# IEC's own forensics live in spec/pubid/iec/number_string_spec.rb: its
# `Iec::Components::Code` subclass existed only to render a `prefix` that no
# construction path ever set, and the split between a Code from `parse` and a
# String from `new` made the two paths silently not `==`.
#
# WHY. ::Pubid::Identifier declares all three as `Components::Code`
# (lib/pubid/identifier.rb:136-138), so a flavor that wants a scalar must
# REDECLARE the attribute — and a redeclaration on a class that other classes
# inherit from resolves nondeterministically under multi-flavor load. That
# landmine is recorded a dozen times in CLAUDE.md and is why twelve flavors
# carry a structural tripwire spec. It exists only because the parent and the
# leaves disagree about the type. Every flavor listed here stored a String in a
# box: measured over the whole fixture corpus, not one of the six tranche-1
# flavors' 2,066 identifiers, and not one of IEC's 12,331, populated `prefix`,
# `part`, `subpart` or `parts` inside the Code, and `number.parts` /
# `number.prefix` have zero call sites anywhere in lib/.
#
# The base declaration is deliberately NOT changed here — that is the last step
# of the three-tranche sequence, after ISO, NIST and CSA also move. Until then
# the disagreement is real, which is exactly what the first block below pins.
#
# IMPORTANT: the structural block is only meaningful under the FULL suite
# (`bundle exec rake`), never `rspec spec/pubid/<flavor>` alone. lutaml
# deep-dups the parent attribute table into each subclass at class-definition
# time, so a single-flavor run can resolve the attribute differently from a run
# that has loaded every flavor.
module NumberStringRetypeSpec
  STRING = Lutaml::Model::Type::String

  # The three attributes ::Pubid::Identifier declares as a Components::Code.
  ATTRS = %i[number part subpart].freeze

  # flavor fixture dir => [flavor module, minimum ids the sweep must find]
  FLAVORS = {
    "ansi" => [Pubid::Ansi, 170],
    "api" => [Pubid::Api, 190],
    "bsi" => [Pubid::Bsi, 1_400],
    "ccsds" => [Pubid::Ccsds, 400],
    "cen_cenelec" => [Pubid::CenCenelec, 100],
    "idf" => [Pubid::Idf, 60],
    "iec" => [Pubid::Iec, 2_000],
    "jcgm" => [Pubid::Jcgm, 25],
  }.freeze

  # Flavors whose fixture corpus is too large to sweep whole: take every Nth
  # input. IEC has 12,331 pass fixtures and parsing them all costs ~39 s, which
  # would make one flavor dominate the suite. The stride is deterministic (not
  # random), so a failure is reproducible, and the files are ordered by
  # identifier type, so every type is still represented.
  SAMPLE_STRIDE = { "iec" => 6 }.freeze

  # Identifiers whose from_hash(to_hash) does not reproduce to_hash. Every one
  # of these already failed before the retype (measured on the parent commit:
  # ansi 0, api 1, bsi 613, cen_cenelec 64, idf 0, jcgm 0) and none of the
  # causes is the number type. BSI improved from 613 to 594 here, because the
  # members of a bundled identifier now resolve to the flavor class instead of
  # the abstract root — see Pubid::Identifier.own_base_class.
  # bsi 594 -> 647 and cen_cenelec 64 -> 66 when the BSI adopted-branch nil bug
  # was fixed, and the rise is the WHOLE point of pinning exactly. Neither
  # flavor got worse: the BSI corpus grew from 1448 to 1501 parsed identifiers
  # (49 `DD CEN ISO/…` inputs returned nil on the old code and were dropped by
  # the corpus builder's filter_map; 48 now build), and CEN gained the two
  # `ES 59008-…` ids a stale fixture had recorded as a NameError. Every one of
  # the 53 + 2 new corpus members lands in the SAME pre-existing gap — they are
  # BSI/CEN wrappers holding another flavor's identifier in an attribute typed
  # to their own Components::Code, the documented `bsi-set-cross-flavor-type`
  # issue — so the delta equals the corpus growth exactly. A count that moves
  # for any other reason is the regression this pin exists to catch.
  # cen_cenelec 66 -> 0 when the relaton blockers were fixed: the CEN
  # supplements no longer type `base` to the legacy Identifiers::Base, the
  # adopted norm holds a Components::Publisher instead of an Array, the
  # consolidated identifier lost its colliding readers, and the CWA/HD/CR/ES/
  # ENV `type` default is a Components::Type instead of a Symbol.
  # bsi 647 -> 597 in the same branch: Pubid::TypeResolver now resolves the
  # `pubid:cencenelec:` type segment (the module name, not a registry name),
  # so the CEN identifier nested in a BSI adoption deserializes as its CEN
  # class instead of the abstract root.
  KNOWN_ROUND_TRIP_FAILURES = {
    "ansi" => 0,
    "api" => 1,
    "bsi" => 597,
    "ccsds" => 0,
    "cen_cenelec" => 0,
    "idf" => 0,
    # Measured over the WHOLE 12,331-id IEC corpus on the parent commit, not
    # just the sampled slice: 0 failures before the retype and 0 after.
    "iec" => 0,
    "jcgm" => 0,
  }.freeze

  # One reference per flavor whose serialized hash must carry a BARE scalar
  # number, and the scalar it must carry.
  FLAT_WIRE = {
    "ansi" => ["ANSI C135.14-2000", "C135.14"],
    "api" => ["API RP 500", "500"],
    "bsi" => ["BS 1234:2020", "1234"],
    # CCSDS already emitted a bare scalar: its own Identifier declared :string
    # while the unused SingleIdentifier still declared a Components::Code.
    "ccsds" => ["CCSDS 120.0-G-4", "120"],
    "cen_cenelec" => ["EN 196-3:2005", "196"],
    "idf" => ["IDF 125:1988", "125"],
    # IEC already emitted a bare scalar before the retype, through the
    # emit_code/build_code converters. The retype removed the converters, not
    # the shape — which is why no relaton-data-iec row changes.
    "iec" => ["IEC 60068-2-28:2008", "60068"],
    "jcgm" => ["JCGM 100:2008", "100"],
  }.freeze

  # A generated pass fixture writes "!input!rendered" for a NORMALIZING parse
  # (one that succeeds but whose to_s differs from the input); only the input
  # half is parseable. Mirrors FixtureFileHelper#read_pass_fixture_entries.
  NORMALIZING = /\A!(.+)!(.+)\z/

  class << self
    # Every class in a flavor's hierarchy, the shared base included. Reading
    # polymorphic_type_map first forces the concrete Identifiers::* classes to
    # autoload; ObjectSpace then also picks up the intermediates they inherit
    # (SingleIdentifier, SupplementIdentifier, Identifiers::Base ...), which is
    # where the landmine actually lives.
    def hierarchy(mod)
      base = mod.const_get(:Identifier)
      base.polymorphic_type_map
      ([base] + ObjectSpace.each_object(Class).select { |c| c < base })
        .uniq.sort_by(&:name)
    end

    # Attributes of `klass` that do not resolve to a plain String, reported as
    # "Class#attr=Type" so a failure names the offender.
    def offenders(mod)
      hierarchy(mod).flat_map do |klass|
        ATTRS.filter_map do |attr|
          type = klass.attributes[attr]&.type
          "#{klass.name}##{attr}=#{type}" if type != STRING
        end
      end
    end

    # True when `klass` reaches `attr` through a hand-written delegation rather
    # than the lutaml-generated accessor. Every converted flavor declares the
    # three attributes on its `Identifier` base, so that is where a generated
    # reader is owned; anything else is a wrapper forwarding to a nested
    # identifier, which may belong to a flavor that has not converted yet.
    def delegated?(mod, klass, attr)
      klass.instance_method(attr).owner != mod.const_get(:Identifier)
    end

    # [input, identifier] for every parseable pass-fixture line of a flavor.
    def corpus(flavor)
      @corpus ||= {}
      @corpus[flavor] ||= begin
        klass = FLAVORS.fetch(flavor).first.const_get(:Identifier)
        fixture_inputs(flavor).filter_map do |line|
          id = try_parse(klass, line)
          [line, id] if id
        end
      end
    end

    private

    def fixture_inputs(flavor)
      glob = File.join(__dir__,
                       "../fixtures/#{flavor}/identifiers/pass/*.txt")
      lines = Dir.glob(glob).flat_map { |f| File.readlines(f, chomp: true) }
      inputs = lines.filter_map { |line| fixture_input(line) }.uniq
      stride = SAMPLE_STRIDE[flavor]
      stride ? inputs.each_slice(stride).map(&:first) : inputs
    end

    def fixture_input(line)
      stripped = line.strip
      return nil if stripped.empty? || stripped.start_with?("#")

      (m = stripped.match(NORMALIZING)) ? m[1] : stripped
    end

    def try_parse(klass, line)
      klass.parse(line)
    rescue StandardError, Parslet::ParseFailed
      nil
    end
  end
end

RSpec.describe "number/part/subpart as :string" do
  describe "the shared base is NOT retyped" do
    # The whole point of the tranching: this line moves last, once ISO, NIST
    # and CSA have also converted. A failure here means someone jumped ahead.
    NumberStringRetypeSpec::ATTRS.each do |attr|
      it "::Pubid::Identifier still declares #{attr} as Components::Code" do
        expect(Pubid::Identifier.attributes[attr].type)
          .to eq(Pubid::Components::Code)
      end
    end
  end

  NumberStringRetypeSpec::FLAVORS.each do |flavor, (mod, minimum)|
    describe mod.name do
      describe "structural tripwire (full-suite only)" do
        it "resolves number/part/subpart to String on every class" do
          expect(NumberStringRetypeSpec.offenders(mod)).to eq([])
        end
      end

      describe "the fixture corpus" do
        # The six tranche-1 flavors' own fixtures_spec.rb files all report 0
        # examples (the `../../../fixtures` glob has one `..` too many; api and
        # idf also use an uppercase directory). Until that is fixed separately,
        # this sweep is the only thing exercising their corpora. IEC's own
        # fixtures_spec.rb is live, so its sweep here is a second net.
        let(:corpus) { NumberStringRetypeSpec.corpus(flavor) }

        it "parses a corpus worth sweeping" do
          expect(corpus.size).to be >= minimum
        end

        it "holds a String, never a Code, in number/part/subpart" do
          bad = corpus.reject do |_, id|
            NumberStringRetypeSpec::ATTRS.all? do |attr|
              # A wrapper that DELEGATES the reader (BSI's adoption types
              # return their nested identifier's number) reports a value it
              # does not own, and that nested id may be an ISO or IEC one,
              # which still holds a Components::Code until tranche 3.
              next true if NumberStringRetypeSpec.delegated?(mod, id.class,
                                                             attr)

              value = id.public_send(attr)
              value.nil? || value.is_a?(String)
            end
          end

          expect(bad.map(&:first).first(10)).to eq([])
        end

        it "round-trips through from_hash(to_hash) no worse than before" do
          # The counts are pinned exactly rather than as an upper bound, so
          # that a REGRESSION and an accidental IMPROVEMENT are both visible —
          # the convention identifier_roundtrip_spec.rb's PENDING_EQUALITY list
          # already uses. A count reaching 0 means: delete the entry.
          klass = mod.const_get(:Identifier)
          bad = corpus.reject do |_, id|
            hash = id.to_hash
            klass.from_hash(hash).to_hash == hash
          rescue StandardError
            false
          end

          expect(bad.size).to eq(
            NumberStringRetypeSpec::KNOWN_ROUND_TRIP_FAILURES.fetch(flavor),
          )
        end
      end

      describe "serialized shape" do
        it "emits a bare scalar number, not a nested {value => ...}" do
          ref, scalar = NumberStringRetypeSpec::FLAT_WIRE.fetch(flavor)

          expect(mod.const_get(:Identifier).parse(ref).to_hash["number"])
            .to eq(scalar)
        end
      end
    end
  end
end
