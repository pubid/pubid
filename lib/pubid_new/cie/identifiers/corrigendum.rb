# frozen_string_literal: true

require "lutaml/model"
require_relative "../supplement_identifier"

module PubidNew
  module Cie
    module Identifiers
      # Corrigendum identifier for CIE
      # Handles /CorN notation with recursive base parsing
      # Examples: CIE 232:2019/Cor1:2020, CIE 198-SP1.4:2011/Cor1:2013
      class Corrigendum < SupplementIdentifier
        attribute :base_number, :string
        attribute :base_year, :string
        attribute :base_supplement, :string       # If base is a supplement
        attribute :base_supplement_part, :string  # Part of supplement
        attribute :cor_number, :string
        attribute :cor_year, :string

        def to_s
          # Build base identifier string
          result = "CIE #{base_number}"

          # Add supplement notation if base is a supplement
          if base_supplement
            result += "-SP#{base_supplement}"
            result += ".#{base_supplement_part}" if base_supplement_part
          end

          # Add base year with colon
          result += ":#{base_year}" if base_year

          # Add corrigendum with slash and colon
          result += "/Cor#{cor_number}:#{cor_year}"

          result
        end
      end
    end
  end
end
