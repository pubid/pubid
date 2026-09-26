# frozen_string_literal: true

module Pubid
  module Itu
    module Identifiers
      # The ITU Radio Regulations — the treaty text revised by each World
      # Radiocommunication Conference.
      # Format: ITU-R RR [(YYYY)]
      # Example: ITU-R RR (2020)
      #
      # It has no document number: "RR" is the whole designation, stored as
      # the series. `#number` returns it, so `root.number` (the relaton-index
      # key) is not empty.
      class RadioRegulations < Identifier
        include StandardSerialization

        def number
          series&.series
        end

        def render_base(**_opts)
          "#{publisher}-#{sector} #{series}#{render_date_suffix}"
        end
      end
    end
  end
end
