# frozen_string_literal: true

module Pubid
  module Csa
    module Identifiers
      # An amendment riding on a CSA identifier: "/A1:15" after the base
      # designation. The grammar binds amendment_number and
      # amendment_year; the builder wraps the base identifier in this
      # class when they are present.
      class Amendment < Identifier
        attribute :base, ::Pubid::Identifier
        attribute :amendment_number, :string
        attribute :amendment_year, :string

        def initialize(base:, amendment_number:, amendment_year: nil, **opts)
          super(base: base, amendment_number: amendment_number,
                amendment_year: amendment_year, **opts)
        end

        def to_s(**opts)
          suffix = "/A#{amendment_number}"
          suffix += ":#{amendment_year}" if amendment_year
          "#{base.to_s(**opts)}#{suffix}"
        end
      end
    end
  end
end
