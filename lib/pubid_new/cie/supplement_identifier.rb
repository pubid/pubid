# frozen_string_literal: true

require_relative "identifier"

module PubidNew
  module Cie
    # Base class for CIE supplement identifiers
    # Single Responsibility: Provide common attributes for supplement documents
    #
    # Supplement identifiers modify or extend base identifiers.
    # Unlike ISO/IEC, CIE supplements store base information as flat
    # string attributes rather than recursive Identifier objects.
    #
    # Classes inheriting from SupplementIdentifier:
    # - Corrigendum (corrigenda with /CorN notation)
    # - Supplement (supplements with -SPN notation)
    #
    # Architecture Note:
    # CIE uses a different architectural approach than ISO/IEC:
    # - ISO/IEC: Recursive base_identifier objects
    # - CIE: Flat string attributes (base_number, base_year, etc.)
    class SupplementIdentifier < Identifier
      # Common attribute for all CIE identifiers
      # Values: "current" (colon date separator) or "legacy" (dash date separator)
      attribute :style, :string
    end
  end
end
