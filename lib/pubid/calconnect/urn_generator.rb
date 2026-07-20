# frozen_string_literal: true

module Pubid
  module Calconnect
    # Emits CalConnect URNs of the form
    #   urn:calconnect[:<series>]:<number>:<date>
    # e.g. "urn:calconnect:DIR:10006:2019", "urn:calconnect:18011:2018",
    # "urn:calconnect:WD:51017:2024-07-23".
    #
    # The series keeps its printed case (JIS keeps its code case likewise) so a
    # URN reconstructs the human form losslessly — mirror in urn_parser.rb.
    #
    # NOTE: a *partial* (date-less) reference has NO round-trippable URN form.
    # Both `series` and `date` are optional, and UrnParser reads the trailing
    # segments positionally, so a date-less URN like "urn:calconnect:11001"
    # (or "urn:calconnect:DIR:10006") is ambiguous with a series-less dated URN
    # and does not parse back. Partial refs are matched by pubid `#exclude`,
    # not by URN, so this generator simply omits the missing segment rather
    # than emitting an empty ":" — callers must not rely on URN round-trip for
    # a partial id.
    class UrnGenerator < Pubid::UrnGenerator::Base
      def generate
        # series and date_string are nil for a series-less or partial
        # (date-less) id; compact drops them so no empty ":" segment appears.
        parts = [
          "urn", "calconnect",
          identifier.series, identifier.number.to_s, identifier.date_string
        ]
        parts.compact.join(":")
      end
    end
  end
end
