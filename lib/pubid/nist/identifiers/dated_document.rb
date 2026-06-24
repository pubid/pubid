# frozen_string_literal: true

module Pubid
  module Nist
    module Identifiers
      # NIST date-style identifier with no series.
      # Examples:
      # - "NIST 2022-04-15 001" (short) / "NIST.2022-04-15.001" (mr/doi)
      #   DOI 10.6028/NIST.2022-04-15.001
      class DatedDocument < Base
        # Empty so the bare "NIST" abbr never shadows a series lookup; the
        # Router guard (parsed_hash[:dated_date] && :dated_seq) is the dispatch path.
        TYPED_STAGES = [].freeze

        attribute :date_year, :string
        attribute :date_month, :string
        attribute :date_day, :string
        attribute :dated_seq, :string

        class << self
          def typed_stages
            TYPED_STAGES
          end

          def type
            { key: :dated, title: "NIST Dated Document" }
          end
        end

        def to_short_style
          "#{publisher || 'NIST'} #{date_year}-#{date_month}-#{date_day} #{dated_seq}"
        end

        def to_mr_style
          "#{publisher || 'NIST'}.#{date_year}-#{date_month}-#{date_day}.#{dated_seq}"
        end

        # No series/number to expand; non-default formats fall back to short.
        def to_full_style
          to_short_style
        end

        def to_abbreviated_style
          to_short_style
        end
      end
    end
  end
end
