# frozen_string_literal: true

module Pubid
  module Omg
    # Base class for every OMG identifier AND the flavor's parse/create
    # entry point.
    class Identifier < ::Pubid::Identifier
      # The spec family acronym, e.g. "AMI4CCM", "UML", "CORBA".
      attribute :acronym, :string

      # Free-form version string. Stored verbatim because OMG versioning is
      # loose ("1.0", "2.5.1", "5 beta 3", "1.1"). Use Version#to_s for
      # rendering.
      attribute :version, :string

      OMG_TYPE_MAP = {
        "pubid:omg:specification" => "Pubid::Omg::Identifiers::Specification",
      }.freeze

      key_value do
        map "_type", to: :_type, polymorphic_map: OMG_TYPE_MAP
        map "acronym", to: :acronym
        map "version", to: :version
      end

      PUBLISHER = "OMG"

      def to_s(**opts)
        render(format: :human, **opts)
      end

      def self.parse(identifier)
        if identifier.length > Pubid::MAX_INPUT_LENGTH
          raise ArgumentError, Pubid::INPUT_TOO_LONG_MESSAGE
        end

        parsed = Parser.parse(identifier)
        Builder.build(parsed)
      rescue Parslet::ParseFailed => e
        raise "Failed to parse OMG identifier '#{identifier}': #{e.message}"
      end
    end
  end
end
