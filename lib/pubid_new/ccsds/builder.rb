# frozen_string_literal: true

require_relative "identifiers/base"

module PubidNew
  module Ccsds
    class Builder
      def self.build(parsed_data)
        new.build(parsed_data)
      end

      def build(data)
        # Extract corrigenda
        corrigenda = []
        if data[:corrigenda]
          corr_array = data[:corrigenda]
          corr_array = [corr_array] unless corr_array.is_a?(Array)
          corrigenda = corr_array.map { |c| c[:cor_number].to_i }
        end

        Identifiers::Base.new(
          number: data[:number].to_s,
          part: data[:part]&.to_s,
          type: data[:type]&.to_s,
          edition: data[:edition]&.to_s,
          suffix: data[:suffix]&.to_s,
          corrigenda: corrigenda.empty? ? nil : corrigenda,
          language: data[:language]&.to_s
        )
      end
    end
  end
end