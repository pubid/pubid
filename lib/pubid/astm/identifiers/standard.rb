# frozen_string_literal: true

module Pubid
  module Astm
    module Identifiers
      class Standard < Base
        attribute :sub_year, :string        # a, b, c
        attribute :reapproval, :string      # (2023)
        attribute :edition, :string # e1
      end
    end
  end
end
