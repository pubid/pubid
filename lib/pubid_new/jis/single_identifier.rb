require "lutaml/model"
require_relative "identifier"

module PubidNew
  module Jis
    class SingleIdentifier < Identifier
      attribute :publisher, Components::Publisher, default: -> { Components::Publisher.new(body: "JIS") }
      attribute :series, Components::Code
      attribute :number, Components::Code
      attribute :part, Components::Code
      attribute :date, Components::Date
      attribute :language, Components::Code
      attribute :type, Components::Type
      attribute :typed_stage, Components::TypedStage

      def to_s(lang: :en, lang_single: false)
        parts = []
        
        # Publisher (JIS)
        parts << publisher.body if publisher
        
        # Type for TR/TS
        type_short = self.class.type[:short]
        parts << type_short if type_short != "JIS"
        
        # Series and number
        if series && number
          parts << "#{series.value} #{number.value}"
        elsif number
          parts << number.value
        end
        
        result = parts.join(" ")
        
        # Part (with hyphen)
        result += "-#{part.value}" if part
        
        # Date
        result += ":#{date.year}" if date
        
        # Language in parentheses
        result += "(#{language.value})" if language
        
        result
      end

      def <=>(other)
        return nil unless other.is_a?(SingleIdentifier)
        
        # Compare by series first
        series_cmp = (series&.value || "") <=> (other.series&.value || "")
        return series_cmp unless series_cmp.zero?
        
        # Then by number
        num_cmp = number.value.to_i <=> other.number.value.to_i
        return num_cmp unless num_cmp.zero?
        
        # Then by part
        part_cmp = (part&.value&.to_i || 0) <=> (other.part&.value&.to_i || 0)
        return part_cmp unless part_cmp.zero?
        
        # Then by date
        if date && other.date
          date.year.to_i <=> other.date.year.to_i
        elsif date
          1
        elsif other.date
          -1
        else
          0
        end
      end
    end
  end
end