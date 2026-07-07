# frozen_string_literal: true

module Pubid
  module Iala
    # Base class for all IALA identifiers. Canonical name
    # Pubid::Iala::Identifier; every concrete IALA identifier
    # (Identifiers::*) descends from it, and Identifiers::Base — aliased
    # at the foot of identifiers/base.rb — points back to it.
    #
    # IALA identifiers have the form:
    #   [IALA ]{S|R|G|M|C|X|P}<4-digit number>[-<subpart>][ Ed <edition>][ (<LangLetter>)]
    #
    # Examples:
    #   S1070
    #   IALA S1070 Ed 2.0
    #   R1016:ed2.0(F)
    #   C0103-1 Ed 3.0
    class Identifier < ::Pubid::Identifier
      # Parse an IALA identifier string into an identifier object.
      # @param identifier [String]
      # @return [Pubid::Iala::Identifier]
      # @raise [Parslet::ParseFailed] If parsing fails
      def self.parse(identifier)
        parsed = Parser.parse(identifier)
        Builder.build(parsed)
      rescue Parslet::ParseFailed => e
        raise "Failed to parse IALA identifier '#{identifier}': #{e.message}"
      end

      attribute :publisher, :string, default: "IALA"
      attribute :number,    :string    # "1070", "0126", "0103-1"
      attribute :edition,   :string    # "2.0", "1.3", nil
      attribute :language,  :string    # "E", "F", "S", "C", "A", "R", nil

      IALA_TYPE_MAP = {
        "pubid:iala:standard"       => "Pubid::Iala::Identifiers::Standard",
        "pubid:iala:recommendation" => "Pubid::Iala::Identifiers::Recommendation",
        "pubid:iala:guideline"      => "Pubid::Iala::Identifiers::Guideline",
        "pubid:iala:manual"         => "Pubid::Iala::Identifiers::Manual",
        "pubid:iala:model-course"   => "Pubid::Iala::Identifiers::ModelCourse",
        "pubid:iala:report"         => "Pubid::Iala::Identifiers::Report",
        "pubid:iala:resolution"     => "Pubid::Iala::Identifiers::Resolution",
      }.freeze

      key_value do
        map "_type",    to: :_type, polymorphic_map: IALA_TYPE_MAP
        map "number",   to: :number
        map "edition",  to: :edition
        map "language", to: :language
      end

      def to_urn
        UrnGenerator.new(self).generate
      end

      # Single-letter type code (S, R, G, …) — convenience accessor used
      # by Renderer and UrnGenerator.
      def type_letter
        self.class.type[:short]
      end
    end
  end
end
