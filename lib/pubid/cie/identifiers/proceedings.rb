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
      # The paper itself is the document, so its identity (code + running
      # number, e.g. "OP01") is stored flat as +number+ for BOTH forms. This
      # gives every proceedings row a non-empty relaton-index binary-search key
      # (see index_number_spec). The x-form's parent conference lives in
      # +conference+; the standalone form's +page+ range is its locality.
      # No-default values so absent keys drop from to_hash (round-trip).
      class Proceedings < SingleIdentifier
        # The paper identity "OP01" / "P03". :string overrides the base
        # ::Pubid::Identifier Components::Code type.
        attribute :number, :string
        # The parent conference "043" (x-form only; nil for standalone).
        attribute :conference, :string
        # Page range "1-5" (standalone form only).
        attribute :page, :string

        def to_s
          if conference
            "CIE x#{conference}-#{number}"
          else
            "CIE #{number} #{page}"
          end
        end
      end
    end
  end
end
