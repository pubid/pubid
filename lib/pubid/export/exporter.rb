# frozen_string_literal: true

module Pubid
  module Export
    # Top-level orchestrator. Iterates flavors, selects the appropriate
    # extraction strategy, and produces the combined result.
    #
    # Open/Closed: Adding a new flavor only requires registering it in
    # FLAVOR_STRATEGIES; no existing code changes.
    class Exporter
      FLAVORS = %i[
        iso iec ieee nist bsi itu cen_cenelec etsi ansi astm ashrae asme
        ccsds cie csa jis jcgm oiml idf api amca plateau sae
      ].freeze

      # Maps each flavor to its extraction strategy class.
      # When a flavor follows a new pattern, add a new strategy class here.
      FLAVOR_STRATEGIES = {
        iso: :scheme,
        iec: :scheme,
        ieee: :ieee,
        nist: :nist,
        bsi: :registry,
        itu: :itu,
        cen_cenelec: :registry,
        etsi: :data_class,
        ansi: :scheme,
        astm: :scheme,
        ashrae: :scheme,
        asme: :scheme,
        ccsds: :scheme,
        cie: :scheme,
        csa: :scheme,
        jis: :scheme,
        jcgm: :scheme,
        oiml: :scheme,
        idf: :scheme,
        api: :scheme,
        amca: :scheme,
        plateau: :data_class,
        sae: :scheme,
      }.freeze

      STRATEGY_CLASSES = {
        scheme: SchemeExporter,
        registry: RegistryExporter,
        data_class: DataClassExporter,
        nist: NistExporter,
        ieee: IeeeExporter,
        itu: ItuExporter,
      }.freeze

      # Export all flavors to a hash suitable for JSON serialization.
      # @return [Hash{String => Hash}]
      def self.export_all
        require "pubid"

        FLAVORS.each_with_object({}) do |flavor, result|
          strategy_name = FLAVOR_STRATEGIES[flavor]
          strategy_class = STRATEGY_CLASSES[strategy_name]
          next unless strategy_class

          exporter = strategy_class.new(flavor)
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
