# frozen_string: true

module Pubid
  module Bsi
    module Components
      # BSI has no date semantics of its own, so this is the shared
      # component, not a subclass: an empty `class Date <
      # Pubid::Components::Date` rejected the shared instances a nested
      # cross-flavor adopted identifier carries (pubid#379 — the adoption
      # wrappers delegate `date` to the foreign object), and made `==`
      # compare the parsed instance against the deserialized one by class.
      # Aliased so the builder's `Components::Date.new` call sites construct
      # the shared class.
      Date = ::Pubid::Components::Date
    end
  end
end
