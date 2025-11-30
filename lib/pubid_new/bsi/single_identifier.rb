# frozen_string_literal: true

require "lutaml/model"
require_relative "../components/publisher"
require_relative "../components/code"
require_relative "../components/date"
require_relative "../components/stage"
require_relative "../components/type"
require_relative "../components/typed_stage"

module PubidNew
  module Bsi
    class SingleIdentifier < Lutaml::Model::Serializable
      attribute :publisher, Components::Publisher, default: -> { Components::Publisher.new(body: "BS") }
      attribute :number, Components::Code
      attribute :part, Components::Code
      attribute :subpart, Components::Code
      attribute :date, Components::Date
      attribute :stage, Components::Stage
      attribute :type, Components::Type
      attribute :typed_stage, Components::TypedStage
      attribute :edition, :string
      attribute :month, :integer

      def to_s(lang: :en, lang_single: false)
        parts = []
        
        # Get type short name
        type_short = if type.is_a?(Components::Type)
                       type.abbr
                     elsif self.class.respond_to?(:type)
                       self.class.type[:short]
                     else
                       "BS"  # Default
                     end
        
        # Stage prefix (Draft BS) OR type as publisher
        if typed_stage && typed_stage.abbr && typed_stage.abbr.first != type_short
          # Use full typed_stage abbreviation for stages
          parts << typed_stage.abbr.first
        elsif stage && stage.respond_to?(:abbr)
          parts << stage.abbr
        elsif type.is_a?(Components::Type) && type.abbr != "BS"
          parts << type.abbr
        else
          parts << type_short
        end
        
        # Number with part/subpart
        if number
          number_str = number.respond_to?(:value) ? number.value.to_s : number.to_s
          if part
            part_val = part.respond_to?(:value) ? part.value : part
            number_str += "-#{part_val}"
          end
          if subpart
            subpart_val = subpart.respond_to?(:value) ? subpart.value : subpart
            number_str += "-#{subpart_val}"
          end
          parts << number_str
        end
        
        result = parts.join(" ")
        
        # Date
        if date
          year_val = date.respond_to?(:year) ? date.year : date.to_i
          result += ":#{year_val}"
          # Month if present
          result += "-#{format('%02d', month)}" if month
        end
        
        # Edition
        result += " v#{edition}" if edition
        
        result
      end

      def <=>(other)
        return nil unless other.is_a?(SingleIdentifier)
        
        # Compare by number first
        num_cmp = number.to_s <=> other.number.to_s
        return num_cmp unless num_cmp.zero?
        
        # Then by part
        part_cmp = (part || Components::Code.new(value: "0")).to_s <=> (other.part || Components::Code.new(value: "0")).to_s
        return part_cmp unless part_cmp.zero?
        
        # Then by date
        if date && other.date
          date.to_s <=> other.date.to_s
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