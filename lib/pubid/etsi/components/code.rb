# frozen_string_literal: true

require "lutaml/model"

module Pubid
  module Etsi
    module Components
      # Represents an ETSI code with complex number formats
      # Handles three variants:
      #   Simple: 012, 123, 456
      #   GSM: GSM 02.01, 02.01
      #   Complex: ABC 123, ABC-DEF 123
      #
      # Stays independent of Pubid::Components::Code because ETSI uses
      # +minor+ (a flavor-specific sub-number) plus +parts+.
      class Code < Lutaml::Model::Serializable
        attribute :number, :string # Main number
        attribute :minor, :string # Optional minor part
        attribute :parts, :string, collection: true # Parts array

        def initialize(number:, minor: nil, parts: nil)
          @number = number
          @minor = minor
          @parts = parts || []
        end

        # Render code with space for minor and dash-separated parts
        def to_s
          result = number.to_s
          result += " #{minor}" if minor
          result += parts.map { |p| "-#{p}" }.join if parts&.any?
          result
        end

        def render(context: nil)
          to_s
        end

        def ==(other)
          return false unless other.is_a?(Code)

          number == other.number &&
            minor == other.minor &&
            parts == other.parts
        end
      end
    end
  end
end
