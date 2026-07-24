# frozen_string_literal: true

module Pubid
  module Gb
    # Base class for every Chinese Standard identifier AND the flavor's
    # parse/create entry point. Concrete types under Pubid::Gb::Identifiers
    # descend from this class, so a parsed GB id is always an instance of
    # Pubid::Gb::Identifier.
    class Identifier < ::Pubid::Identifier
      # The issuing body code as printed, e.g. "GB", "JB", "T/GZAEPI".
      # Always non-empty for a valid identifier.
      attribute :publisher_code, :string

      # Mandate category: "T" (recommended), "Z" (guideline), or nil
      # (mandatory). Carried after the "/" in the printed form.
      attribute :mandate, :string

      # Document number (digits, possibly dotted with part). Required.
      # Examples: "20223", "5606.1", "001".
      attribute :number, :string

      # Optional part. Captured separately from #number when the input
      # uses the dotted form (e.g. "5606.1" => number "5606", part "1").
      attribute :part, :string

      # All-parts flag — true for "GB/T 5606 (all parts)" forms.
      attribute :all_parts, :boolean, default: -> { false }

      # Polymorphic type map for lutaml key_value (de)serialization.
      GB_TYPE_MAP = {
        "pubid:gb:standard" => "Pubid::Gb::Identifiers::Standard",
      }.freeze

      key_value do
        map "_type", to: :_type, polymorphic_map: GB_TYPE_MAP
        map "publisher_code", to: :publisher_code
        map "mandate", to: :mandate
        map "number", to: :number
        map "part", to: :part
        map "all_parts", to: :all_parts, render_default: false
      end

      PUBLISHER = "CN"

      def to_s(**opts)
        render(format: :human, **opts)
      end

      # Parse a Chinese Standard identifier string.
      # @param identifier [String]
      # @return [Pubid::Gb::Identifier]
      def self.parse(identifier)
        if identifier.length > Pubid::MAX_INPUT_LENGTH
          raise ArgumentError, Pubid::INPUT_TOO_LONG_MESSAGE
        end

        parsed = Parser.parse(identifier)
        Builder.build(parsed)
      rescue Parslet::ParseFailed => e
        raise "Failed to parse Chinese Standard identifier '#{identifier}': #{e.message}"
      end
    end
  end
end
