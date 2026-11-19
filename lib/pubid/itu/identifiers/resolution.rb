# frozen_string_literal: true

module Pubid
  module Itu
    module Identifiers
      # ITU-R Resolution, adopted by the Radiocommunication Assembly.
      # Format: Resolution ITU-{SECTOR} {NUMBER}[-REVISION] [(YEAR)]
      # Example: Resolution ITU-R 1-9 (2023)
      #
      # A Resolution has a number and a revision (`code.parts`, as for a
      # Recommendation edition), never a series. Resolutions number
      # independently of Recommendations, so the leading word is part of the
      # identity: it reaches `to_s`, `to_urn` and `to_mr_string`, and the
      # class-strict `Identifier#==` keeps "Resolution ITU-R 1-9" unequal to
      # "ITU-R 1-9" in both directions.
      #
      # The grammar also reads "ITU-R Res. 1-9", "ITU-R Resolution 1-9" and
      # "Res. ITU-R 1-9"; all render ITU's leading form. (`Pubid.parse` does
      # not route "Res. ITU-R …": no registered prefix, no exact round trip.
      # `Pubid::Itu.parse` reads it.) The legacy
      # relaton-data-itu spelling "ITU-R R.1-9" carries no marker and stays a
      # Recommendation of series R.
      class Resolution < Identifier
        include StandardSerialization

        def render_base(**_opts)
          "Resolution #{super}"
        end

        # "itu.r.resolution.1-9": without the marker, the slug (an output
        # filename) equals the one of Recommendation "ITU-R 1-9".
        def mr_type
          [super, "resolution"].compact.join(".")
        end
      end
    end
  end
end
