# frozen_string_literal: true

module Pubid
  module Calconnect
    # Parses CalConnect URNs back into identifiers.
    #
    # UrnGenerator emits: urn:calconnect[:<series>]:<number>:<date>
    #   urn:calconnect:18011:2018            → CC 18011:2018
    #   urn:calconnect:DIR:10006:2019        → CC/DIR 10006:2019
    #   urn:calconnect:WD:51017:2024-07-23   → CC/WD 51017:2024-07-23
    #
    # The date segment (year or full "YYYY-MM-DD") never contains a colon, so
    # it is a single trailing part; the number precedes it, and an optional
    # series precedes the number.
    #
    # This positional pop assumes a *dated* URN (the form UrnGenerator emits for
    # a full id). A partial (date-less) reference has no round-trippable URN —
    # see UrnGenerator — so this parser is only guaranteed for URNs produced
    # from a full id; a date-less URN misaligns the pops and will not parse.
    class UrnParser < Pubid::UrnParser::Base
      def parse_urn(urn)
        parts = split_parts(strip_namespace(urn))
        date = parts.pop
        number = parts.pop
        series = parts.pop

        text = +"CC"
        text << "/#{series}" if series
        text << " #{number}:#{date}"
        flavor_parse(text)
      end
    end
  end
end
