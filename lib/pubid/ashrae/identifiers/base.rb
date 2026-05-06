# frozen_string_literal: true

module Pubid
  module Ashrae
    module Identifiers
      # Base class for all ASHRAE identifiers
      class Base < Pubid::Identifier
        attribute :publisher, :string, default: "ASHRAE"
        attribute :code, :string
        attribute :year, :string
        attribute :type, :string
        attribute :suffix, :string # R (revision), P (proposed), etc.
        attribute :amendment, :string
        attribute :reaffirmed, :string
        attribute :copublisher, :string

        def self.parse(string)
          Ashrae::Identifier.parse(string)
        end
      end
    end
  end
end
