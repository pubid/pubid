# frozen_string_literal: true

module Pubid
  module Adobe
    # Grammar for Adobe identifiers.
    #
    # Canonical citation forms (what the renderer produces):
    #
    #   Adobe TN 5014                  (tech note; replaces the older
    #                                    "Adobe Technical Note #5014")
    #   Adobe Publication adobe-glyph-list
    #   Adobe Publication adobe-japan1-7
    #
    # The parser also accepts these legacy forms for back-compat:
    #
    #   Adobe Technical Note #5014
    #   Adobe Technical Note 5014
    #   Adobe TN5014                   (no space)
    #   ATN5014                        (short alias)
    #   5014                           (bare number; data-repo context)
    #   adobe-glyph-list               (bare slug)
    class Parser
    end
  end
end
