require "lutaml/model"

module PubidNew
  module Cen
    class SingleIdentifier < Lutaml::Model::Serializable
      attribute :publisher, Components::Publisher, default: -> { Components::Publisher.new(body: "EN") }
      attribute :copublishers, Components::Publisher, collection: true
      attribute :number, Components::Code
      attribute :part, Components::Code
      attribute :subpart, Components::Code
      attribute :date, Components::Date
      attribute :stage, Components::Stage
      attribute :type, Components::Type
      attribute :typed_stage, Components::TypedStage

      def to_s(lang: :en, lang_single: false)
        parts = []
        
        # Get type details
        type_short = type.is_a?(Components::Type) ? self.class.type[:short] : type[:short]
        
        # Stage prefix (prEN, FprEN) OR publisher
        if typed_stage && typed_stage.abbr.first != type_short
          parts << typed_stage.abbr.first
        elsif publisher
          parts << publisher.body
        end
        
        # Copublishers - add to last part (publisher) with slash
        if copublishers && copublishers.any?
          copub_str = copublishers.map(&:body).join("/")
          unless copub_str.empty?
            if parts.any?
              parts[-1] = "#{parts[-1]}/#{copub_str}"
            else
              parts << copub_str
            end
          end
        end
        
        # Type for non-EN documents (TS, TR, CWA, etc.)
        # But not if CWA/HD (they act as publisher)
        if type_short != "EN" && !%w[CWA HD].include?(type_short)
          parts << type_short
        end
        
        # Number with part/subpart
        if number
          number_str = number.value.to_s
          number_str += "-#{part.value}" if part
          number_str += "-#{subpart.value}" if subpart
          parts << number_str
        end
        
        result = parts.join(" ")
        
        # Date
        result += ":#{date.year}" if date
        
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