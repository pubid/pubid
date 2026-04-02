# frozen_string_literal: true

module Pubid
  module Ansi
    # Scheme configuration for ANSI identifiers
    IDENTIFIER_TYPES = [
      Identifiers::Standard,
    ].freeze

    Scheme = Pubid::Scheme.new(
      identifiers: IDENTIFIER_TYPES,
      supplement_identifiers: [],
    )
  end
end
