# frozen_string_literal: true

module Pubid
  module Isbn
    # Grammar for ISBN identifiers per ISO 2108.
    #
    # Accepts:
    #   [ISBN[ |:]] {10 or 13 digits with optional hyphens}
    #
    # ISBN-10 final digit may be "X" (check digit value 10). Hyphens are
    # optional and may appear in any group position; they are preserved
    # for round-trip rendering.
    class Parser
    end
  end
end
