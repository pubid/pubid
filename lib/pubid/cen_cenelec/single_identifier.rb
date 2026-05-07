# frozen_string_literal: true

module Pubid
  module CenCenelec
    class SingleIdentifier < Pubid::Identifier
      attribute :publisher, Components::Publisher, default: -> {
        Components::Publisher.new(body: "EN")
      }

      # Generate URN for this identifier
      #
      # @return [String] URN representation

      def to_s(lang: :en, lang_single: false)
        parts = []

        # Check if we have a draft stage (prEN, FprEN) - these include both stage and type
        is_draft_stage = typed_stage&.abbr && %w[prEN
                                                 FprEN].include?(typed_stage.abbr.first)

        # Get type short name - for draft stages, extract base type
        type_short = if is_draft_stage
                       typed_stage.type_code.to_s.upcase # :en => "EN"
                     elsif type.is_a?(Components::Type)
                       type.abbr
                     elsif self.class.respond_to?(:type) && self.class.type.is_a?(Hash)
                       self.class.type[:short]
                     else
                       "EN" # Default
                     end

        # Track if we should use slash before type
        use_slash_before_type = false

        # For CWA/HD, they act as publisher (not EN)
        if %w[CWA HD CR].include?(type_short)
          # Stage prefix OR type as publisher
          parts << if typed_stage&.abbr && typed_stage.abbr.first != type_short
                     typed_stage.abbr.first
                   else
                     type_short
                   end
        elsif is_draft_stage
          # Draft stage prefix (prEN, FprEN) OR regular publisher
          parts << typed_stage.abbr.first
        elsif publisher
          parts << (publisher.is_a?(Components::Publisher) ? publisher.body : publisher.to_s)
          use_slash_before_type = true # When publisher present, use slash before type
        end

        # Copublishers - add to last part (publisher) with slash
        if copublishers&.any?
          copub_str = copublishers.map do |cp|
            cp.is_a?(Components::Publisher) ? cp.body : cp.to_s
          end.join("/")
          unless copub_str.empty?
            if parts.any?
              parts[-1] = "#{parts[-1]}/#{copub_str}"
            else
              parts << copub_str
            end
          end
        end

        # Type for non-EN documents (TS, TR) - but not CWA/HD or Guide
        if type_short != "EN" && !%w[CWA HD CR Guide].include?(type_short)
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
          number_str = number.is_a?(Components::Code) ? number.value.to_s : number.to_s
          if part
            part_val = part.is_a?(Components::Code) ? part.value : part
            number_str += "-#{part_val}"
          end
          parts << number_str
        end

        # Join parts - but handle slash prefix for type
        result = ""
        parts.each_with_index do |part, idx|
          if idx.positive? && !part.start_with?("/")
            result += " "
          end
          result += part
        end

        # Date
        if date
          year_val = date.is_a?(Components::Date) ? date.year : date.to_i
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
