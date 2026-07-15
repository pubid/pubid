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
    class UrnGenerator < Pubid::UrnGenerator::Base
      def generate
        parts = ["urn", "calconnect"]
        parts << identifier.series if identifier.series
        parts << identifier.number.to_s
        parts << identifier.date_string
        parts.join(":")
      end
    end
  end
end
