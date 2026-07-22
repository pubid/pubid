# frozen_string_literal: true

module Pubid
  module Sae
    # Base SAE Identifier. Canonical name Pubid::Sae::Identifier (Identifiers::Base
    # is a back-compat alias). SAE has a single identifier class that IS the
    # document type, so this class is both the base and the only concrete type.
    # Handles all SAE document types (AMS, AIR, ARP, AS, MA).
    class Identifier < ::Pubid::Identifier
      def self.parse(input)
        parsed = Parser.parse(input)
        Builder.build(parsed)
      rescue Parslet::ParseFailed => e
        raise "Failed to parse SAE identifier: #{input}\n#{e.message}"
      end

      attribute :publisher, :string, default: -> { "SAE" }
      attribute :type, Sae::Components::Type
      attribute :number, Sae::Components::Code
      attribute :date, Sae::Components::Date

      def self.type
        { key: :base, web: :standard, title: "Standard", short: "SAE" }
      end

      def year
        date&.year
      end

      # SAE encodes the document class (AS, ARP, AMS, AIR, J, …) in `type.abbr`,
      # not in `typed_stage.type_code`, so the generic mr_type returns nil.
      # Losslessness requires the type letter to appear in MR — without it,
      # `SAE J300` and `SAE AS300` would collide on `SAE.300.<year>`.
      # Lowercased to match the all-lowercase MR convention (issue #142).
      def mr_type
        type&.abbr&.to_s&.downcase
      end
    end

    module Identifiers
      # Backward-compatible alias: SAE's base class used to be
      # Pubid::Sae::Identifiers::Base. It is now Pubid::Sae::Identifier.
      Base = Pubid::Sae::Identifier
    end
  end
end
