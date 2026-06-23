# frozen_string_literal: true

module Pubid
  module Iec
    module Identifiers
      # VAP (Version/Compilation) Identifier
      # Single Responsibility: Wraps another identifier with VAP type suffix
      # Examples: "IEC 61666:2010+AMD1:2021 CSV"
      class VapIdentifier < Identifier
        attribute :base_identifier, Identifier, polymorphic: true
        # One or more VAP codes (e.g. ["CSV"] or ["EXV", "CMV"]). Plain strings.
        attribute :vap, :string, collection: true
        attribute :edition, ::Pubid::Components::Edition, default: -> {}

        # number/date/publisher/stage are delegated to base_identifier, so
        # serialize the wrapped identifier under "base" plus the vap array; the
        # common fields live inside "base", not at the top level.
        include Pubid::Iec::DelegatedFieldSuppression

        key_value do
          map "base", with: { to: :base_to_kv, from: :base_from_kv }
          map "vap", to: :vap, render_default: false
        end

        def base_to_kv(model, doc)
          base = model.base_identifier
          return unless base

          doc.add_child(Lutaml::KeyValue::DataModel::Element.new("base",
                                                                base.to_hash))
        end

        def base_from_kv(model, value)
          model.base_identifier = ::Pubid::Iec::Identifier.from_hash(value) if value
        end

        # VAP types mapping
        TYPE_MAP = {
          "CSV" => "Consolidated version (with Supplements)",
          "CMV" => "Compiled Maintenance Version",
          "RLV" => "Redline Version (shows changes)",
          "SER" => "Serial version",
        }.freeze

        def to_s(**opts)
          render(format: :human, **opts)
        end

        # Delegate common attributes to base_identifier
        def publisher
          base_identifier&.publisher
        end

        def copublishers
          base_identifier&.copublishers
        end

        def code
          base_identifier&.code
        end

        def number
          base_identifier&.number
        end

        def date
          base_identifier&.date
        end

        def stage
          base_identifier&.stage
        end

        def typed_stage
          base_identifier&.typed_stage
        end
      end
    end
  end
end
