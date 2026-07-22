# frozen_string_literal: true

module Pubid
  module Adobe
    module Identifiers
      # Adobe named publication. Slug-keyed specs that have no tech-note
      # number — Adobe Glyph List, PostScript Language, character
      # collections, etc.
      #
      # Surface forms:
      #   * slug `adobe-glyph-list`, `adobe-postscript-language`
      #   * versioned character collections: `adobe-japan1` + version `7`
      #   * human render is the slug title-cased (`Adobe Glyph List`,
      #     `Adobe-Japan1-7`); the full publication title lives in the
      #     data repo's title attribute, not here.
      class Publication < Identifier
        attribute :slug,    :string   # "adobe-glyph-list", "adobe-japan1"
        attribute :version, :string   # "7", "3", nil

        key_value do
          map "slug",    to: :slug
          map "version", to: :version
        end

        def self.type
          { key: :publication, title: "Publication", short: nil }
        end
      end
    end
  end
end
