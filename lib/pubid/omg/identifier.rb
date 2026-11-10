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

      # The document part: the volume or format segment after the version,
      # e.g. "Superstructure", "Infrastructure", "PDF".
      #
      # This retypes the `part` that ::Pubid::Identifier declares as a
      # Components::Code, because an OMG part is a name and not a numbered
      # part. Reusing the inherited name is what gives relaton `remove_part!`
      # as `exclude(:part)`, and what lets Renderers::Annotator wrap the value
      # from its own TOKENS table. The declaration sits once, on the class
      # every OMG identifier inherits from, whose body lives in this one file
      # and is never reopened — the placement the number-retype tranches
      # require.
      attribute :part, :string

      OMG_TYPE_MAP = {
        "pubid:omg:specification" => "Pubid::Omg::Identifiers::Specification",
      }.freeze

      key_value do
        map "_type", to: :_type, polymorphic_map: OMG_TYPE_MAP
        map "acronym", to: :acronym
        map "version", to: :version
        map "part", to: :part
      end

      PUBLISHER = "OMG"

      def to_s(**opts)
        render(format: :human, **opts)
      end

      # OMG keeps its publisher in the PUBLISHER constant, not the attribute.
      def publisher_prefixes
        [PUBLISHER]
      end

      def self.parse(identifier)
        unless identifier.is_a?(String)
          raise Pubid::Errors::InvalidInputError,
                Pubid::INPUT_NOT_A_STRING_MESSAGE
        end

        if identifier.length > Pubid::MAX_INPUT_LENGTH
          raise Pubid::Errors::InvalidInputError, Pubid::INPUT_TOO_LONG_MESSAGE
        end

        identifier = ::Pubid.utf8_input(identifier)

        parsed = Pubid::Parg::Model.bound(:omg, identifier)
        Builder.build(parsed)
      end

      # A legacy named-tree version emission (see {Pubid::LegacyTreeValue}) —
      # the parsanol 1.3.111 era wrote five relaton-data-omg rows (the beta
      # documents, `version: '[{digit: "2"}]'` for "1.0 beta 2") with the
      # node list in place of the version, because that emission drops every
      # unnamed literal and only the beta tail's `digit` nodes are named in
      # the grammar's version rule. The version body is lost information; the
      # one faithful recovery is the digits themselves (the IEEE builder's
      # per-token join), which re-parse as a version and keep the print
      # stable. Current parses are unaffected — only those rows deserialize
      # through here.
      def self.from_hash(data, options = {})
        return super unless data.is_a?(::Hash)

        value = data["version"] || data[:version]
        digits = LegacyTreeValue.digit_values(value)
        return super unless digits

        out = data.dup
        out[data.key?("version") ? "version" : :version] = digits.join
        super(out, options)
      end
    end
  end
end
