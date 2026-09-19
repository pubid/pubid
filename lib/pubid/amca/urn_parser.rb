# frozen_string_literal: true

module Pubid
  module Amca
    # Parses AMCA URNs back into identifiers.
    #
    # UrnGenerator emits:
    #   urn:amca:{number}[:{year}][:{keyed tokens}][:{type}]
    #
    # The keyed tokens are `interp.<code>`, `rev.<revision>`,
    # `reaff.<year>` and `copub.<publisher>`; the type is the key of the
    # identifier class. The parser rebuilds the printed form from them and
    # parses that, so the identifier comes back as the same class.
    #
    # Examples:
    # - urn:amca:210:08                             → AMCA 210-08
    # - urn:amca:211:22:rev.01-23:copub.amca:publication
    #                            → AMCA Publication 211-22 (Rev. 01-23)
    # - urn:amca:99:interp.jw:copub.amca:interpretation → AMCA 99 JW Interp
    class UrnParser < Pubid::UrnParser::Base
      TYPE_TITLES = {
        "standard" => "Standard",
        "publication" => "Publication",
      }.freeze

      def parse_urn(urn)
        number, *rest = split_parts(strip_namespace(urn))
        year = rest.shift if rest.first&.match?(/\A\d+\z/)
        keyed = rest.grep(/\./).to_h { |token| token.split(".", 2) }
        type = (rest - keyed.map { |k, v| "#{k}.#{v}" }).last

        flavor_parse(printed(number, year, keyed, type))
      end

      private

      def printed(number, year, keyed, type)
        publisher = keyed.fetch("copub", "amca").upcase
        return interpretation(publisher, number, keyed) if type == "interpretation"

        text = [publisher, TYPE_TITLES[type], number].compact.join(" ")
        text += "-#{year}" if year
        text += " (Rev. #{keyed['rev']})" if keyed["rev"]
        text += " (R#{keyed['reaff']})" if keyed["reaff"]
        text
      end

      def interpretation(publisher, number, keyed)
        code = keyed["interp"]&.upcase
        [publisher, number, code, "Interp"].compact.join(" ")
      end
    end
  end
end
