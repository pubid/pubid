# frozen_string_literal: true

module Pubid
  module Ieee
    module Identifiers
      # Parenthetical Identifier - wraps identifier with parenthetical annotation
      # Example: "IEEE Standard No 18-1968 (ANSI C55.1-1968)"
      class ParentheticalIdentifier < Identifier
        attribute :base, Identifier, polymorphic: true
        attribute :parenthetical_identifier, Identifier, polymorphic: true
      end
    end
  end
end
