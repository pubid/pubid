# frozen_string_literal: true

module Pubid
  module Bsi
    module Identifiers
      # Corrigendum Identifier
      # Contains a base identifier plus corrigendum parameters
      class Corrigendum < SingleIdentifier
        attribute :base, ::Pubid::Identifier, polymorphic: true
        attribute :corrigendum_number, :string
        attribute :corrigendum_year, :integer
        attribute :separator, :string, default: -> { "+" }

        def publisher
          base&.publisher
        end

        # Base document = the standard this corrigendum applies to, fully peeled.
        def base_document
          base&.base_document || self
        end

        # Dropping the supplement layer yields the base standard.
        def drop_supplements
          base || self
        end

        # Uniform supplement interface (shared with Amendment) so callers need
        # not special-case the class.
        def supplement_type
          :corrigendum
        end

        def supplement_number
          corrigendum_number
        end

        def supplement_year
          corrigendum_year
        end
      end
    end
  end
end
