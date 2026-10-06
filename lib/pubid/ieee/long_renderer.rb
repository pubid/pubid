# frozen_string_literal: true

module Pubid
  module Ieee
    # The long face (C2 ruling): one uniform format dimension for every
    # IEEE identifier. Expands the type words an identifier actually
    # carries — Std → Standard on a published standard — and spells
    # draft months out ("August 2007"). A draft carries no Std/Standard
    # word, so both faces render `Draft`; there are no draft-specific
    # render rules.
    class LongRenderer < Renderer
      def render(context: nil, **opts)
        @long = true
        super
      end
    end
  end
end
