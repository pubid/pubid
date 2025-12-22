# frozen_string_literal: true

require "lutaml/model"

module PubidNew
  module Nist
    module Components
      # Translation component for NIST publications
      # Uses 3-letter ISO 639-2 language codes
      #
      # Examples:
      #   Translation.new(code: "spa").to_s(:short) # => " spa"
      #   Translation.new(code: "por").to_s(:mr)    # => ".por"
      #   Translation.new(code: "ind").to_s(:short) # => " ind"
      class Translation < Lutaml::Model::Serializable
        attribute :code, :string  # 3-letter ISO 639-2 code: spa, por, ind, etc.

        # Render translation in specified format
        # @param format [:short, :mr, :long] The output format
        # @return [String] The formatted translation representation
        def to_s(format = :short)
          return "" if code.nil?

          case format
          when :short, :long
            " #{code}"
          when :mr
            ".#{code}"
          else
            " #{code}"
          end
        end
      end
    end
  end
end