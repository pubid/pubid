# frozen_string_literal: true

module Pubid
  module Sae
    class Builder
      def self.build(parsed_data)
        new.build(parsed_data)
      end

      def build(data)
        data = data.inject({}) { |acc, h| acc.merge(h) } if data.is_a?(Array)

        # SAE only has one identifier type (Standard)
        identifier = Identifiers::Base.new

        # Cast and assign each attribute
        data.each_pair do |key, value|
          realized_components = cast(key.to_sym, value)
          next if realized_components.nil?

          case realized_components
          when Hash
            realized_components.each_pair do |k, v|
              begin
                identifier.send("#{k}=", v)
              rescue NoMethodError
                nil
              end
            end
          else
            begin
              identifier.send("#{key}=", realized_components)
            rescue NoMethodError
              nil
            end
          end
        end

        identifier
      end

      private

      def cast(type, value)
        case type
        when :publisher
          # SAE publisher is constant
          "SAE"

        when :type
          Components::Type.new(abbr: value.to_s)

        when :number
          Components::Code.new(value: value.to_s)

        when :year
          # Return as hash with :date key for proper attribute mapping
          { date: Components::Date.new(year: value.to_i) }

        else
          value
        end
      end
    end
  end
end
