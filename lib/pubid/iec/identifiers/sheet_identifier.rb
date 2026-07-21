# frozen_string_literal: true

module Pubid
  module Iec
    module Identifiers
      # Sheet Identifier
      # Single Responsibility: Wraps another identifier with sheet number and year
      # Example: "IEC 60695-2-1/1:1994" = Sheet 1 of IEC 60695-2-1 from 1994
      class SheetIdentifier < Identifier
        attribute :base, Identifier, polymorphic: true
        attribute :sheet_number, :string
        attribute :year, :string, default: -> {}

        # Common fields are delegated to base, so serialize the
        # wrapped identifier under "base" plus the sheet number/year; suppress
        # the delegated common maps (they live inside "base").
        include Pubid::Iec::DelegatedFieldSuppression

        key_value do
          map "base", with: { to: :base_to_kv, from: :base_from_kv }
          map "sheet_number", to: :sheet_number, render_default: false
          map "sheet_year", to: :year, render_default: false
        end

        def base_to_kv(model, doc)
          base = model.base
          return unless base

          doc.add_child(Lutaml::KeyValue::DataModel::Element.new("base",
                                                                 base.to_hash))
        end

        def base_from_kv(model, value)
          model.base = ::Pubid::Iec::Identifier.from_hash(value) if value
        end

        # Delegate common attributes to base
        def publisher
          base&.publisher
        end

        def copublishers
          base&.copublishers
        end

        def code
          base&.code
        end

        def number
          base&.number
        end

        def date
          base&.date
        end

        def stage
          base&.stage
        end

        def typed_stage
          base&.typed_stage
        end
      end
    end
  end
end
