# frozen_string_literal: true

module Pubid
  module Adobe
    module Identifiers
      # Adobe Technical Note. Numbered 4-digit (5xxx series observed).
      #
      # Surface forms:
      #   * `Adobe Technical Note #5014` — formal citation form
      #   * `ATN5014`                    — short alias used in Metanorma
      #                                    anchor ids ([[atn5014,…]])
      #   * filename `5014.CIDFont_Spec.pdf` (data repo splits filename
      #     into number + slug before calling the parser)
      #
      # The optional `slug` carries the filename's title segment
      # (`CIDFont_Spec`) so round-trip through the data repo is lossless.
      class TechNote < Identifier
        attribute :number, :string   # "5014", "5902"
        attribute :slug,   :string   # "CIDFont_Spec", "AFM_Spec", nil

        key_value do
          map "number", to: :number
          map "slug",   to: :slug
        end

        def self.type
          { key: :"tech-note", title: "Technical Note", short: "ATN" }
        end
      end
    end
  end
end
