# frozen_string_literal: true

module Pubid
  module Bsi
    module Identifiers
      # Amendment Identifier
      # Contains a base identifier plus amendment parameters
      class Amendment < SingleIdentifier
        attribute :base, ::Pubid::Identifier, polymorphic: true
        attribute :amendment_number, :string
        attribute :amendment_year, :integer
        attribute :separator, :string, default: -> { "+" }
        # true for the trailing " AMD5" / " AMD AA" suffix form, false for the
        # compact "+A5" / "/A5" join form. Distinguishes the two when no year is
        # present (previously the presence of a year was a reliable proxy).
        attribute :amd_suffix_form, :boolean, default: -> { false }

        def publisher
          base&.publisher
        end

        # Base document = the standard this amendment applies to, fully peeled.
        def base_document
          base&.base_document || self
        end

        # Dropping the supplement layer yields the base standard.
        def drop_supplements
          base || self
        end

        # Uniform supplement interface (shared with Corrigendum) so callers need
        # not special-case the class.
        def supplement_type
          :amendment
        end

        def supplement_number
          amendment_number
        end

        def supplement_year
          amendment_year
        end
      end
    end
  end
end
