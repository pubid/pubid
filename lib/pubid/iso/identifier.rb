# frozen_string_literal: true

module Pubid
  module Iso
    class Identifier < ::Pubid::Identifier
      # Override base types with ISO-specific ones.
      # Defaults to the type's implied publisher (ISO for most; IWA has none),
      # so an omitted publisher key reconstructs correctly on from_hash.
      attribute :publisher, ::Pubid::Iso::Components::Publisher,
                default: -> { self.class.default_publisher }
      attribute :copublishers, ::Pubid::Iso::Components::Publisher,
                collection: true

      # The publisher implied when none is serialized. ISO for most types;
      # publisher-less types (IWA) override this to nil.
      def self.default_publisher
        ::Pubid::Iso::Components::Publisher.new
      end

      # typed_stage is the single source of truth for stage (and, with the class,
      # the doctype). Default to the class's published typed_stage, so an omitted
      # "stage" key reconstructs the published state on from_hash.
      attribute :typed_stage, ::Pubid::Components::TypedStage,
                default: -> { self.class.published_typed_stage }

      # The class's published typed_stage (canonical surface form), or nil for
      # types with no stages (e.g. TC documents).
      def self.published_typed_stage
        return nil unless const_defined?(:TYPED_STAGES)

        ts = self::TYPED_STAGES.find { |t| t.stage_code.to_s == "published" }
        return nil unless ts

        ts = ts.dup
        ts.original_abbr = ts.canonical_abbreviation
        ts
      end

      # type and stage are derived from typed_stage, never stored — so the
      # doctype (fixed by the class / _type) can't be lost when "stage" is
      # omitted for the published default.
      def type
        typed_stage&.to_type
      end

      def stage
        typed_stage&.to_stage
      end

      # Return a copy with the lifecycle stage set from an ISO harmonized stage
      # code (e.g. "90.92"). typed_stage is the single source of truth, so this
      # is all that is needed to surface the stage in #to_s and #to_urn. Returns
      # an unchanged copy if the code is not recognised.
      def with_harmonized_stage(harmonized_code)
        ts = Pubid::Iso.locate_stage_by_harmonized_code(harmonized_code)
        ts ? dup.tap { |id| id.typed_stage = ts } : dup
      end

      attribute :number, ::Pubid::Iso::Components::Code
      attribute :part, ::Pubid::Iso::Components::Code
      attribute :subpart, ::Pubid::Iso::Components::Code

      # Polymorphic type map for lutaml::Model key_value serialization
      # Maps polymorphic_name → class name for deserialization
      # Validated by spec to stay in sync with identifier_types
      ISO_TYPE_MAP = {
        "pubid:iso:international-standard" => "Pubid::Iso::Identifiers::InternationalStandard",
        "pubid:iso:international-standardized-profile" => "Pubid::Iso::Identifiers::InternationalStandardizedProfile",
        "pubid:iso:international-workshop-agreement" => "Pubid::Iso::Identifiers::InternationalWorkshopAgreement",
        "pubid:iso:technical-report" => "Pubid::Iso::Identifiers::TechnicalReport",
        "pubid:iso:technical-specification" => "Pubid::Iso::Identifiers::TechnicalSpecification",
        "pubid:iso:pas" => "Pubid::Iso::Identifiers::Pas",
        "pubid:iso:guide" => "Pubid::Iso::Identifiers::Guide",
        "pubid:iso:recommendation" => "Pubid::Iso::Identifiers::Recommendation",
        "pubid:iso:amendment" => "Pubid::Iso::Identifiers::Amendment",
        "pubid:iso:corrigendum" => "Pubid::Iso::Identifiers::Corrigendum",
        "pubid:iso:supplement" => "Pubid::Iso::Identifiers::Supplement",
        "pubid:iso:addendum" => "Pubid::Iso::Identifiers::Addendum",
        "pubid:iso:extract" => "Pubid::Iso::Identifiers::Extract",
        "pubid:iso:directives" => "Pubid::Iso::Identifiers::Directives",
        "pubid:iso:directives-supplement" => "Pubid::Iso::Identifiers::DirectivesSupplement",
        "pubid:iso:data" => "Pubid::Iso::Identifiers::Data",
        "pubid:iso:tc-document" => "Pubid::Iso::Identifiers::TcDocument",
        "pubid:iso:technology-trends-assessments" => "Pubid::Iso::Identifiers::TechnologyTrendsAssessments",
        "pubid:iso:bundled-identifier" => "Pubid::Iso::BundledIdentifier",
      }.freeze

      # BundledIdentifier lives outside Pubid::Iso::Identifiers but carries a
      # polymorphic `_type`, so the shared polymorphic_type_map needs it
      # explicitly (see Pubid::Identifier#additional_identifier_classes).
      def self.additional_identifier_classes
        [Pubid::Iso::BundledIdentifier]
      end
      private_class_method :additional_identifier_classes

      # Build type map from Pubid::Iso.identifier_types for validation
      def self.build_type_map
        Pubid::Iso.identifier_types.to_h do |klass|
          [klass.polymorphic_name, klass.name]
        end
      end

      # The base Pubid::Identifier no longer auto-maps attributes, so each
      # flavor's top class must declare its own key_value mapping. Subclasses
      # merge their own blocks on top of this one (e.g. SupplementIdentifier
      # adds base; Directives adds subgroup), so list every base
      # attribute ISO serializes here once.
      key_value do
        map "_type", to: :_type, polymorphic_map: ISO_TYPE_MAP
        # Code components serialize as their plain string value, not {value,number}.
        map "number", with: { to: :number_to_kv, from: :number_from_kv }
        map "part", with: { to: :part_to_kv, from: :part_from_kv }
        map "subpart", with: { to: :subpart_to_kv, from: :subpart_from_kv }
        map "stage_iteration",
            with: { to: :stage_iteration_to_kv, from: :stage_iteration_from_kv }
        # date serialized flat as year/month/day, nils omitted.
        map "year", with: { to: :year_to_kv, from: :year_from_kv }
        map "month", with: { to: :month_to_kv, from: :month_from_kv }
        map "day", with: { to: :day_to_kv, from: :day_from_kv }
        # ISO/IEC undated reference (e.g. ISO 16634:--). The `false` default
        # is omitted; only the meaningful `true` round-trips via to_hash.
        map "undated", with: { to: :undated_to_kv, from: :undated_from_kv }
        map "edition", to: :edition
        map "languages", to: :languages
        # publisher emitted only when the primary isn't the type default;
        # copublishers (the other bodies) as an array, omitted when empty.
        map "publisher", with: { to: :publisher_to_kv, from: :publisher_from_kv }
        map "copublishers", with: { to: :copublishers_to_kv, from: :copublishers_from_kv }
        map "locality", to: :locality
        # `type` and generic `stage` are fully derived from `typed_stage`
        # (builder sets them via to_type/to_stage), so we serialize only the
        # unique typed-stage `code` under "stage" and recompute the rest on
        # load. _type already pins the document type.
        map "stage", with: { to: :stage_to_kv, from: :stage_from_kv }
        # Omit the `false` default; only the meaningful `true` is serialized.
        map "all_parts", with: { to: :all_parts_to_kv, from: :all_parts_from_kv }
      end

      def all_parts_to_kv(model, doc)
        return unless model.all_parts

        doc.add_child(
          Lutaml::KeyValue::DataModel::Element.new("all_parts", true),
        )
      end

      def all_parts_from_kv(model, value)
        model.all_parts = value
      end

      # Serialize typed_stage as just its unique code (e.g. "is", "dis",
      # "committee_draft_amd"). type/stage are recomputed from it on load.
      def stage_to_kv(model, doc)
        ts = model.typed_stage
        return unless ts&.code
        # Omit the published default (recomputed from the class on load).
        return if ts.stage_code.to_s == "published"

        doc.add_child(
          Lutaml::KeyValue::DataModel::Element.new("stage", ts.code.to_s),
        )
      end

      # Resolve the typed-stage code back to the full TypedStage within this
      # identifier's class, then derive type/stage from it.
      def stage_from_kv(model, value)
        return if value.nil? || value.to_s.empty?

        ts = (model.class.const_defined?(:TYPED_STAGES) &&
              model.class::TYPED_STAGES.find { |t| t.code.to_s == value.to_s }) ||
             Pubid::Iso::Scheme.locate_typed_stage_by_code(value)
        return unless ts

        # The renderer prefers `original_abbr` (the parsed surface form); without
        # it the supplement renderer falls back to `short_abbr` (e.g. "AMD").
        # Resolving from a code has no surface form, so render the canonical
        # abbreviation (`abbr.first`, e.g. "Amd").
        ts = ts.dup
        ts.original_abbr = ts.canonical_abbreviation
        model.typed_stage = ts
      end

      # --- Code components <-> plain string ---
      def number_to_kv(model, doc) = emit_code(doc, "number", model.number)
      def number_from_kv(model, value) = model.number = build_code(value)
      def part_to_kv(model, doc) = emit_code(doc, "part", model.part)
      def part_from_kv(model, value) = model.part = build_code(value)
      def subpart_to_kv(model, doc) = emit_code(doc, "subpart", model.subpart)
      def subpart_from_kv(model, value) = model.subpart = build_code(value)

      def stage_iteration_to_kv(model, doc)
        iter = model.stage_iteration
        v = iter.is_a?(::Pubid::Components::Iteration) ? iter.number : iter
        return if v.nil? || v.to_s.empty?

        doc.add_child(Lutaml::KeyValue::DataModel::Element.new("stage_iteration",
                                                                v.to_s))
      end

      def stage_iteration_from_kv(model, value)
        model.stage_iteration = ::Pubid::Components::Iteration.new(number: value.to_s)
      end

      def emit_code(doc, key, code)
        v = code.is_a?(::Pubid::Components::Code) ? code.value : code
        return if v.nil? || v.to_s.empty?

        doc.add_child(Lutaml::KeyValue::DataModel::Element.new(key, v.to_s))
      end

      def build_code(value)
        ::Pubid::Iso::Components::Code.new(value: value.to_s)
      end

      # --- date serialized flat as year/month/day ---
      def year_to_kv(model, doc) = emit_date_part(doc, "year", model.date&.year)
      def year_from_kv(model, value) = date_for(model).year = value.to_s
      def month_to_kv(model, doc) = emit_date_part(doc, "month", model.date&.month)
      def month_from_kv(model, value) = date_for(model).month = value.to_s
      def day_to_kv(model, doc) = emit_date_part(doc, "day", model.date&.day)
      def day_from_kv(model, value) = date_for(model).day = value.to_s

      # --- date undated flag (ISO/IEC undated reference, e.g. ISO 16634:--) ---
      # The `false` default is omitted; only the meaningful `true` round-trips
      # via to_hash / from_hash.
      def undated_to_kv(model, doc)
        return unless model.date&.undated?

        doc.add_child(Lutaml::KeyValue::DataModel::Element.new("undated", true))
      end

      def undated_from_kv(model, value)
        date_for(model).undated = value.to_s == "true"
      end

      def emit_date_part(doc, key, val)
        return if val.nil? || val.to_s.empty?

        doc.add_child(Lutaml::KeyValue::DataModel::Element.new(key, val.to_s))
      end

      def date_for(model)
        model.date ||= ::Pubid::Components::Date.new
      end

      # --- publisher: primary only when non-default; copublishers as a list ---
      def publisher_to_kv(model, doc)
        pub = model.publisher&.publisher
        return if pub.nil? || pub == model.class.default_publisher&.publisher

        doc.add_child(Lutaml::KeyValue::DataModel::Element.new("publisher", pub))
      end

      def publisher_from_kv(model, value)
        publisher_for(model).publisher = value.to_s
      end

      def copublishers_to_kv(model, doc)
        cp = model.publisher&.copublisher
        return unless cp&.any?

        doc.add_child(
          Lutaml::KeyValue::DataModel::Element.new("copublishers", cp.map(&:to_s)),
        )
      end

      def copublishers_from_kv(model, value)
        list = Array(value).map(&:to_s)
        return unless list.any?

        # Mirror Builder#parse: copublishers live both on the primary
        # publisher (as strings) and as the top-level `copublishers`
        # collection of Publisher objects. `==` compares the latter, so
        # populate both or a deserialized id never equals a parsed one.
        publisher_for(model).copublisher = list
        model.copublishers = list.map do |cp|
          ::Pubid::Iso::Components::Publisher.new(publisher: cp)
        end
      end

      def publisher_for(model)
        model.publisher ||= ::Pubid::Iso::Components::Publisher.new
      end

      def self.parse(string, format: :auto)
        if string.length > Pubid::MAX_INPUT_LENGTH
          raise ArgumentError, Pubid::INPUT_TOO_LONG_MESSAGE
        end

        format = Pubid::FormatDetector.detect(string) if format == :auto

        case format
        when :urn
          Pubid::Iso::UrnParser.parse(string)
        when :mr_string
          Pubid::Parsers::MrString.parse(string)
        else
          parsed = Pubid::Iso::Parser.new.parse(string)
          if parsed.nil? || parsed.empty?
            raise Pubid::Iso::Parser::ParseError,
                  "Invalid identifier format"
          end

          Pubid::Iso::Builder.new.build(parsed)
        end
      end

      # from_hash is the shared polymorphic dispatch on Pubid::Identifier, which
      # routes `_type` through polymorphic_type_map (ISO_TYPE_MAP's dynamic
      # equivalent). ISO_TYPE_MAP remains as the key_value polymorphic_map.
    end
  end
end
