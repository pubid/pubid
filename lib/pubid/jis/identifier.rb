# frozen_string_literal: true

module Pubid
  module Jis
    # Base class for every JIS identifier AND the flavor's parse/create entry
    # point — mirrors Pubid::Iso::Identifier. Concrete identifiers under
    # Pubid::Jis::Identifiers descend from this class, so a parsed JIS id is an
    # instance of Pubid::Jis::Identifier.
    class Identifier < ::Pubid::Identifier
      # JIS keeps its number flat at the top level (string, to preserve leading
      # zeros like "0205"), with the division letter in `series` and any
      # multi-level part numbers in `parts`. Supplements override `number` with
      # their integer sequence number; the document number then lives on `base`.
      attribute :number, :string
      attribute :series, :string # Division letter A-Z
      attribute :parts, :string, collection: true # Optional multi-level parts
      attribute :year, :integer
      attribute :language, :string # "E" or "J"
      # Boolean flags carry no default, so they stay nil (and are omitted from
      # the serialized hash) unless actually set true.
      attribute :all_parts, :boolean
      # Reaffirmation (再確認): a trailing "R" on the year marks an edition
      # that was reaffirmed without revision (e.g. ":2019R").
      attribute :reaffirmed, :boolean
      # Graphical-symbol sub-reference (JIS Z 8210 etc.): the value after
      # "SYMBOL". nil means no SYMBOL clause; an empty string means a bare
      # "SYMBOL" keyword with no value.
      attribute :symbol, :string

      # Polymorphic type map for lutaml::Model key_value (de)serialization:
      # maps each subclass's polymorphic_name to its class name so a stored
      # hash rebuilds the correct identifier type via from_hash.
      JIS_TYPE_MAP = {
        "pubid:jis:japanese-industrial-standard" =>
          "Pubid::Jis::Identifiers::JapaneseIndustrialStandard",
        "pubid:jis:standard" => "Pubid::Jis::Identifiers::Standard",
        "pubid:jis:technical-report" =>
          "Pubid::Jis::Identifiers::TechnicalReport",
        "pubid:jis:technical-specification" =>
          "Pubid::Jis::Identifiers::TechnicalSpecification",
        "pubid:jis:amendment" => "Pubid::Jis::Identifiers::Amendment",
        "pubid:jis:corrigendum" => "Pubid::Jis::Identifiers::Corrigendum",
        "pubid:jis:explanation" => "Pubid::Jis::Identifiers::Explanation",
      }.freeze

      key_value do
        map "_type", to: :_type, polymorphic_map: JIS_TYPE_MAP
        map "series", to: :series
        map "number", to: :number
        map "parts", to: :parts
        map "year", to: :year
        map "language", to: :language
        map "all_parts", to: :all_parts
        map "reaffirmed", to: :reaffirmed
        # render_empty keeps a bare "SYMBOL" (empty-string value) in the hash so
        # it round-trips distinctly from "no symbol" (nil).
        map "symbol", to: :symbol, render_empty: true
      end

      # Publisher is always "JIS". A plain constant (not a `publisher` method)
      # so it doesn't shadow the inherited lutaml `publisher` attribute, which
      # would otherwise fail serialization type validation.
      PUBLISHER = "JIS"

      def all_parts?
        all_parts == true
      end

      def reaffirmed?
        reaffirmed == true
      end

      # Render a year with its reaffirmation marker, e.g. "2019R".
      def year_with_reaffirmation
        "#{year}#{'R' if reaffirmed?}"
      end

      # Render the trailing " SYMBOL[ <value>]" clause, or "" when absent.
      def symbol_suffix
        return "" if symbol.nil?

        symbol.empty? ? " SYMBOL" : " SYMBOL #{symbol}"
      end

      # The rendered document code, e.g. "B 0205-1" (series, number, parts).
      # A convenience for rendering; the underlying data is the flat
      # series/number/parts attributes.
      def code
        result = "#{series} #{number}"
        result += parts.map { |p| "-#{p}" }.join if parts&.any?
        result
      end

      # Comparison with all_parts logic
      # When either identifier has all_parts=true, compare only series and number
      def ==(other)
        return false unless other.is_a?(Identifier)

        if all_parts? || other.all_parts?
          # Compare only series and number, ignore year, parts, all_parts
          return series == other.series && number == other.number
        end

        # Normal full comparison
        series == other.series &&
          number == other.number &&
          (parts || []) == (other.parts || []) &&
          year == other.year &&
          language == other.language &&
          all_parts? == other.all_parts? &&
          reaffirmed? == other.reaffirmed? &&
          symbol == other.symbol
      end

      # Basic string representation. Delegates to renderer.
      def to_s(**opts)
        render(format: :human, **opts)
      end

      # JIS exposes its publisher as the `PUBLISHER` constant rather than the
      # inherited `publisher` attribute, so the generic mr_publisher returns
      # nil. Without this override every JIS id would lose its "JIS." prefix.
      def mr_publisher
        PUBLISHER
      end

      # JIS stores its identity across `series` (division letter A–Z), `number`
      # (string, may have leading zeros), and `parts` (multi-level). The
      # generic mr_number_with_part only knows about `number`/`part`/`subpart`,
      # so without these overrides every JIS id would collapse onto its
      # document number and drop the division letter (issue #142).
      def mr_type
        return nil unless respond_to?(:type_prefix)

        type_prefix&.downcase
      end

      def mr_number_with_part
        segments = []
        segments << series.to_s if series
        segments << number.to_s if number
        parts&.each { |p| segments << p.to_s }
        return nil if segments.empty?

        segments.join("-")
      end

      # JIS stores the year as a bare integer (not a Components::Date), so the
      # inherited mr_year (which reads `date`) returns nil. Emit it directly,
      # including the reaffirmation marker so `JIS X:2019` and `JIS X:2019R`
      # stay distinct in MR.
      def mr_year
        return nil unless year

        year_with_reaffirmation.to_s
      end

      def mr_languages
        return nil unless language

        "(#{language})"
      end

      def mr_all_parts
        return nil unless all_parts?

        "all-parts"
      end

      # from_hash is the shared polymorphic dispatch on Pubid::Identifier.
      # JIS_TYPE_MAP remains as the key_value polymorphic_map.

      # Parse a JIS identifier string into an identifier object
      # @param identifier [String] The JIS identifier string to parse
      # @return [Identifier] The appropriate identifier object
      # @raise [RuntimeError] If parsing fails
      def self.parse(identifier)
        parsed = Parser.parse(identifier)
        Builder.build(parsed)
      rescue Parslet::ParseFailed => e
        raise "Failed to parse JIS identifier '#{identifier}': #{e.message}"
      end
    end
  end
end
