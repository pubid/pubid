# frozen_string_literal: true

module Pubid
  module Etsi
    module Identifiers
      # Single class for all ETSI standard types
      # Type is passed as parameter: EN, ES, EG, TS, ETR, ETS, I-ETS, TBR,
      # TCRTR, NET, GR, GS, SR, TR, GTS
      # Format: ETSI TYPE CODE VERSION (DATE)
      # Examples:
      #   ETSI GS ZSM 012 V1.1.1 (2022-12)
      #   ETSI GR ZSM 009-3 V1.1.1 (2023-08)
      #   ETSI GTS GSM 02.01 V5.5.0 (1999-01)
      class EtsiStandard < Identifier
        # Type is stored in @type attribute from Identifier
        # All rendering handled by Identifier class

        # Compact serialization (mirrors ISO/JCGM/OIML): the Code component
        # collapses to a bare `number` scalar (plus a `parts` array and, rarely,
        # a `minor` scalar); Version flattens to a scalar `version` string with
        # an `is_edition` boolean flag (omitted when false); Date flattens to
        # top-level year/month/day. The constant `publisher` ("ETSI") is
        # intentionally NOT mapped — it is reconstructed on load from its
        # attribute default, keeping the hash compact.
        #
        # This block lives on EtsiStandard (a leaf) rather than the shared Identifier:
        # SupplementIdentifier is a sibling that DELEGATES type/code/version and
        # date to its inner `base`, so a block on Identifier would be inherited-and-
        # merged by the supplement and re-emit every delegated field at the top.
        key_value do
          map "_type",      to: :_type
          map "type",       to: :type
          map "number",     with: { to: :number_to_kv, from: :number_from_kv }
          map "parts",      with: { to: :parts_to_kv,  from: :parts_from_kv }
          map "minor",      with: { to: :minor_to_kv,  from: :minor_from_kv }
          map "version",    with: { to: :version_to_kv, from: :version_from_kv }
          map "is_edition", with: { to: :edition_to_kv, from: :edition_from_kv }
          map "year",       with: { to: :year_to_kv,  from: :year_from_kv }
          map "month",      with: { to: :month_to_kv, from: :month_from_kv }
          map "day",        with: { to: :day_to_kv,   from: :day_from_kv }
        end

        # --- Code component flattened to bare number / parts / minor ---
        def number_to_kv(model, doc)
          emit_kv(doc, "number", model.code&.number)
        end

        def number_from_kv(model, value)
          code_for(model).number = value.to_s
        end

        def minor_to_kv(model, doc)
          emit_kv(doc, "minor", model.code&.minor)
        end

        def minor_from_kv(model, value)
          code_for(model).minor = value.to_s
        end

        def parts_to_kv(model, doc)
          parts = model.code&.parts
          return if parts.nil? || parts.empty?

          doc.add_child(
            Lutaml::KeyValue::DataModel::Element.new(
              "parts", parts.map(&:to_s)
            ),
          )
        end

        def parts_from_kv(model, value)
          code_for(model).parts = Array(value).map(&:to_s)
        end

        # --- Version flattened to scalar version + is_edition flag ---
        def version_to_kv(model, doc)
          emit_kv(doc, "version", model.version&.version)
        end

        def version_from_kv(model, value)
          version_for(model).version = value.to_s
        end

        def edition_to_kv(model, doc)
          return unless model.version&.is_edition

          doc.add_child(
            Lutaml::KeyValue::DataModel::Element.new("is_edition", true),
          )
        end

        def edition_from_kv(model, value)
          version_for(model).is_edition = value
        end

        # --- Date flattened to top-level year/month/day scalars ---
        def year_to_kv(model, doc)
          emit_kv(doc, "year", model.date&.year)
        end

        def month_to_kv(model, doc)
          emit_kv(doc, "month", model.date&.month)
        end

        def day_to_kv(model, doc)
          emit_kv(doc, "day", model.date&.day)
        end

        def year_from_kv(model, value)
          date_for(model).year = value.to_s
        end

        def month_from_kv(model, value)
          date_for(model).month = value.to_s
        end

        def day_from_kv(model, value)
          date_for(model).day = value.to_s
        end

        def emit_kv(doc, key, value)
          return if value.nil? || value.to_s.empty?

          doc.add_child(
            Lutaml::KeyValue::DataModel::Element.new(key, value.to_s),
          )
        end

        def code_for(model)
          model.code ||= Pubid::Etsi::Components::Code.new
        end

        def version_for(model)
          model.version ||= Pubid::Etsi::Components::Version.new
        end

        def date_for(model)
          model.date ||= Pubid::Components::Date.new
        end
      end
    end
  end
end
