# frozen_string_literal: true

require "pubid"
module Pubid
  # The all-parts identifier of a flavor that has no class of its own.
  # A flavor that prints "(all parts)" or has a series URN gives its own
  # class instead: see {Pubid::AllParts} and `Identifier.all_parts_class`.
  class AllPartsIdentifier < Identifier
    include AllParts

    # This class belongs to no flavor, so its name carries no flavor segment
    # and {TypeResolver} resolves it directly.
    def self.polymorphic_name
      return super unless self == ::Pubid::AllPartsIdentifier

      "pubid:all-parts"
    end
  end
end
