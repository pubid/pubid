# frozen_string_literal: true

require_relative "model"

module Pubid
  module Itu
    class Scheme < Pubid::Scheme
      # Attribute mappings define how parsed data maps to model attributes
      ATTRIBUTE_MAPPINGS = {
        sector: :sector,
        series: :series,
        number: :number,
        subseries: :subseries,
        part: :part,
        supplement: :supplement,
        amendment: :amendment,
        annex: :annex,
        corrigendum: :corrigendum,
        addendum: :addendum,
        appendix: :appendix,
        date: :date,
        month: :month,
        year: :year,
        second_number: :second_number,
        range_series: :range_series,
        range_number: :range_number,
        sg_number: :sg_number,
      }.freeze

      # Model class to use for rendering
      def self.model_class
        Model
      end

      # Convert parsed data to model attributes
      def self.transform(parsed)
        attributes = {}

        # Extract sector
        attributes[:sector] = parsed[:sector].to_s if parsed[:sector]

        # Determine content based on sector
        content = parsed[:t_content] || parsed[:r_content] || {}

        # Extract series and study group
        if content[:series].is_a?(Hash) && content[:series][:sg_number]
          # Study groups (questions)
          attributes[:series] = "SG#{content[:series][:sg_number]}"
        elsif content[:series]
          attributes[:series] = content[:series].to_s
        end

        # Extract numbering components
        if content[:numbering]
          numbering = content[:numbering]

          # Handle numbering as array (e.g., number + subseries)
          if numbering.is_a?(Array)
            numbering.each do |part|
              if part.is_a?(Hash)
                if part[:number]
                  attributes[:number] = part[:number].to_s
                elsif part[:subseries]
                  # Collect subseries parts
                  if attributes[:subseries]
                    attributes[:subseries] =
                      "#{attributes[:subseries]}.#{part[:subseries]}"
                  else
                    attributes[:subseries] = part[:subseries].to_s
                  end
                elsif part[:part]
                  attributes[:part] = part[:part].to_s
                end
              end
            end
          elsif numbering.is_a?(Hash)
            # Handle numbering as hash
            attributes[:number] = numbering[:number].to_s if numbering[:number]
            if numbering[:subseries]
              attributes[:subseries] =
                numbering[:subseries].to_s
            end
            attributes[:part] = numbering[:part].to_s if numbering[:part]
          end
        end

        # Extract supplement/amendment/etc.
        if content[:supplement]
          attributes[:supplement] =
            content[:supplement].to_s
        end
        attributes[:amendment] = content[:amendment].to_s if content[:amendment]
        attributes[:annex] = content[:annex].to_s if content[:annex]
        if content[:corrigendum]
          attributes[:corrigendum] =
            content[:corrigendum].to_s
        end
        attributes[:addendum] = content[:addendum].to_s if content[:addendum]

        # Handle appendix (convert Roman numerals to Arabic)
        if content[:appendix]
          appendix = content[:appendix].to_s
          attributes[:appendix] = roman_to_arabic(appendix) || appendix
        end

        # Extract date
        if content[:date]
          date = content[:date]
          if date[:month] && date[:year]
            attributes[:month] = date[:month].to_s
            attributes[:year] = date[:year].to_s
          elsif date[:year]
            attributes[:year] = date[:year].to_s
          end
        end

        # Extract second number (for combined standards like G.780/Y.1351)
        if content[:second_number]
          second = content[:second_number]
          second_attrs = {}
          second_attrs[:series] = second[:series].to_s if second[:series]
          if second[:numbering]
            numbering = second[:numbering]
            if numbering[:number]
              second_attrs[:number] =
                numbering[:number].to_s
            end
            if numbering[:subseries]
              second_attrs[:subseries] = numbering[:subseries].to_s
            end
            second_attrs[:part] = numbering[:part].to_s if numbering[:part]
          end
          attributes[:second_number] = second_attrs unless second_attrs.empty?
        end

        # Extract range (for Q.400-Q.490 style)
        if content[:range_series] && content[:range_number]
          attributes[:range] = {
            series: content[:range_series].to_s,
            number: content[:range_number].to_s,
          }
        end

        attributes
      end

      # Convert Roman numerals to Arabic numbers
      def self.roman_to_arabic(roman)
        return roman unless roman.match?(/^[IVXLCDM]+$/i)

        roman_map = {
          "I" => 1, "V" => 5, "X" => 10, "L" => 50,
          "C" => 100, "D" => 500, "M" => 1000
        }

        roman = roman.upcase
        result = 0
        prev_value = 0

        roman.reverse.each_char do |char|
          value = roman_map[char]
          if value < prev_value
            result -= value
          else
            result += value
          end
          prev_value = value
        end

        result.to_s
      end
    end
  end
end
