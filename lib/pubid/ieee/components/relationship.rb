# frozen_string_literal: true

# IEEE's Relationship component is now the shared Pubid::Components::Relationship.
# This subclass exists so existing references (Pubid::Ieee::Components::Relationship,
# the VALID_TYPES constants, etc.) continue to resolve without rewriting every
# call site.
module Pubid
  module Ieee
    module Components
      class Relationship < ::Pubid::Components::Relationship; end
    end
  end
end
