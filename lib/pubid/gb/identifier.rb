# frozen_string_literal: true

module Pubid
  module Gb
    # Base class for every Chinese Standard identifier AND the flavor's
    # parse/create entry point. Concrete types under Pubid::Gb::Identifiers
    # descend from this class, so a parsed GB id is always an instance of
    # Pubid::Gb::Identifier.
    class Identifier < ::Pubid::Identifier
      # The all-parts identifier of this flavor.
      def self.all_parts_class
        Identifiers::AllParts
      end

      # The issuing body code as printed — "GB", "JB", "GBn", "T/GZAEPI" —
      # lives in the `publisher` attribute inherited from ::Pubid::Identifier.
      # The flat-scalar hooks below serialize it as a bare string, and the
      # shared URN generator renders it lowercase, so the series is part of
      # the URN identity (GB 20223 and GBn 20223 are two documents).

      # Mandate category: "T" (recommended), "Z" (guideline), or nil
      # (mandatory). Carried after the "/" in the printed form.
      attribute :mandate, :string

      # Document number (digits, possibly dotted with part). Required.
      # Examples: "20223", "5606.1", "001".
      attribute :number, :string

      # Optional part. Captured separately from #number when the input
      # uses the dotted form (e.g. "5606.1" => number "5606", part "1").
      attribute :part, :string


      # Polymorphic type map for lutaml key_value (de)serialization.
      GB_TYPE_MAP = {
        "pubid:gb:standard" => "Pubid::Gb::Identifiers::Standard",
      }.freeze

      # This block REPLACES the maps of ::Pubid::Identifier, so every
      # attribute the flavor uses must appear here — "date" included, or the
      # publication year is lost in to_hash. The shared flat-scalar rules
      # (Identifier#to_hash / .from_hash) write it as a bare "year" scalar.
      key_value do
        map "_type", to: :_type, polymorphic_map: GB_TYPE_MAP
        map "publisher", to: :publisher
        map "mandate", to: :mandate
        map "number", to: :number
        map "part", to: :part
        map "date", to: :date
      end

      PUBLISHER = "CN"

      # Serialize `publisher` as a bare string instead of a nested
      # {"body" => "GB"}, the CEN/CENELEC precedent. The entry is added for
      # GB's own classes only: a shared entry would change the wire format of
      # every flavor that publishes an index.
      def self.flat_scalar_components
        super.merge(publisher: "publisher")
      end

      def self.flat_scalar_fields
        super.merge(publisher: :body)
      end

      def to_s(**opts)
        render(format: :human, **opts)
      end

      # Parse a Chinese Standard identifier string.
      # @param identifier [String]
      # @return [Pubid::Gb::Identifier]
      def self.parse(identifier)
        unless identifier.is_a?(String)
          raise Pubid::Errors::InvalidInputError,
                Pubid::INPUT_NOT_A_STRING_MESSAGE
        end

        if identifier.length > Pubid::MAX_INPUT_LENGTH
          raise Pubid::Errors::InvalidInputError, Pubid::INPUT_TOO_LONG_MESSAGE
        end

        parsed = Parser.parse(identifier)
        Builder.build(parsed)
      end
    end
  end
end
