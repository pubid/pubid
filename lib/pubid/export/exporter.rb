# frozen_string_literal: true

module Pubid
  module Export
    # Top-level orchestrator. Iterates flavors and delegates to FlavorExporter.
    #
    # Open/Closed: Adding a new flavor only requires adding it to FLAVORS;
    # no existing code changes.
    class Exporter
      FLAVORS = %i[
        iso iec ieee nist bsi itu cen_cenelec etsi ansi astm ashrae asme
        ccsds cie csa jis jcgm oiml idf api amca plateau sae xsf
      ].freeze

      # Export all flavors to a hash suitable for JSON serialization.
      # @return [Hash{String => Hash}]
      def self.export_all
        require "pubid"

        FLAVORS.each_with_object({}) do |flavor, result|
          exporter = FlavorExporter.new(flavor)
          flavor_result = exporter.export
          next unless flavor_result

          result[flavor.to_s] = flavor_result.to_hash
        rescue StandardError => e
          warn "Export warning (#{flavor}): #{e.message}"
        end
      end
    end
  end
end
