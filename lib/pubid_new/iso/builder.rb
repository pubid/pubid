# frozen_string_literal: true

require_relative "../components/date"
require_relative "components/publisher"
require_relative "components/code"
require_relative "identifiers/international_standard"
require_relative "identifiers/guide"

module PubidNew
  module Iso
    class Builder
      def self.build(parsed_data)
        new.build(parsed_data)
      end

      def build(data)
        # Convert array of hashes to single hash
        if data.is_a?(Array)
          data = data.inject({}) { |acc, h| acc.merge(h) }
        end

        # Build publisher
        publisher = build_publisher(data)

        # Build code
        code = build_code(data)

        # Determine type - typed_stage may contain type info
        type_str = extract_type(data)
        stage_str = extract_stage(data)

        # Select appropriate class
        klass = if type_str == "Guide" || type_str == "GUIDE"
          Identifiers::Guide
        else
          Identifiers::InternationalStandard
        end

        klass.new(
          publisher: publisher,
          type: (type_str == "Guide" || type_str == "GUIDE") ? nil : type_str,
          code: code,
          year: data[:year]&.to_i,
          stage: stage_str,
          iteration: data[:iteration]&.to_i,
          language: data[:language]&.to_s
        )
      end

      private

      def extract_type(data)
        # Typed stages like "DTR" mean  "Draft TR"
        if data[:typed_stage]
          ts = data[:typed_stage].to_s
          return "TR" if ts.include?("TR")
          return "TS" if ts.include?("TS")
        end

        data[:type]&.to_s
      end

      def extract_stage(data)
        # Typed stages like "DTR" mean type=TR, stage=Draft
        if data[:typed_stage]
          ts = data[:typed_stage].to_s
          return "CD" if ts.start_with?("D") && !ts.start_with?("DIS")
          return "DIS" if ts == "DIS"
          return "FDIS" if ts == "FDIS"
          return ts
        end

        data[:stage]&.to_s
      end

      def build_publisher(data)
        copubs = []
        if data[:copublisher]
          copubs = data[:copublisher].is_a?(Array) ? data[:copublisher].map(&:to_s) : [data[:copublisher].to_s]
        end

        Components::Publisher.new(
          publisher: data[:publisher]&.to_s || "ISO",
          copublisher: copubs.empty? ? nil : copubs
        )
      end

      def build_code(data)
        parts = []
        if data[:parts] && data[:parts].is_a?(Array) && data[:parts].any?
          parts = data[:parts].map { |p| p[:part].to_s }
        end

        Components::Code.new(
          number: data[:number].to_s,
          parts: parts.empty? ? nil : parts
        )
      end
    end
  end
end
