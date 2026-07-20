# frozen_string_literal: true

require "lutaml/model"

module Pubid
  module Cie
    module Identifiers
      # Corrigendum identifier for CIE (/CorN notation).
      # Wraps a nested base_identifier — a Standard, or a Supplement when the
      # corrigendum applies to a supplement (CIE 198-SP1.4:2011/Cor1:2013).
      # The "/CorN:year" is a clean trailing suffix on the base's rendering.
      # Examples: CIE 232:2019/Cor1:2020, CIE 198-SP1.4:2011/Cor1:2013
      class Corrigendum < SupplementIdentifier
        attribute :cor_number, :string
        attribute :cor_year, :string

        # Uniform supplement interface (shared with Supplement).
        def supplement_type
          :corrigendum
        end

        def supplement_number
          cor_number
        end

        def supplement_year
          cor_year
        end

        def to_s
          "#{base_identifier}/Cor#{cor_number}:#{cor_year}"
        end
      end
    end
  end
end
