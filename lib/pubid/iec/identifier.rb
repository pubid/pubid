# frozen_string_literal: true

module Pubid
  module Iec
    # Mixin for pure wrapper identifiers (Vap/Consolidated/Sheet) whose common
    # ID fields are delegated to a wrapped base. lutaml merges a subclass's
    # key_value block onto the parent's, so without this the delegated fields
    # would serialize twice — once at the wrapper's top level and once inside
    # "base". No-op the delegated maps so they serialize once. (Mirrors
    # Iso::BundledIdentifier.) Fragment keeps its own stage/edition, so it
    # suppresses a subset inline instead of including this.
    #
    # number/part/subpart and the date keys (year/month/day/undated) are NOT
    # here, and deliberately so: their maps live on SingleIdentifier, which
    # the wrappers do not inherit from, so the exclusion is structural rather
    # than a denylist that can drift. (The denylist did drift: it once listed
    # `year` but not `month`/`day`/`undated`, and those three leaked a
    # duplicated top-level key on every wrapper.) Only publisher,
    # copublishers and stage stay here, because those maps are still wanted
    # on the parent block.
    module DelegatedFieldSuppression
      def publisher_to_kv(_model, _doc); end
      def copublishers_to_kv(_model, _doc); end
      def stage_to_kv(_model, _doc); end
    end

    class Identifier < ::Pubid::Identifier
      # IEC prints "(all parts)" and has a series URN, so it has its own
      # all-parts class.
      def self.all_parts_class
        Identifiers::AllParts
      end

      # Override base types with IEC-specific ones. publisher defaults to the
      # type's implied publisher (IEC), so an omitted publisher key reconstructs
      # correctly on from_hash.
      attribute :publisher, ::Pubid::Iec::Components::Publisher,
                default: -> { self.class.default_publisher }
      attribute :copublishers, ::Pubid::Iec::Components::Publisher,
                collection: true

      # number/part/subpart are plain strings, not a Components::Code.
      # ::Pubid::Identifier declares them as a Code, so this is a REDECLARATION
      # — safe here because this class body lives in this one file and is never
      # reopened, so lutaml's deep-dup of the attribute table into each subclass
      # always sees the complete table.
      #
      # The Code they used to hold was an empty box. Measured over all 12,331
      # parseable IEC pass fixtures, number/part/subpart were a Code 9,975 /
      # 5,422 / 2,416 times and NOT ONE populated `prefix`, `parts`, `part` or
      # `subpart` inside it; `Iec::Components::Code` existed solely to render a
      # `prefix` that no construction path ever set, and is deleted.
      #
      # The split was a live defect, not just clutter: `parse` produced a Code
      # while `new` left a String (a `:string` assigned to a Code-typed
      # attribute stays a String), so a hand-built identifier was not `==` the
      # parsed one — and `#matches?` is `exclude(*ignore) == other.exclude(...)`,
      # so every match between them silently returned false while `to_s`,
      # `to_urn` and `to_hash` all agreed. See spec/pubid/iec/number_string_spec.
      attribute :number, :string
      attribute :part, :string
      attribute :subpart, :string

      # The publisher implied when none is serialized (IEC for every type).
      def self.default_publisher
        ::Pubid::Iec::Components::Publisher.new(body: "IEC")
      end

      # typed_stage is the single source of truth for stage (and, with the
      # class, the doctype). Default to the class's published typed_stage so an
      # omitted "stage" key reconstructs the published state on from_hash.
      attribute :typed_stage, ::Pubid::Components::TypedStage,
                default: -> { self.class.published_typed_stage }

      # The class's published typed_stage (canonical surface form), or nil for
      # types without a published stage.
      #
      # `original_abbr` is deliberately LEFT NIL. It records the spelling the
      # input used, it is not serialized, and the parse path (Builder#
      # locate_typed_stage) never writes it — so setting it here alone made
      # `from_hash(to_hash) != parse` for every IEC identifier. The `dup` stays:
      # TYPED_STAGES is frozen, its elements are not.
      def self.published_typed_stage
        return nil unless const_defined?(:TYPED_STAGES)

        ts = self::TYPED_STAGES.find { |t| t.stage_code.to_s == "published" }
        ts&.dup
      end

      # type and generic stage are derived from typed_stage, never stored — so
      # the doctype (fixed by the class / _type) can't be lost when "stage" is
      # omitted for the published default.
      def type
        typed_stage&.to_type
      end

      def stage
        typed_stage&.to_stage
      end

      # Polymorphic type map for lutaml::Model key_value serialization. Maps
      # polymorphic_name -> class name for from_hash dispatch. Includes the
      # compound wrappers (Consolidated/Vap/Sheet) and the synthetic
      # SingleIdentifier base, which appear as nested `_type` values even though
      # they aren't identifier_types. Validated against build_type_map by spec.
      IEC_TYPE_MAP = {
        "pubid:iec:international-standard" => "Pubid::Iec::Identifiers::InternationalStandard",
        "pubid:iec:technical-specification" => "Pubid::Iec::Identifiers::TechnicalSpecification",
        "pubid:iec:technical-report" => "Pubid::Iec::Identifiers::TechnicalReport",
        "pubid:iec:publicly-available-specification" => "Pubid::Iec::Identifiers::PubliclyAvailableSpecification",
        "pubid:iec:guide" => "Pubid::Iec::Identifiers::Guide",
        "pubid:iec:operational-document" => "Pubid::Iec::Identifiers::OperationalDocument",
        "pubid:iec:component-specification" => "Pubid::Iec::Identifiers::ComponentSpecification",
        "pubid:iec:conformity-assessment" => "Pubid::Iec::Identifiers::ConformityAssessment",
        "pubid:iec:societal-technology-trend-report" => "Pubid::Iec::Identifiers::SocietalTechnologyTrendReport",
        "pubid:iec:systems-reference-document" => "Pubid::Iec::Identifiers::SystemsReferenceDocument",
        "pubid:iec:technology-report" => "Pubid::Iec::Identifiers::TechnologyReport",
        "pubid:iec:technical-group" => "Pubid::Iec::Identifiers::TechnicalGroup",
        "pubid:iec:test-report-form" => "Pubid::Iec::Identifiers::TestReportForm",
        "pubid:iec:white-paper" => "Pubid::Iec::Identifiers::WhitePaper",
        "pubid:iec:working-document" => "Pubid::Iec::Identifiers::WorkingDocument",
        "pubid:iec:amendment" => "Pubid::Iec::Identifiers::Amendment",
        "pubid:iec:corrigendum" => "Pubid::Iec::Identifiers::Corrigendum",
        "pubid:iec:interpretation-sheet" => "Pubid::Iec::Identifiers::InterpretationSheet",
        "pubid:iec:fragment-identifier" => "Pubid::Iec::Identifiers::FragmentIdentifier",
        "pubid:iec:consolidated-identifier" => "Pubid::Iec::Identifiers::ConsolidatedIdentifier",
        "pubid:iec:vap-identifier" => "Pubid::Iec::Identifiers::VapIdentifier",
        "pubid:iec:sheet-identifier" => "Pubid::Iec::Identifiers::SheetIdentifier",
        "pubid:iec:base" => "Pubid::Iec::Identifiers::Base",
        "pubid:iec:single-identifier" => "Pubid::Iec::SingleIdentifier",
      }.freeze

      # SingleIdentifier lives outside Pubid::Iec::Identifiers but appears as a
      # nested `_type`, so the shared polymorphic_type_map needs it explicitly
      # (see Pubid::Identifier#additional_identifier_classes).
      def self.additional_identifier_classes
        [Pubid::Iec::SingleIdentifier]
      end
      private_class_method :additional_identifier_classes

      # Build the type map from the live class list, for the validation spec.
      def self.build_type_map
        types = Pubid::Iec.identifier_types
        extra = [Identifiers::ConsolidatedIdentifier, Identifiers::VapIdentifier,
                 Identifiers::SheetIdentifier, Identifiers::Base, SingleIdentifier]
        (types + extra).uniq.to_h { |klass| [klass.polymorphic_name, klass.name] }
      end

      # The base Pubid::Identifier no longer auto-maps attributes, so each
      # flavor's top class declares its own key_value mapping. Subclasses merge
      # their own blocks on top of this one — lutaml APPENDS a subclass's maps
      # to the parent's (e.g. SingleIdentifier adds number/part/subpart,
      # SupplementIdentifier adds base, VapIdentifier adds vap) — so list every
      # attribute EVERY IEC type serializes here once, and put a key that only
      # some types own on the class that owns it.
      #
      # Date is flattened to plain scalars; the verbose type/stage trees are not
      # mapped (type/stage are recomputed from typed_stage, which serializes as
      # just its code under "stage").
      #
      # A converter (`with:`) is for a custom class, or for splitting one
      # attribute across several keys. A primitive takes a plain map: a nil and
      # a default-valued attribute are both dropped by
      # ::Pubid::Identifier#to_hash, so no converter is needed to omit them.
      key_value do
        map "_type", to: :_type, polymorphic_map: IEC_TYPE_MAP
        # number/part/subpart are NOT mapped here — they live on
        # SingleIdentifier, the seam that excludes the delegating wrappers.
        # See the comment on that block.
        #
        # stage_iteration is a degenerate Components::Iteration (one :string
        # field, `number`), so the shared FLAT_SCALAR_COMPONENTS rule on
        # ::Pubid::Identifier flattens it to a bare scalar and inflates it back.
        # A plain map is enough; no converter.
        map "stage_iteration", to: :stage_iteration, render_default: false
        # year/month/day/undated are NOT mapped here either — they live on
        # SingleIdentifier for the same reason as number/part/subpart: a
        # wrapper delegates `date` to what it wraps.
        map "edition", to: :edition, render_default: false
        map "languages", to: :languages, render_default: false
        # publisher emitted only when the primary isn't the IEC default;
        # copublishers (the other bodies) as an array, omitted when empty.
        map "publisher", with: { to: :publisher_to_kv, from: :publisher_from_kv }
        map "copublishers",
            with: { to: :copublishers_to_kv, from: :copublishers_from_kv }
        # `type` and generic `stage` are fully derived from `typed_stage`, so we
        # serialize only the unique typed-stage code under "stage" and recompute
        # the rest on load. _type already pins the document type.
        map "stage", with: { to: :stage_to_kv, from: :stage_from_kv }
        # A Boolean attribute whose `false` default ::Pubid::Identifier#to_hash
        # already drops, so a plain map suffices (the GB spelling).
      end

      # --- publisher: primary only when non-default; copublishers as a list ---
      def publisher_to_kv(model, doc)
        pub = model.publisher&.body
        return if pub.nil? || pub == model.class.default_publisher&.body

        doc.add_child(Lutaml::KeyValue::DataModel::Element.new("publisher", pub))
      end

      def publisher_from_kv(model, value)
        return if value.nil? || value.to_s.empty?

        model.publisher = ::Pubid::Iec::Components::Publisher.new(body: value.to_s)
      end

      def copublishers_to_kv(model, doc)
        cp = model.copublishers
        return unless cp&.any?

        doc.add_child(
          Lutaml::KeyValue::DataModel::Element.new("copublishers", cp.map(&:body)),
        )
      end

      def copublishers_from_kv(model, value)
        list = Array(value).map(&:to_s)
        return unless list.any?

        model.copublishers = list.map do |cp|
          ::Pubid::Iec::Components::Publisher.new(body: cp)
        end
      end

      # Serialize typed_stage as just its unique code (e.g. "cd", "fdis"); the
      # published default is omitted (recomputed from the class on load).
      def stage_to_kv(model, doc)
        ts = model.typed_stage
        return unless ts&.code
        return if ts.stage_code.to_s == "published"

        doc.add_child(
          Lutaml::KeyValue::DataModel::Element.new("stage", ts.code.to_s),
        )
      end

      # Resolve the typed-stage code back within this identifier's class.
      # `original_abbr` is left nil here for the same reason as in
      # `published_typed_stage` above.
      def stage_from_kv(model, value)
        return if value.nil? || value.to_s.empty?

        ts = (model.class.const_defined?(:TYPED_STAGES) &&
              model.class::TYPED_STAGES.find { |t| t.code.to_s == value.to_s }) ||
             Pubid::Iec.all_typed_stages.find { |t| t.code.to_s == value.to_s }
        return unless ts

        model.typed_stage = ts.dup
      end

      def self.parse(string)
        unless string.is_a?(String)
          raise Pubid::Errors::InvalidInputError,
                Pubid::INPUT_NOT_A_STRING_MESSAGE
        end

        if string.length > Pubid::MAX_INPUT_LENGTH
          raise Pubid::Errors::InvalidInputError, Pubid::INPUT_TOO_LONG_MESSAGE
        end

        string = ::Pubid.utf8_input(string)

        # Route URN strings to the URN parser (mirrors Iso::Identifier.parse)
        if Pubid::FormatDetector.detect(string) == :urn
          return Pubid::Iec::UrnParser.parse(string)
        end

        # Apply legacy update_codes normalization first, before any other preprocessing
        normalized = Core::UpdateCodes.apply(string, :iec)
        parsed = Pubid::Parg::Model.bound(:iec, Pubid::Iec::Parser.normalize_input(normalized))
        id = Pubid::Iec::Builder.new.build(parsed)
        # A standalone supplement stores its numbers in the layout from_hash
        # rebuilds only after #ensure_base runs; run it here, so a fresh
        # parse holds that layout before any reader runs
        # (SupplementIdentifier#number).
        id.ensure_base if id.is_a?(SupplementIdentifier)
        reject_standalone_dotted_supplement(id, string)
        reject_unrenderable_fragment(id, string)
        reject_unrenderable_consolidated_edition(id, string)
        id
      end

      # A supplement's OWN dotted sub-number has nowhere to print on the
      # standalone (self-base) face: render_supplement_standalone prints the
      # base number and the supplement number only, so the parsed dot was
      # dropped at render and parse(to_s) != parse. No IEC source prints a
      # no-part standalone face with a dotted sub-number — the facet is
      # attested only on the on-base draft faces ("IEC 60038-2/DAM 2.3:2022")
      # — so the shape is rejected here instead of being built unrenderable
      # (pubid#727; the same ruling as the prefix-face dotted ballot numbers,
      # which the grammar keeps raising). The walk reaches the dotted layer
      # when it sits under an undotted second supplement ("/AMD 1.2:2017" as
      # the base of a "/COR 1" chain). The single-document draft faces
      # ("IEC CD 1.2:2017") and the DAM-family decodes ("IEC/DAM 1.2") keep
      # their dot on a non-supplement layer and pass; the on-base faces have
      # a real base, so synthetic_base? is false and they pass too.
      STANDALONE_DOTTED_SUPPLEMENT_MESSAGE =
        "the standalone no-part supplement face carries a dotted sub-number " \
        "(e.g. \"IEC/AMD 1.2:2017\"): no IEC source prints one, and the " \
        "standalone face has no layer to print the dot on, so the stored " \
        "sub-number would be dropped at render — the dotted sub-number is " \
        "attested only on the on-base draft forms"

      def self.reject_standalone_dotted_supplement(id, input)
        node = id
        while node.is_a?(SupplementIdentifier)
          if node.stage_iteration && node.synthetic_base?
            raise Pubid::Errors::ParseError.new(
              STANDALONE_DOTTED_SUPPLEMENT_MESSAGE, nil,
              input: input, flavor: "iec"
            )
          end
          node = node.base
        end
      end

      # pubid#731: the fragment-ladder spellings ("CDFRAG", "DFRAG",
      # "FDFRAG", "PRF Frag", "PWI Frag" and the NP/ANW/WD " Frag" siblings)
      # parse into broken shapes, and one condition on the BUILT object
      # covers every route (the check is the shape, not a grammar route —
      # the same ruling as reject_standalone_dotted_supplement above):
      #
      # * a fragment built WITHOUT its base designation — the ladder token
      #   (or even the published "FRAG" token) in the primary type position.
      #   The input's designation, date and edition are dropped (the
      #   fragment delegates number/date to a base that is not there), the
      #   fragment renders bare "/FRAG" — which is itself unparseable — and
      #   the official URN is nil, so the shape silently corrupts
      #   downstream.
      # * a fragment carrying a NON-PUBLISHED ladder stage — the token in a
      #   supplement layer ("IEC 60038/CDFRAG 1"). The renderer prints the
      #   published "/FRAG<n>" face only, so the stage facet is dropped at
      #   render and parse(to_s) != parse.
      #
      # No IEC source prints either shape: the gem fixtures, the testsuite
      # ledger and the IEC/ISO Harmonized APIs data feeds (which carry an
      # empty <FRAG/> element plus <stdFragment> for the number) attest only
      # the on-base "/FRAG<n>" notation of the published fragment, and the
      # stage-codes extract (data/iec/stage-codes.md) has no ladder rows. So
      # the ladder spellings are rejected at parse — the #726/#727 ruling
      # for unattested, un-renderable faces. from_hash stays open
      # (stored-data compatibility): parse can no longer produce the shape,
      # and no stored row carries it. The walk reaches a broken fragment
      # under the wrappers ("IEC DFRAG 60038 (all parts)" is an AllParts
      # over one; "IEC 60038/FRAG1 CSV" a Vap over a sound one — which
      # passes).
      FRAGMENT_LADDER_MESSAGE =
        "the fragment-ladder spellings (\"CDFRAG\", \"DFRAG\", \"FDFRAG\", " \
        "\"PRF Frag\", \"PWI Frag\" and the NP/ANW/WD \" Frag\" siblings) " \
        "build a fragment identifier that cannot render or round-trip: no " \
        "IEC source prints a fragment-ladder token (the attested fragment " \
        "face is the on-base \"/FRAG<n>\" notation), and the built fragment " \
        "either holds no base designation — rendering bare \"/FRAG\" with " \
        "nothing attached and an empty official URN — or carries a " \
        "non-published fragment stage with no printed token"

      def self.reject_unrenderable_fragment(id, input)
        node = id
        while node
          reject_fragment_ladder_shape(node, input)
          node = descend_wrapper(node)
        end
      end

      # The rejected fragment shape: either facet of the ladder spellings.
      # A sound fragment (a base AND the published stage) passes; a nil
      # stage also fails the check, defensively — no parse route builds one.
      def self.reject_fragment_ladder_shape(node, input)
        return unless node.is_a?(Identifiers::FragmentIdentifier)
        return if node.base && node.typed_stage&.stage_code.to_s == "published"

        raise Pubid::Errors::ParseError.new(
          FRAGMENT_LADDER_MESSAGE, nil,
          input: input, flavor: "iec"
        )
      end

      # The next node the walk reaches: a wrapper's child. Supplements,
      # Vap, Sheet and Fragment carry it in `base`; the AllParts and
      # Consolidated members in `identifiers`. A leaf resolves neither and
      # ends the walk.
      def self.descend_wrapper(node)
        if node.class.attributes.key?(:base)
          node.base
        elsif node.class.attributes.key?(:identifiers)
          node.identifiers.first
        end
      end

      # The bare consolidated chain with a trailing edition
      # ("IEC 60068:2005+AMD1:2012 ED2") parses, and then cannot render:
      # the edition rides the base member, so the composition prints it
      # onto the base designation ("IEC 60068:2005 ED2+AMD1:2012") — a face
      # no IEC source prints and the grammar rejects, so parse(to_s)
      # raises. The attested consolidated editions carry no edition facet
      # on the chain at all (0 of the 33,070 primary docidentifiers in
      # relaton-data-iec; 0 rows in the gem fixtures): the consolidated
      # edition IS the CSV product ("IEC 60034-18-41:2014+AMD1:2019 CSV",
      # the OBP PDF named `{ed1.1}`), and where the printed edition
      # appears at all it is the CSV face's own facet
      # ("IEC 60068:2005+AMD1:2012 CSV ED1" — the Vap carries the edition
      # after the deliverable code and renders back parseably). So the
      # shape is rejected at parse — the #727 ruling for unattested,
      # un-renderable faces — rather than built unrenderable. The check is
      # the SHAPE on the built object, not a grammar route (the same
      # ruling as reject_standalone_dotted_supplement): a bare
      # ConsolidatedIdentifier with an edition on any member. from_hash
      # stays open (stored-data compatibility): parse can no longer
      # produce the shape, and no stored row carries it.
      CONSOLIDATED_EDITION_MESSAGE =
        "the bare consolidated chain carries a trailing edition " \
        "(e.g. \"IEC 60068:2005+AMD1:2012 ED2\"): no IEC source prints " \
        "one — 0 of the 33,070 primary docidentifiers in relaton-data-iec " \
        "carry an edition facet on a chain — and the canonical render " \
        "prints the edition onto the base designation " \
        "(\"IEC 60068:2005 ED2+AMD1:2012\"), which cannot be re-parsed. " \
        "The consolidated edition is the CSV face (\"IEC " \
        "60034-18-41:2014+AMD1:2019 CSV\", the OBP PDF named {ed1.1}); " \
        "where the printed edition appears it rides the CSV face " \
        "(\"IEC 60068:2005+AMD1:2012 CSV ED1\"), which parses and " \
        "round-trips"

      def self.reject_unrenderable_consolidated_edition(id, input)
        node = id
        while node
          reject_consolidated_edition_shape(node, input)
          node = descend_wrapper(node)
        end
      end

      # The rejected edition shape: a bare ConsolidatedIdentifier with an
      # edition on any member. A leaf or a wrapper whose edition rides its
      # own render face (the Vap's `CSV ED1`) passes.
      def self.reject_consolidated_edition_shape(node, input)
        return unless node.is_a?(Identifiers::ConsolidatedIdentifier)
        return unless Array(node.identifiers).any? { |m| !m.edition.nil? }

        raise Pubid::Errors::ParseError.new(
          CONSOLIDATED_EDITION_MESSAGE, nil,
          input: input, flavor: "iec"
        )
      end

      # from_hash is the shared polymorphic dispatch on Pubid::Identifier.
      # IEC_TYPE_MAP remains as the key_value polymorphic_map.
    end
  end
end
