# frozen_string_literal: true

module Pubid
  module Iana
    # Grammar for IANA registry identifiers.
    #
    # Accepts the authoritative printed form "IANA <slug>[/<sub-slug>]" as well
    # as a bare index-key slug (no "IANA " prefix). The optional prefix is
    # consumed and discarded — the renderer always re-emits it.
    #
    # Slugs use only [a-zA-Z0-9._-] and contain at most one "/", so a plain
    # character-class repeat parses them; there is no ReDoS surface.
    class Parser
    end
  end
end
