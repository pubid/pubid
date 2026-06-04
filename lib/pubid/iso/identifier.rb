# frozen_string_literal: true

module Pubid
  module Iso
    class Identifier < ::Pubid::Identifier
      # Override base types with ISO-specific ones
      attribute :publisher, ::Pubid::Iso::Components::Publisher
      attribute :copublishers, ::Pubid::Iso::Components::Publisher,
                collection: true
      attribute :number, ::Pubid::Iso::Components::Code
      attribute :part, ::Pubid::Iso::Components::Code
      attribute :subpart, ::Pubid::Iso::Components::Code

      # Polymorphic type map for lutaml::Model key_value serialization
      # Maps polymorphic_name → class name for deserialization
      # Validated by spec to stay in sync with Scheme.identifiers
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
      }.freeze

      # Build type map from Scheme.identifiers for validation
      def self.build_type_map
        Scheme.identifiers.to_h do |klass|
          [klass.polymorphic_name, klass.name]
        end
      end

      key_value do
        map "_type", to: :_type, polymorphic_map: ISO_TYPE_MAP
      end

      def self.parse(string, format: :auto)
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

          Pubid::Iso::Builder.new(Pubid::Iso::Scheme).build(parsed)
        end
      end

      # Factory mirroring pubid 1.x's `Pubid::Iso::Identifier.create` API.
      #
      # Accepts 1.x-style primitive kwargs and dispatches to the correct
      # 2.x `Identifiers::*` subclass via {Pubid::Iso::Scheme}. Coerces
      # primitives into ISO-specific Component objects.
      #
      # Dispatch rules:
      #   * `type:` (e.g. `:tr`, `:amd`)        → lookup via Scheme
      #   * else `stage:` (e.g. `"DIS"`, `"AMD"`) → lookup via Scheme
      #   * else                                → InternationalStandard
      #
      # @param type    [Symbol, String, nil] type key (`:is`, `:tr`, `:amd`, …)
      # @param stage   [String, Symbol, nil] typed-stage abbreviation
      # @param opts    [Hash] remaining attribute primitives:
      #   :publisher (String), :number, :part, :subpart, :year, :edition,
      #   :language
      # @return [Pubid::Iso::Identifier]
      def self.create(type: nil, stage: nil, base: nil, **opts)
        klass = resolve_create_class(type: type, stage: stage)
        attrs = coerce_create_attrs(opts)
        ts = resolve_create_typed_stage(klass, stage)
        if ts
          # dup the (shared) TYPED_STAGES element before tweaking, and set
          # original_abbr to the canonical abbr so rendering matches a
          # parsed identifier (parse records the spelled abbr, e.g. "Amd"
          # not the upcased short_abbr "AMD").
          ts = ts.dup
          ts.original_abbr ||= Array(ts.abbr).first&.to_s
          attrs[:typed_stage] = ts
          # Parse fills `type` and `stage` Components derived from
          # typed_stage; mirror that here so .create round-trips through
          # Pubid::Identifier#== with a parsed identifier.
          attrs[:type] ||= ::Pubid::Components::Type.new(
            name:      ts.name,
            abbr:      Array(ts.abbr).first.to_s,
            type_code: ts.type_code&.to_s,
          )
          attrs[:stage] ||= ::Pubid::Components::Stage.new(
            name:              ts.name,
            stage_code:        ts.stage_code&.to_s,
            abbr:              Array(ts.abbr).first.to_s,
            harmonized_stages: Array(ts.harmonized_stages),
          )
        end
        if supplement_klass?(klass)
          raise ArgumentError, "#{klass} requires a base: identifier" if base.nil?

          attrs[:base_identifier] = build_base_identifier(base)
        end
        klass.new(**attrs)
      end

      # Build the base_identifier for a supplement from either an already
      # constructed identifier or a 1.x-style attribute hash (the nested
      # `:base` entry in a structured index). Recurses so supplement-of-
      # supplement chains (e.g. a Corrigendum to an Amendment) build cleanly.
      def self.build_base_identifier(base)
        return base if base.is_a?(::Pubid::Identifier)

        create(**base.transform_keys(&:to_sym))
      end

      # When `stage:` is explicit, look up the matching TypedStage via
      # Scheme. Otherwise default to the chosen class's "published"
      # TypedStage (so e.g. TR renders the "/TR" prefix). Returns nil if
      # neither is available; the renderer then omits the stage prefix.
      def self.resolve_create_typed_stage(klass, stage)
        if stage
          locate_create_typed_stage(stage)
        elsif klass.const_defined?(:TYPED_STAGES)
          klass.const_get(:TYPED_STAGES).find do |ts|
            ts.stage_code.to_sym == :published
          end
        end
      end

      # Resolve a TypedStage from a create() :stage value. The index may
      # supply it as an abbreviation ("DIS"), a generic stage_code (:dis),
      # or a unique per-typed-stage code (:dtr, :fdisp). Try each in turn.
      def self.locate_create_typed_stage(stage)
        Scheme.locate_typed_stage_by_abbr(stage.to_s) ||
          Scheme.locate_typed_stage_by_stage_code(stage) ||
          Scheme.locate_typed_stage_by_code(stage)
      end

      def self.resolve_create_class(type:, stage:)
        klass =
          if type
            located = locate_klass_by_type_or_short(type)
            raise ArgumentError, "Unknown ISO type: #{type.inspect}" unless located

            located
          elsif stage
            ts = locate_create_typed_stage(stage)
            ts && Scheme.locate_identifier_klass_by_type_code(ts.type_code)
          end
        klass || Identifiers::InternationalStandard
      end

      # Try direct key lookup, then a case-insensitive key lookup (indexes
      # store e.g. "DATA" but the registry key is :data), then fall back to
      # matching the class's :short letter (e.g. type "R" → Recommendation,
      # whose key is :rec and short is "R"). Indexes and legacy data carry
      # either the key, an upper-cased key, or the short form.
      def self.locate_klass_by_type_or_short(type)
        Scheme.locate_identifier_klass_by_type_code(type) ||
          Scheme.locate_identifier_klass_by_type_code(type.to_s.downcase) ||
          Scheme.identifiers.detect { |k| k.type&.dig(:short)&.to_s == type.to_s }
      end

      def self.supplement_klass?(klass)
        Array(Scheme.instance.supplement_identifiers).include?(klass)
      end

      def self.coerce_create_attrs(opts)
        out = {}
        if (v = opts[:publisher])
          # Parse sets copublisher to []; mirror that for hash/equality
          # parity with parsed identifiers.
          out[:publisher] = Components::Publisher.new(
            publisher: v.to_s, copublisher: [],
          )
        end
        %i[number part subpart].each do |k|
          v = opts[k]
          out[k] = Components::Code.new(number: v.to_s) unless v.nil?
        end
        if (v = opts[:year])
          out[:date] = ::Pubid::Components::Date.new(year: v.to_s)
        end
        if (v = opts[:edition])
          out[:edition] = ::Pubid::Components::Edition.new(number: v)
        end
        if (v = opts[:language])
          out[:languages] =
            [::Pubid::Components::Language.new(code: v.to_s)]
        end
        # TODO(create-shim): 1.x also accepted joint_document, tctype,
        # sctype, wgtype, tcnumber, scnumber, wgnumber, dirtype, iteration,
        # base, supplements, amendments, corrigendums, addendum, month,
        # jtc_dir, dir. Add as relaton call sites require them.
        out
      end
      private_class_method :resolve_create_class, :supplement_klass?,
                           :resolve_create_typed_stage, :coerce_create_attrs
    end
  end
end
