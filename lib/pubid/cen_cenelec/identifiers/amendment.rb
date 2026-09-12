# frozen_string_literal: true

module Pubid
  module CenCenelec
    module Identifiers
      # Amendment Identifier
      # Contains a base identifier plus amendment parameters
      #
      # It descends from the shared Pubid::CenCenelec::Identifier, not from
      # the legacy Identifiers::Base. That class declares publisher, year and
      # parts attributes that an amendment does not have, and its `==` compared
      # only those, so any two amendments were equal.
      #
      # The amendment number is the inherited `number`, and its year is a
      # `year` string, so the hash uses the same keys as a document:
      # {"base" => {…}, "number" => "1", "year" => "2005"}. The member of a
      # consolidated identifier has no `base`; the consolidated identifier
      # holds the base document once.
      class Amendment < Pubid::CenCenelec::Identifier
        # Typed to the shared parent: the base of an amendment is a
        # SingleIdentifier ("EN 13250:2000"), an adopted norm
        # ("CEN ISO/TS 21003-7:2008") or another supplement.
        attribute :base, Pubid::CenCenelec::Identifier, polymorphic: true
        attribute :year, :string

        def self.supplement_date_attributes
          %i[year]
        end

        def base_document
          base&.base_document || self
        end

        # Dropping the supplement layer yields the base standard.
        def drop_supplements
          base || self
        end

        # Uniform supplement interface (shared with Corrigendum and with BSI)
        # so callers need not special-case the class.
        def supplement_type
          :amendment
        end

        def supplement_number
          number
        end

        def supplement_year
          year
        end

        def mr_supplement_suffix
          mr_join_segments("amd", number, year)
        end
      end
    end
  end
end
