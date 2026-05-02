# frozen_string_literal: true

require "json"

module Pubid
  module Export
    # Compares library-generated metadata against website publisher data.
    # Reports gaps: missing types, extra types, stage mismatches.
    #
    # Open/Closed: New audit dimensions can be added as new methods.
    class Auditor
      attr_reader :generated, :website

      # @param generated_path [String] Path to website-data.json
      # @param website_path [String] Path to publishers.ts (not parsed; uses key matching)
      def initialize(generated_data)
        @generated = generated_data
      end

      def self.from_file(path)
        data = JSON.parse(File.read(path))
        new(data)
      end

      def audit(website_publishers)
        results = {}

        generated.each do |flavor, gen_data|
          website_data = website_publishers[flavor]
          results[flavor] = audit_flavor(flavor, gen_data, website_data)
        end

        # Also check for website flavors not in generated data
        website_publishers.each_key do |flavor|
          next if results.key?(flavor)
          results[flavor] = { missing_from_library: true }
        end

        results
      end

      def summary(audit_results)
        lines = []
        total_missing = 0
        total_extra = 0

        audit_results.each do |flavor, result|
          next if result.empty?
          missing = result[:missing_types] || []
          extra = result[:extra_types] || []

          if !missing.empty? || !extra.empty?
            lines << "#{flavor}:"
            lines.concat(missing.map { |t| "  MISSING from website: #{t[:key]} (#{t[:title]})" })
            lines.concat(extra.map { |t| "  EXTRA in website (not in library): #{t}" })
            total_missing += missing.size
            total_extra += extra.size
          end
        end

        lines.unshift("Audit Summary: #{total_missing} missing, #{total_extra} extra")
        lines.join("\n")
      end

      private

      def audit_flavor(flavor, gen_data, website_data)
        result = {}
        return result unless website_data

        gen_keys = (gen_data["identifier_types"] || []).map { |t| t["key"] }
        web_keys = (website_data["doc_types"] || []).map { |t| t["key"] }

        result[:missing_types] = gen_data["identifier_types"].reject { |t| web_keys.include?(t["key"]) }
        result[:extra_types] = web_keys.reject { |k| gen_keys.include?(k) }

        result
      end
    end
  end
end
