# frozen_string_literal: true

module Pubid
  module Easc
    # Grammar for EASC identifiers.
    #
    # Accepts the Cyrillic surface forms observed in mgscatalog.by:
    #
    #   ПМГ 03-2025
    #   ПМГ В 31-2001           (defense variant)
    #   РМГ 151-2025
    #   РМГ 29-2013
    #
    # Also accepts Latin transliterations (PMG, RMG, V) for
    # round-tripping with English-language tooling. The renderer
    # emits Cyrillic as the canonical form.
    class Parser
    end
  end
end
