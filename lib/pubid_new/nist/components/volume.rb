# frozen_string_literal: true

require "lutaml/model"

module PubidNew
  module Nist
    module Components
      # Volume component for NIST publications
      # Format: v{NUMBER} where NUMBER is the volume number
      #
      # Examples:
      #   Volume.new(value: "6").to_s => "v6"
      #   Volume.new(value: "12").to_s => "v12"
      #
      # Used in:
      #   - CSM (Commercial Standards Monthly): Volume 6, Issue 1
      #   - CIRC (Circular): Volume 539
      class Volume < Lutaml::Model::Serializable
        attribute :value, :string

        def to_s
          "v#{value}"
        end

        # Alias for numeric comparison
        def to_i
          value.to_i
        end
      end
    end
  end
end
