# frozen_string_literal: true

module Pubid
  module Csa
    module Identifiers
      # SeriesIdentifier represents CSA identifiers where SERIES
      # is the primary document type, not just a keyword modifier
      #
      # Examples:
      #   CSA MH SERIES 3.14:20
      #   CSA RV SERIES 1:19
      #   CSA SERIES Z1000:22
      #
      # Difference from Standard with series_keyword:
      #   - Series: SERIES is the document type (primary)
      #   - Standard: SERIES is a modifier keyword (secondary)
      class Series < Base
        # Series prefix (MH, RV, etc.) - optional
        attribute :series_prefix, :string

        def to_s(**opts)
          render(format: :human, **opts)
        end
      end
    end
  end
end
