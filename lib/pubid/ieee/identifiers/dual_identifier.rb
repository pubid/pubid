# frozen_string_literal: true

module Pubid
  module Ieee
    module Identifiers
      # Dual Identifier - wraps two identifiers connected with "and"
      # Example: "ANSI C37.61-1973 and IEEE Std 321-1973"
      class DualIdentifier < Base
        attribute :first_identifier, Base, polymorphic: true
        attribute :second_identifier, Base, polymorphic: true
      end
    end
  end
end
