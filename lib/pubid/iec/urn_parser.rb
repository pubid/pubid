# frozen_string_literal: true

module Pubid
  module Iec
    # Parses IEC URNs in the legacy positional format (relaton-data-iec ground
    # truth):
    #
    #   urn:iec:std:{publisher}:{number}[-{part}]:{date}:{type}:{deliverable}:{language}[:{adjuncts}]
    #
    # Examples:
    # - urn:iec:std:iec:60050:2011:::
    # - urn:iec:std:iec:62547:2013:tr::          (type after date)
    # - urn:iec:std:iec:60050-102:2007:::::amd:1:2017
    # - urn:iec:std:iec:60034-16-3:1996:ts::fr   (deliverable empty, language fr)
    # - urn:iec:std:iec:80000:::ser              (all-parts series)
    #
    # This is a port of relaton-iec's +urn_to_code+: the positional fields are
    # reassembled into a code string which is then run through the text parser
    # (+Identifier.parse+), so there is a single source of truth for building
    # the identifier object.
    class UrnParser
      # Parse IEC URN string
      # @param urn [String] URN string to parse
      # @return [Identifier] parsed identifier
      def self.parse(urn)
        new.parse_urn(urn)
      end

      # Parse URN string into identifier
      # @param urn [String] URN string
      # @return [Identifier] parsed identifier
      def parse_urn(urn)
        unless urn.start_with?("urn:iec:std:")
          raise Pubid::UrnParser::Errors::ParseError, "Invalid IEC URN: #{urn}"
        end

        code, lang, all_parts = urn_to_code(urn)
        unless code
          raise Pubid::UrnParser::Errors::ParseError,
                "Invalid IEC URN: #{urn}"
        end

        id = Pubid::Iec::Identifier.parse(code)
        id.all_parts = true if all_parts && id.class.attributes.key?(:all_parts)
        # The language slot joins codes with a hyphen ("en-fr"). Building one
        # Language from the whole field gave a single bogus language that
        # rendered as "(en-fr)".
        if lang && !lang.empty? && id.class.attributes.key?(:languages)
          id.languages = lang.split("-").map do |code|
            ::Pubid::Components::Language.new(code: code)
          end
        end
        id
      end

      private

      # Port of Relaton::Iec.urn_to_code. Reassembles the positional URN fields
      # into a text code string. Returns [code, language, all_parts].
      def urn_to_code(urn)
        fields = urn.upcase.split(":")
        return if fields.size < 5

        head, num, date, type, deliv, lang = fields[3, 8]
        all_parts = false

        code = head.gsub("-", "/")
        type_code = type_slot_to_code(type)
        code += " #{type_code}" unless type_code.empty?
        code += " #{num}"
        code += ":#{date}" unless date.nil? || date.empty?
        code += adjunct_to_code(fields[9..])

        # "ser" marks an all-parts series rather than a deliverable suffix; it
        # is signalled out-of-band (the code built from a series URN carries no
        # part or date, so to_s renders "IEC NNNN (all parts)").
        if deliv&.casecmp("SER")&.zero?
          all_parts = true
        elsif (edition = edition_slot_to_code(deliv))
          code += " #{edition}"
        elsif deliv && !deliv.empty?
          code += " #{deliv}"
        end

        [code, lang&.downcase, all_parts]
      end

      # The type slot holds either the legacy type token ("TS"), a stage
      # ("STAGE-10.20"), or both ("TS-STAGE-50.00"). A stage is written back as
      # the abbreviation the grammar accepts, resolved from the registry by
      # type code and harmonized code — so the round trip is exact in both
      # directions. See issue #360 item 4.
      def type_slot_to_code(type)
        return "" if type.nil? || type.empty?

        match = /\A(?:([A-Z]+)-)?STAGE-([\d.]+)\z/.match(type)
        return type unless match

        type_code = (match[1] || "IS").downcase
        stage = Pubid::Iec.all_typed_stages.find do |s|
          s.type_code.to_s == type_code &&
            s.harmonized_stages&.first.to_s == match[2]
        end
        return "" unless stage

        stage.abbr.first.to_s
      end

      # "ED-7" in the deliverable slot is an edition, not a deliverable code.
      def edition_slot_to_code(deliv)
        match = /\AED-(.+)\z/.match(deliv.to_s)
        match && "ED#{match[1]}"
      end

      # Port of Relaton::Iec.ajanct_to_code — recursively rebuilds amd/cor/ish
      # adjuncts from (relation, type, number, date) quartets. A "PLUS"
      # relation token (the consolidated "+" marker) yields "+"; otherwise "/".
      def adjunct_to_code(fields)
        return "" if fields.nil? || fields.empty?

        rel, type, num, date = fields[0..3]
        code = (rel.empty? ? "/" : "+") + type + num
        code += ":#{date}" unless date.nil? || date.empty?
        code + adjunct_to_code(fields[4..])
      end
    end
  end
end
