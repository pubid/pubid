module PubidNew
  module Bsi
    class Builder
      attr_reader :scheme

      def initialize(scheme)
        @scheme = scheme
      end

      def build(data)
        # Handle national annex
        if data[:national_annex]
          return build_national_annex(data)
        end

        # Handle collection (combined documents)
        if data[:second_number]
          return build_collection(data)
        end

        # Handle expert commentary wrapper
        if data[:expert_commentary]
          return build_expert_commentary(data)
        end

        # Build regular identifier
        build_identifier(data)
      end

      private

      def build_national_annex(data)
        na_data = data[:national_annex]
        
        # Build the supplement if present
        na_supplement = nil
        if na_data[:supplement]
          na_supplement = build_supplement(na_data[:supplement])
        end
        
        # Build the base identifier (without NA prefix)
        base_data = data.dup
        base_data.delete(:national_annex)
        base_identifier = build_identifier(base_data)
        
        # Create national annex model
        na = NationalAnnex.new(
          type: na_data[:type],
          supplement: na_supplement,
          base: base_identifier
        )
        
        # Return an identifier with the NA
        Identifier.new(
          national_annex: na,
          type: data[:type] || "BS",
          number: data[:number],
          part: data[:part],
          year: data[:year],
          supplements: build_supplements(data[:supplements]),
          adopted: build_adopted(data[:adopted])
        )
      end

      def build_collection(data)
        Collection.new(
          type: data[:type] || "BS",
          numbers: [data[:number], data[:second_number]],
          year: data[:year],
          supplements: build_supplements(data[:supplements])
        )
      end

      def build_expert_commentary(data)
        # Build base identifier without expert_commentary flag
        base_data = data.dup
        base_data.delete(:expert_commentary)
        base_identifier = build_identifier(base_data)
        
        # Return identifier with expert_commentary flag
        Identifier.new(
          expert_commentary: true,
          type: data[:type] || "BS",
          number: data[:number],
          part: data[:part],
          year: data[:year],
          month: data[:month],
          supplements: build_supplements(data[:supplements]),
          adopted: build_adopted(data[:adopted])
        )
      end

      def build_identifier(data)
        Identifier.new(
          type: data[:type] || "BS",
          number: data[:number],
          part: data[:part],
          second_number: data[:second_number],
          year: data[:year],
          month: data[:month],
          edition: data[:edition],
          supplements: build_supplements(data[:supplements]),
          adopted: build_adopted(data[:adopted]),
          expert_commentary: data[:expert_commentary] || false,
          tracked_changes: data[:tracked_changes] || false,
          translation: data[:translation],
          pdf: data[:pdf] || false
        )
      end

      def build_supplements(supplements_data)
        return [] unless supplements_data
        
        supplements_array = supplements_data.is_a?(Array) ? supplements_data : [supplements_data]
        supplements_array.map { |s| build_supplement(s) }
      end

      def build_supplement(supp_data)
        return nil unless supp_data
        
        Supplement.new(
          type: supp_data[:type],
          number: supp_data[:number],
          year: supp_data[:year]
        )
      end

      def build_adopted(adopted_data)
        return nil unless adopted_data
        
        case adopted_data[:flavor]
        when "iec"
          adopted_data[:identifier]
        when "iso"
          adopted_data[:identifier]
        when "cen"
          adopted_data[:identifier]
        when "unknown"
          # Return as string if parsing failed
          adopted_data[:text]
        else
          nil
        end
      end
    end
  end
end