# frozen_string_literal: true

require "lutaml/model"
require_relative "../components/language"

module PubidNew
  module Cie
    module Identifiers
      # Supplement identifier for CIE
      # Handles -SPN and -SPN.P notation with recursive base parsing
      # Examples: CIE 121-SP1:2009, CIE 198-SP1.4:2011, CIE DIS 025-SP1/E:2019
      class Supplement < Lutaml::Model::Serializable
        attribute :base_number, :string
        attribute :supplement_number, :string    # "1", "2"
        attribute :supplement_part, :string      # "1" in "SP1.1", "4" in "SP1.4"
        attribute :year, :string
        attribute :style, :string
        attribute :stage, :string                # "DIS", "DS"
        attribute :language, Components::Language

        def to_s
          parts = ["CIE"]

          # Stage if present (DIS/DS)
          parts << stage if stage

          # Build base number and supplement
          result = parts.join(" ")
          result += " #{base_number}-SP#{supplement_number}"

          # Add part if present (e.g., ".4" in "SP1.4")
          result += ".#{supplement_part}" if supplement_part

          # Add language with slash if present (before year)
          if language && language.format == "slash_colon"
            result += "/#{language.code}"
          end

          # Add year with colon (supplements always use current style)
          result += ":#{year}" if year

          result
        end
      end
    end
  end
end
