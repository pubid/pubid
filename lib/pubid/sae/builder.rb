# frozen_string_literal: true

module Pubid
  module Sae
    class Builder < Pubid::Builder::Base
      def self.build(parsed_data)
        new.build(parsed_data)
      end

      private

      def default_identifier_class
        Identifier
      end

      def cast(type, value)
        case type
        when :publisher
          "SAE"
        when :type
          Components::Type.new(abbr: value.to_s)
        when :number
          Components::Code.new(value: value.to_s)
        when :year
          { date: Components::Date.new(year: value.to_i) }
        else
          value
        end
      end
    end
  end
end
