# frozen_string_literal: true

require "lutaml/model"

module Pubid
  module Ieee
    module Identifiers
      module Nesc
        # Base class for National Electrical Safety Code (NESC) identifiers
        #
        # NESC is published by IEEE Standards Association and covers electrical
        # safety standards for utilities and communication systems.
        #
        # @example Standard format
        #   nesc = Pubid::Ieee.parse("C2-1997 National Electric Safety Code")
        #   nesc.code.value  # => "C2"
        #   nesc.year.year   # => 1997
        #
        # @example Handbook format
        #   nesc = Pubid::Ieee.parse("2017 NESC Handbook, Premier Edition")
        #   nesc.year.year   # => 2017
        #   nesc.variant     # => "Handbook"
        #   nesc.edition     # => "Premier Edition"
        class Base < Lutaml::Model::Serializable
          attribute :code, Pubid::Ieee::Components::Code # "C2" code designation
          attribute :year, Pubid::Components::Date # Publication year
          attribute :variant, :string              # Handbook, Redline, etc.
          attribute :edition, :string              # Edition notation
          attribute :draft, :boolean               # Draft flag
          attribute :month, :string                # For draft identifiers

          # Publisher portion for NESC identifiers
          #
          # @return [String] Always returns "NESC"
          def publisher_portion
            "NESC"
          end

          # Base rendering - override in subclasses
          #
          # @return [String] String representation
          def to_s
            parts = []
            if code && year
              parts << "#{code}-#{year.year}"
            elsif year
              parts << year.year.to_s
            end
            parts << "National Electrical Safety Code"
            parts.join(" ")
          end
        end
      end
    end
  end
end
