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

      # The base Pubid::Identifier no longer auto-maps attributes, so each
      # flavor's top class must declare its own key_value mapping. Subclasses
      # merge their own blocks on top of this one (e.g. SupplementIdentifier
      # adds base_identifier; Directives adds subgroup), so list every base
      # attribute ISO serializes here once.
      key_value do
        map "_type", to: :_type, polymorphic_map: ISO_TYPE_MAP
        map "number", to: :number
        map "part", to: :part
        map "subpart", to: :subpart
        map "stage_iteration", to: :stage_iteration
        map "date", to: :date
        map "edition", to: :edition
        map "languages", to: :languages
        map "publisher", to: :publisher
        map "copublishers", to: :copublishers
        map "type", to: :type
        map "stage", to: :stage
        map "locality", to: :locality
        map "typed_stage", to: :typed_stage
        map "all_parts", to: :all_parts
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

      # lutaml's polymorphic key_value mapping reads `_type` only to validate;
      # it does not re-instantiate the concrete subclass on deserialization. So
      # `Identifier.from_hash(corrigendum_hash)` would return a bare Identifier
      # and drop `base_identifier`. Route by `_type` to the right subclass and
      # let its (inherited) from_hash do the real work, mirroring JIS.
      def self.from_hash(data, options = {})
        type = data["_type"] || data[:_type]
        klass_name = ISO_TYPE_MAP[type]
        if klass_name
          klass = Object.const_get(klass_name)
          return klass.from_hash(data, options) unless klass == self
        end
        super
      end
    end
  end
end
