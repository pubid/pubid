# frozen_string_literal: true

module Pubid
  module Ieee
    module Identifiers
      # IEC/IEEE Copublished Identifier - represents standards copublished by IEC and IEEE
      # Example: "IEC/IEEE 60079-30-2/D5 IEC:2013 (10/07)"
      class IecIeeeCopublished < Base
        attribute :iec_identifier, Base, polymorphic: true
        attribute :ieee_identifier, Base, polymorphic: true
        attribute :copublished_number, :string  # The shared number like "60079-30-2"
        attribute :draft_info, :string          # Draft information like "/D5"
        attribute :iec_year, :string            # IEC year like "2013"
        attribute :date_info, :string           # Date information like "(10/07)"

        def to_s
          result = "IEC/IEEE"
          result += " #{copublished_number}" if copublished_number
          result += draft_info if draft_info
          result += " IEC:#{iec_year}" if iec_year
          result += " #{date_info}" if date_info
          result
        end
      end
    end
  end
end
