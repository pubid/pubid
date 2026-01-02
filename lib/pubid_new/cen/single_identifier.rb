require "lutaml/model"
require_relative "../components/publisher"
require_relative "../components/code"
require_relative "../components/date"
require_relative "../components/stage"
require_relative "../components/type"
require_relative "../components/typed_stage"

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

        # Check if we have a draft stage (prEN, FprEN) - these include both stage and type
        is_draft_stage = typed_stage && typed_stage.abbr && %w[prEN FprEN].include?(typed_stage.abbr.first)

        # Get type short name - for draft stages, extract base type
        type_short = if is_draft_stage
                       typed_stage.type_code.to_s.upcase  # :en => "EN"
                     elsif type.is_a?(Components::Type)
                       type.abbr
                     elsif self.class.respond_to?(:type)
                       self.class.type[:short]
                     else
                       "EN"  # Default
                     end

        # Track if we should use slash before type
        use_slash_before_type = false

        # For CWA/HD, they act as publisher (not EN)
        if %w[CWA HD].include?(type_short)
          # Stage prefix OR type as publisher
          if typed_stage && typed_stage.abbr && typed_stage.abbr.first != type_short
            parts << typed_stage.abbr.first
          else
            parts << type_short
          end
        else
          # Draft stage prefix (prEN, FprEN) OR regular publisher
          if is_draft_stage
            parts << typed_stage.abbr.first
          elsif publisher
            parts << (publisher.respond_to?(:body) ? publisher.body : publisher.to_s)
            use_slash_before_type = true  # When publisher present, use slash before type
          end
        end

        # Copublishers - add to last part (publisher) with slash
        if copublishers && copublishers.any?
          copub_str = copublishers.map { |cp| cp.respond_to?(:body) ? cp.body : cp.to_s }.join("/")
          unless copub_str.empty?
            if parts.any?
              parts[-1] = "#{parts[-1]}/#{copub_str}"
            else
              parts << copub_str
            end
          end
        end

        # Type for non-EN documents (TS, TR) - but not CWA/HD or Guide
        if type_short != "EN" && !%w[CWA HD Guide].include?(type_short)
          if use_slash_before_type && parts.any?
            # Use slash separator for publisher/type combination (TS, TR only)
            parts << "/#{type_short}"
          else
            parts << type_short
          end
        elsif type_short == "Guide"
          # Guide uses SPACE separator, not slash
          parts << "Guide"
        end

        # Number with part (which may be multi-level like "5-1-1")
        if number
          number_str = number.respond_to?(:value) ? number.value.to_s : number.to_s
          if part
            part_val = part.respond_to?(:value) ? part.value : part
            number_str += "-#{part_val}"
          end
          parts << number_str
        end

        # Join parts - but handle slash prefix for type
        result = ""
        parts.each_with_index do |part, idx|
          if idx > 0 && !part.start_with?("/")
            result += " "
          end
          result += part
        end

        # Date
        if date
          year_val = date.respond_to?(:year) ? date.year : date.to_i
          result += ":#{year_val}"
        end

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