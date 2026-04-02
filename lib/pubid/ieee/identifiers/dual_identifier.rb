# frozen_string_literal: true

module Pubid
  module Ieee
    module Identifiers
      # Dual Identifier - wraps two identifiers connected with "and"
      # Example: "ANSI C37.61-1973 and IEEE Std 321-1973"
      class DualIdentifier < Base
        attribute :first_identifier, Base, polymorphic: true
        attribute :second_identifier, Base, polymorphic: true

        def to_s
          "#{first_identifier} and #{second_identifier}"
        end
      end
    end
  end
end
