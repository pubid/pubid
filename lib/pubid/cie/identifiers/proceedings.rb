# frozen_string_literal: true

require "lutaml/model"

module Pubid
  module Cie
    module Identifiers
      # Proceedings paper identifier for CIE conference papers.
      #
      # Two surface forms share this type:
      #   x-prefixed (attached to a conference): "CIE x043-OP01"
      #   standalone (with a page range):        "CIE OP02 1-5"
      #
      # The paper's identity (code + number) is a Components::Paper, matching
      # how the flavor groups other sub-structure into components.
      # +number+ (the parent conference, x-form) and +page_range+ (standalone)
      # are the form-specific parts. No-default values so absent keys drop from
      # to_hash (relaton-index round-trip contract).
      class Proceedings < SingleIdentifier
        # The conference number "043" (nil for standalone form). :string
        # overrides the base ::Pubid::Identifier Components::Code type.
        attribute :number, :string
        attribute :paper, Components::Paper   # code "OP" + number "01"
        attribute :page_range, :string        # "1-5" (standalone form only)

        def to_s
          if number
            "CIE x#{number}-#{paper}"
          else
            "CIE #{paper} #{page_range}"
          end
        end
      end
    end
  end
end
