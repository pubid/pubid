# frozen_string_literal: true

module Pubid
  module Api
    module Identifiers
      class Mpms < Base
        attribute :chapter, :string
        attribute :section, :string
        attribute :subsection, :string

        def type_string
          "MPMS"
        end

        private

        def code_portion
          # Override - MPMS doesn't use code_portion
          nil
        end
      end
    end
  end
end
