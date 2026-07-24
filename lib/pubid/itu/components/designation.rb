# frozen_string_literal: true

require "lutaml/model"

module Pubid
  module Itu
    module Components
      # One series+number designation of a combined (joint) recommendation.
      # A combined recommendation such as "ITU-T G.780/Y.1351" keeps its primary
      # designation on the base identifier (series "G", code "780") and carries
      # each *additional* designation ("Y.1351", and any further "/Z.1362" …) as
      # a Designation in Identifiers::CombinedIdentifier#combined.
      #
      # Format: SERIES.CODE  (e.g. "Y.1351", "Y.1362-2")
      class Designation < Lutaml::Model::Serializable
        attribute :series, Pubid::Itu::Components::Series
        attribute :code, Pubid::Itu::Components::Code

        def to_s
          "#{series}.#{code}"
        end

        def render(context: nil)
          to_s
        end

        def ==(other)
          return false unless other.is_a?(Designation)

          series == other.series && code == other.code
        end
      end
    end
  end
end
