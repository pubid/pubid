# frozen_string_literal: true

module Pubid
  module Ccsds
    class Builder
      def self.build(parsed_data)
        new.build(parsed_data)
      end

      def build(data)
        # Check if corrigenda are present - if so, build Corrigendum objects
        if data[:corrigenda] && !data[:corrigenda].empty?
          return build_corrigendum(data)
        end

        # Build base identifier
        build_base(data)
      end

      private

      def build_base(data)
        Identifiers::Base.new(
          number: data[:number].to_s,
          part: data[:part]&.to_s,
          type: data[:type]&.to_s,
          edition: data[:edition]&.to_s,
          suffix: data[:suffix]&.to_s,
          language: data[:language]&.to_s,
        )
      end

      def build_corrigendum(data)
        # Extract corrigenda numbers
        corr_array = data[:corrigenda]
        corr_array = [corr_array] unless corr_array.is_a?(Array)
        corr_numbers = corr_array.map { |c| c[:cor_number].to_s }

        # Build base identifier (without corrigenda)
        base_data = data.dup
        base_data.delete(:corrigenda)
        base = build_base(base_data)

        # Build Corrigendum object for each corrigendum number. The corrigendum
        # sequence is stored in the inherited `number` attribute (mirroring ISO).
        # Note: CCSDS uses "Cor. 1" format (single corrigendum per identifier)
        # If multiple corrigenda exist, we build the last one wrapping the base
        corr_numbers.reduce(base) do |current_base, cor_num|
          Identifiers::Corrigendum.new(
            base_identifier: current_base,
            number: cor_num,
          )
        end
      end
    end
  end
end
