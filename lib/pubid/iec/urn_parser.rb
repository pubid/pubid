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
          raise Errors::ParseError, "Invalid IEC URN: #{urn}"
        end

        code, lang, all_parts = urn_to_code(urn)
        raise Errors::ParseError, "Invalid IEC URN: #{urn}" unless code

        id = Pubid::Iec::Identifier.parse(code)
        id.all_parts = true if all_parts && id.class.attributes.key?(:all_parts)
        if lang && !lang.empty? && id.class.attributes.key?(:languages)
          id.languages = [::Pubid::Components::Language.new(code: lang)]
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
        code += " #{type}" unless type.nil? || type.empty?
        code += " #{num}"
        code += ":#{date}" unless date.nil? || date.empty?
        code += adjunct_to_code(fields[9..])

        # "ser" marks an all-parts series rather than a deliverable suffix; it
        # is signalled out-of-band (the code built from a series URN carries no
        # part or date, so to_s renders "IEC NNNN (all parts)").
        if deliv&.casecmp("SER")&.zero?
          all_parts = true
        elsif deliv && !deliv.empty?
          code += " #{deliv}"
        end

        [code, lang&.downcase, all_parts]
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
