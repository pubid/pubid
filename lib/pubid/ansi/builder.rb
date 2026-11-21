# frozen_string_literal: true

module Pubid
  module Ansi
    class Builder < Pubid::Builder::Base
      def build(data)
        data = flatten_array(data) if data.is_a?(Array)
        identifier = default_identifier_class.new
        assign_attributes(identifier, data)
        read_dash_year(identifier)
        identifier
      end

      # A trailing "-" + 4 digits (19xx/20xx) is the publication year, not a
      # part: "ANSI X9.62-2005" (relaton#45). Only when no ":YYYY" follows,
      # so the part of "ANSI X9.8-1:2007" stays a part.
      DASH_YEAR = /\A(?:19|20)\d{2}\z/

      private

      def read_dash_year(identifier)
        return if identifier.date || !DASH_YEAR.match?(identifier.part.to_s)

        identifier.date = Components::Date.new(year: identifier.part)
        identifier.date_separator = "-"
        identifier.part = nil
      end

      def default_identifier_class
        Identifiers::Standard
      end

      def cast(type, value)
        case type
        when :publisher
          Components::Publisher.new(body: value)
        when :std_keyword
          !value.nil? && !value.empty?
        when :copublishers
          if value.nil? || value.empty?
            nil
          else
            value.map do |copublisher|
              Components::Publisher.new(body: copublisher[:copublisher])
            end
          end
        when :number_with_part
          original_value = value.to_s
          main_and_parts = original_value.split("-")
          main_number = main_and_parts[0]
          part_number = main_and_parts[1]
          {
            number: main_number,
            part: part_number,
          }.compact
        when :date
          Components::Date.new(year: value.to_s)
        when :languages
          value.to_s.split(",").map do |lang|
            Components::Language.new(code: lang.strip)
          end
        when :all_parts
          # The shared Grammar marks the tree; the prepended AllPartsWrap
          # routes the wrap, so the marker itself carries no component.
          nil
        else
          raise ArgumentError, "Unknown parameter type: #{type}"
        end
      end
    end
  end
end

Pubid::Ansi::Builder.prepend(Pubid::Builder::AllPartsWrap)
