# frozen_string_literal: true

module Pubid
  module CenCenelec
    module Identifiers
      # Corrigendum Identifier
      # Contains a base identifier plus corrigendum parameters
      #
      # Like Amendment, it descends from the shared
      # Pubid::CenCenelec::Identifier and not from the legacy Identifiers::Base,
      # and it keeps its date in `year` and `month` strings:
      # {"base" => {…}, "year" => "2016", "month" => "11"}. An unnumbered
      # "/AC" has no `number`.
      class Corrigendum < Pubid::CenCenelec::Identifier
        attribute :base, Pubid::CenCenelec::Identifier, polymorphic: true
        attribute :year, :string
        attribute :month, :string

        def self.supplement_date_attributes
          %i[year month]
        end

        def base_document
          base&.base_document || self
        end

        # Dropping the supplement layer yields the base standard.
        def drop_supplements
          base || self
        end

        # Uniform supplement interface (shared with Amendment and with BSI)
        # so callers need not special-case the class.
        def supplement_type
          :corrigendum
        end

        def supplement_number
          number
        end

        def supplement_year
          year
        end

        # The date part of the supplement: "2016-11", "2003", or nil.
        def supplement_date
          return nil unless year

          [year, month].compact.reject(&:empty?).join("-")
        end

        def mr_supplement_suffix
          mr_join_segments("cor", number, supplement_date)
        end
      end
    end
  end
end
