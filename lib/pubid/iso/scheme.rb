# frozen_string_literal: true

module Pubid
  module Iso
    # ISO Scheme with memoized parser/builder and hash-based indexing
    class Scheme < Pubid::Scheme
      class << self
        # Singleton instance for memoization
        # @return [Pubid::Iso::Scheme] the singleton scheme instance
        def instance
          @instance ||= new
        end

        # Delegate class methods to singleton instance for backward compatibility
        # @param identifier [String] the identifier string to parse
        # @return [Identifier] the parsed identifier
        def parse(identifier)
          instance.parse(identifier)
        end

        # @param abbr [String, Symbol] the abbreviation to find
        # @return [TypedStage] the matching typed stage
        def locate_typed_stage_by_abbr(abbr)
          instance.locate_typed_stage_by_abbr(abbr)
        end

        # @param type_code [String, Symbol] the type code to find
        # @return [Class] the matching identifier class
        def locate_identifier_klass_by_type_code(type_code)
          instance.locate_identifier_klass_by_type_code(type_code)
        end

        # @param stage_code [String, Symbol] the stage code to find
        # @return [TypedStage] the matching typed stage
        def locate_typed_stage_by_stage_code(stage_code)
          instance.locate_typed_stage_by_stage_code(stage_code)
        end

        # @param harmonized_code [String] the harmonized stage code to find
        # @return [TypedStage, nil] the matching typed stage
        def locate_typed_stage_by_harmonized_code(harmonized_code)
          instance.locate_typed_stage_by_harmonized_code(harmonized_code)
        end

        # Keep existing class methods for backward compatibility
        # @return [Array<Class>] all base identifier classes
        def identifiers
          [
            Identifiers::InternationalStandard,
            Identifiers::TechnicalReport,
            Identifiers::TechnicalSpecification,
            Identifiers::Guide,
            Identifiers::Pas,
            Identifiers::Data,
            Identifiers::TechnologyTrendsAssessments,
            Identifiers::InternationalWorkshopAgreement,
            Identifiers::InternationalStandardizedProfile,
            Identifiers::Recommendation,
            Identifiers::Directives,
            Identifiers::Amendment,
            Identifiers::Corrigendum,
            Identifiers::Supplement,
            Identifiers::Extract,
            Identifiers::DirectivesSupplement,
            Identifiers::Addendum,
            Identifiers::TcDocument,
          ]
        end

        def typed_stages
          identifiers.flat_map { |klass| klass::TYPED_STAGES }.compact
        end

        def supplement_typed_stages
          supplement_identifiers = [
            Identifiers::Amendment,
            Identifiers::Corrigendum,
            Identifiers::Supplement,
            Identifiers::Extract,
            Identifiers::Addendum,
          ]
          supplement_identifiers.flat_map { |klass| klass::TYPED_STAGES }
        end
      end

      # Initialize the scheme with identifiers
      def initialize
        super(
          identifiers: self.class.identifiers,
          supplement_identifiers: [
            Identifiers::Amendment,
            Identifiers::Corrigendum,
            Identifiers::Supplement,
            Identifiers::Extract,
            Identifiers::Addendum,
          ],
        )
      end

      # Parse an ISO identifier string using memoized parser/builder
      # @param identifier [String] the identifier string to parse
      # @return [Identifier] the parsed identifier
      def parse(identifier)
        # Handle DAD/FDAD patterns that parser can't recognize
        if match = identifier.match(/^(.+?)\/(F?DAD)\s+(\d+)(?::(\d{4}))?$/)
          parse_dad_pattern(match)
        else
          # Normalize Cyrillic (Russian) identifiers to Latin equivalents
          normalized = normalize_cyrillic(identifier)
          parsed = parser.parse(normalized)
          builder.build(parsed)
        end
      end

      private

      # Memoized parser instance
      # @return [Pubid::Iso::Parser] parser instance
      def parser
        @parser ||= ::Pubid::Iso::Parser.new
      end

      # Memoized builder instance
      # @return [Pubid::Iso::Builder] builder instance
      def builder
        @builder ||= ::Pubid::Iso::Builder.new(self)
      end

      # Normalize Cyrillic (Russian) ISO identifiers to Latin equivalents
      # ИСО = ISO, МЭК = IEC, Руководство/Руководства = Guide,
      # ОПМС = FDIS, ПМС = DIS, ТО = TR, ТС = TS
      def normalize_cyrillic(identifier)
        return identifier unless identifier.match?(/[а-яА-Я]/)

        normalized = identifier.dup
        # Remove inline comments (Russian style comments with #)
        normalized = normalized.gsub(/\s*#\s*.*$/, "")
        # Translate Russian abbreviations (order matters: longer first)
        normalized = normalized.gsub("Руководства", "GUIDE")
        normalized = normalized.gsub("Руководство", "GUIDE")
        normalized = normalized.gsub("ИСО/МЭК", "ISO/IEC")
        normalized = normalized.gsub("ИСО/ОПМС", "ISO/FDIS")
        normalized = normalized.gsub("ИСО/ПМС", "ISO/DIS")
        normalized = normalized.gsub("ИСО/ТО", "ISO/TR")
        normalized = normalized.gsub("ИСО/ТС", "ISO/TS")
        normalized = normalized.gsub("ИСО", "ISO")
        normalized = normalized.gsub("МЭК", "IEC")
        # Standalone Cyrillic stage abbreviations (after publisher replacements)
        normalized = normalized.gsub("ТО", "TR")
        normalized = normalized.gsub("ТС", "TS")
        normalized = normalized.gsub("ОПМС", "FDIS")
        normalized = normalized.gsub("ПМС", "DIS")
        normalized.strip
      end

      # Parse DAD/FDAM pattern manually
      # Pattern: "ISO 2631/DAD 1" or "ISO 2553/DAD 1:1987"
      # The parser fails because it treats "/" as copublisher separator
      def parse_dad_pattern(match)
        base_str = match[1]          # "ISO 2631" or "ISO 2553"
        stage_abbr = match[2]        # "DAD" or "FDAD"
        supplement_number = match[3] # "1"
        supplement_year = match[4]   # "1987" or nil

        # Parse the base identifier normally (without supplement)
        base_parsed = parser.parse(base_str)
        base_identifier = builder.build(base_parsed)

        # Construct the Addendum supplement manually
        addendum = Identifiers::Addendum.new
        addendum.base_identifier = base_identifier
        addendum.number = ::Pubid::Components::Code.new(number: supplement_number)
        addendum.date = Pubid::Components::Date.new(year: supplement_year) if supplement_year

        # Set typed_stage from register (uses TYPED_STAGES in Addendum class)
        typed_stage = locate_typed_stage_by_abbr(stage_abbr)
        addendum.typed_stage = typed_stage
        addendum.stage = typed_stage.to_stage
        addendum.type = typed_stage.to_type

        addendum
      end
    end
  end
end
