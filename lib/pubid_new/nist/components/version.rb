# frozen_string_literal: true

require "lutaml/model"

module PubidNew
  module Nist
    module Components
      # Version component for NIST publications
      # Uses dotted notation: "1.0.2", "2.0", etc.
      #
      # Examples:
      #   Version.new(value: "1.0.2").to_s(:short) # => "ver1.0.2"
      #   Version.new(value: "2.0").to_s(:long)    # => "Version 2.0"
      class Version < Lutaml::Model::Serializable
        attribute :value, :string  # Dotted notation: "1.0.2"

        # Render version in specified format
        # @param format [:short, :mr, :long] The output format
        # @return [String] The formatted version representation
        def to_s(format = :short)
          return "" if value.nil?

          case format
          when :short, :mr
            "ver#{value}"
          when :long
            "Version #{value}"
          else
            "ver#{value}"
          end
        end
      end
    end
  end
end