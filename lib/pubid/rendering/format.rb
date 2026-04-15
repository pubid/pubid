# frozen_string_literal: true

module Pubid
  module Rendering
    module Format
      # Dispatch to appropriate format renderer
      # @param format [Symbol] target format
      # @return [String] formatted identifier string
      def to_s(format = nil)
        effective_format = determine_format(format)
        send(:"to_#{effective_format}_style")
      end

      private

      def determine_format(format)
        return :short unless format
        return :mr if format.to_sym == :mr
        return :full if %i[full long].include?(format.to_sym)

        :short
      end
    end
  end
end
