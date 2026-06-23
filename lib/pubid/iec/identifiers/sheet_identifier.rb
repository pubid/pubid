# frozen_string_literal: true

module Pubid
  module Iec
    module Identifiers
      # Sheet Identifier
      # Single Responsibility: Wraps another identifier with sheet number and year
      # Example: "IEC 60695-2-1/1:1994" = Sheet 1 of IEC 60695-2-1 from 1994
      class SheetIdentifier < Identifier
        attribute :base_identifier, Identifier, polymorphic: true
        attribute :sheet_number, :string
        attribute :year, :string, default: -> {}

        # Common fields are delegated to base_identifier, so serialize the
        # wrapped identifier under "base" plus the sheet number/year; suppress
        # the delegated common maps (they live inside "base").
        include Pubid::Iec::DelegatedFieldSuppression

        key_value do
          map "base", with: { to: :base_to_kv, from: :base_from_kv }
          map "sheet_number", to: :sheet_number, render_default: false
          map "sheet_year", to: :year, render_default: false
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
