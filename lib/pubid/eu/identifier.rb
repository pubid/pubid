# frozen_string_literal: true

module Pubid
  module Eu
    # Base class for every EU legal act AND the flavor's parse entry point.
    #
    # Identity is the type (the leaf class), the year (+date+) and the
    # +number+ — the three parts of a CELEX number. +family+ is the bracketed
    # legal family of the Official Journal form (`(EU)`, `(EC)` …); the
    # canonical reference omits it, so a reference with no family matches a
    # row that has one (`===`).
    class Identifier < ::Pubid::Identifier
      # The legal family: EU, EC, EEC, Euratom or CFSP.
      attribute :family, :string

      # The print order of the two numbers. nil applies the default rule
      # (#default_number_first?); the builder sets it only when the input
      # used the other order, so the flag is rare in an index row.
      attribute :number_first, :boolean

      # The order is spelling, not identity: "EU Decision 1082/2013" and the
      # CELEX number 32013D1082 name one act.
      equality_ignored :number_first

      EU_TYPE_MAP = {
        "pubid:eu:regulation" => "Pubid::Eu::Identifiers::Regulation",
        "pubid:eu:directive" => "Pubid::Eu::Identifiers::Directive",
        "pubid:eu:decision" => "Pubid::Eu::Identifiers::Decision",
      }.freeze

      key_value do
        map "_type", to: :_type, polymorphic_map: EU_TYPE_MAP
        map "number", to: :number
        map "date", to: :date
        map "family", to: :family
        map "number_first", to: :number_first
      end

      PUBLISHER = "EU"

      # From 2015 every act prints <year>/<number>. Before 2015 a regulation
      # printed <number>/<year>; other acts used both orders, so they default
      # to <year>/<number> and keep the input order in +number_first+.
      FIXED_ORDER_YEAR = 2015

      def self.type
        { key: :identifier, title: "", celex: nil, eli: nil }
      end

      # The year is identity, not an edition: 1227/2011 and 1227/2012 are two
      # acts. So an all-parts wrapper keeps the date (the default drops it,
      # which printed "EU Regulation 1227/ (all parts)").
      def self.all_parts_edition_keys
        super - %i[date year]
      end

      def default_number_first?
        is_a?(Identifiers::Regulation) && year.to_i < FIXED_ORDER_YEAR
      end

      def number_first?
        number_first.nil? ? default_number_first? : number_first
      end

      def to_s(**opts)
        render(format: :human, **opts)
      end

      # EU keeps its publisher in the PUBLISHER constant, not the attribute.
      def publisher_prefixes
        [PUBLISHER]
      end

      # The CELEX number: sector 3, year, type letter, number padded to 4.
      def to_celex
        "3#{year}#{self.class.type[:celex]}#{number.rjust(4, '0')}"
      end

      # The ELI of the act as published in the Official Journal.
      def to_eli
        "http://data.europa.eu/eli/#{self.class.type[:eli]}/#{year}/#{number}/oj"
      end

      # The EU has no registered URN namespace (the ELI is its official
      # identifier, #to_eli). This pubid-invented form keeps the act type,
      # so a regulation and a decision with the same numbers do not collide.
      def to_urn
        "urn:eu:#{self.class.type[:eli]}:#{year}:#{number}"
      end

      # MR string: eu.<eli type>.<number>.<year>, e.g. eu.reg.1227.2011.
      def mr_publisher
        PUBLISHER.downcase
      end

      def mr_type
        self.class.type[:eli]
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

        parsed = Pubid::Parg::Model.bound(:eu, identifier)
        Builder.build(parsed, identifier)
      end
    end
  end
end
