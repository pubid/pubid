# frozen_string_literal: true

module Pubid
  module Ieee
    module Identifiers
      # Parenthetical Identifier - wraps identifier with parenthetical annotation
      # Example: "IEEE Standard No 18-1968 (ANSI C55.1-1968)"
      class ParentheticalIdentifier < Base
        attribute :base_identifier, Base, polymorphic: true
        attribute :parenthetical_identifier, Base, polymorphic: true

        def to_s
          result = base_identifier.to_s
          result += " (#{parenthetical_identifier.to_s})" if parenthetical_identifier
          result
        end
      end
    end
  end
end
