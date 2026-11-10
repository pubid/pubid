# frozen_string_literal: true

module Pubid
  module Iec
    module Identifiers
      # Test Report Form identifier class
      # Single Responsibility: Represents IEC TRF documents
      # Can embed CISPR identifiers for IECEE TRF format
      class TestReportForm < Base
        # TRF can embed a CISPR identifier (MODEL-DRIVEN)
        attribute :cispr_identifier, Identifier, polymorphic: true, default: -> {
        }

        # The embedded CISPR document is part of the form's identity, so it
        # serializes under its own key (issue #687 — before it, a
        # CISPR-bearing TRF hashed to just its publisher and year and never
        # matched after a from_hash round trip). The converter shape is
        # VapIdentifier#base_to_kv / #base_from_kv: the nested identifier
        # carries its own polymorphic `_type`, so to_hash embeds the nested
        # hash and from_hash dispatches back through the type map.
        key_value do
          map "cispr_identifier",
              with: { to: :cispr_identifier_to_kv,
                      from: :cispr_identifier_from_kv }
        end

        def cispr_identifier_to_kv(model, doc)
          cispr = model.cispr_identifier
          return unless cispr

          doc.add_child(
            Lutaml::KeyValue::DataModel::Element.new("cispr_identifier",
                                                     cispr.to_hash),
          )
        end

        def cispr_identifier_from_kv(model, value)
          if value
            model.cispr_identifier = ::Pubid::Iec::Identifier.from_hash(value)
          end
        end

        # TRF has type abbreviation for parsing
        TYPED_STAGES = [
          Pubid::Components::TypedStage.new(
            code: :trf,
            stage_code: :published,
            type_code: :trf,
            abbr: ["TRF"],
            name: "Test Report Form",
            harmonized_stages: %w[60.00 60.60],
          ),
        ].freeze

        def self.type
          { key: :trf,
            web: :test_report_form, title: "Test Report Form", short: "TRF" }
        end

        # TRF uses special rendering via the Renderer
      end
    end
  end
end
