# frozen_string_literal: true

module Pubid
  module Iec
    class SingleIdentifier < Identifier
      # Default to the class's published typed_stage so an omitted "stage" key
      # reconstructs the published state on from_hash.
      attribute :typed_stage, ::Pubid::Components::TypedStage,
                default: -> { self.class.published_typed_stage }

      # number/part/subpart are mapped HERE, not on Iec::Identifier, and the
      # placement is the whole design.
      #
      # The four wrapper identifiers — FragmentIdentifier,
      # ConsolidatedIdentifier, VapIdentifier and SheetIdentifier — inherit
      # from Iec::Identifier DIRECTLY and override `number`/`part`/`subpart` as
      # readers that delegate to what they wrap. A map on the shared parent
      # would therefore serialize
      # the delegated value twice: once at the wrapper's top level and again
      # inside "base"/"identifiers". SingleIdentifier is the seam that excludes
      # exactly those four while covering both classes that own a number of
      # their own (Identifiers::Base and SupplementIdentifier).
      #
      # That is a structural exclusion, not a denylist of no-op converters that
      # a later key can be forgotten from. The date keys live here for the
      # same reason: the wrappers delegate `date` too, and when the date maps
      # sat on Iec::Identifier the denylist no-opped `year` but not
      # `month`/`day`/`undated`, so `IEC CA 01:2025-10 CSV` emitted a second,
      # top-level "month" beside the one inside "base".
      #
      # number/part/subpart are plain strings, so no converter is needed:
      # lutaml writes the scalar, and ::Pubid::Identifier#to_hash drops a nil.
      # The date keys keep converters, because they split one `date`
      # attribute across four keys.
      key_value do
        map "number", to: :number
        map "part", to: :part
        map "subpart", to: :subpart
        # date serialized flat as year/month/day, nils omitted.
        map "year", with: { to: :year_to_kv, from: :year_from_kv }
        map "month", with: { to: :month_to_kv, from: :month_from_kv }
        map "day", with: { to: :day_to_kv, from: :day_from_kv }
        # IEC undated reference (e.g. IEC 60050:--). The `false` default is
        # omitted; only the meaningful `true` round-trips via to_hash.
        map "undated", with: { to: :undated_to_kv, from: :undated_from_kv }
      end

      # --- date serialized flat as year/month/day ---
      def year_to_kv(model, doc)
        y = model.date&.year
        return if y.nil? || y.to_s.empty?

        doc.add_child(Lutaml::KeyValue::DataModel::Element.new("year", y.to_s))
      end

      def year_from_kv(model, value)
        return if value.nil? || value.to_s.empty?

        (model.date ||= ::Pubid::Components::Date.new).year = value.to_s
      end

      def month_to_kv(model, doc)
        m = model.date&.month
        return if m.nil? || m.to_s.empty?

        doc.add_child(Lutaml::KeyValue::DataModel::Element.new("month", m.to_s))
      end

      def month_from_kv(model, value)
        return if value.nil? || value.to_s.empty?

        (model.date ||= ::Pubid::Components::Date.new).month = value.to_s
      end

      def day_to_kv(model, doc)
        d = model.date&.day
        return if d.nil? || d.to_s.empty?

        doc.add_child(Lutaml::KeyValue::DataModel::Element.new("day", d.to_s))
      end

      def day_from_kv(model, value)
        return if value.nil? || value.to_s.empty?

        (model.date ||= ::Pubid::Components::Date.new).day = value.to_s
      end

      # --- date undated flag (IEC undated reference, e.g. IEC 60050:--) ---
      # The `false` default is omitted; only the meaningful `true` round-trips
      # via to_hash / from_hash.
      def undated_to_kv(model, doc)
        return unless model.date&.undated?

        doc.add_child(Lutaml::KeyValue::DataModel::Element.new("undated", true))
      end

      def undated_from_kv(model, value)
        (model.date ||= ::Pubid::Components::Date.new).undated = value.to_s == "true"
      end

      # Generate URN for this identifier
      #
      # @return [String] URN representation

      def to_s(**opts)
        render(format: :human, **opts)
      end

      def publisher_portion(lang: :en)
        # IEC identifiers can have copublishers (e.g., IEC/IEEE, ISO/IEC)

        # Build publisher string
        pub_string = if copublishers&.any?
                       # Has copublishers: "IEC/IEEE" or "ISO/IEC"
                       ([publisher] + copublishers).map(&:body).join("/")
                     else
                       # No copublishers: just "IEC"
                       publisher.body
                     end

        # IEC house style separates the publisher from the typed-stage
        # abbreviation with a SPACE, for every type and whether or not there
        # are copublishers: "IEC CD 60038", "IEC PNW 1000-1:2023". The slash
        # stays the copublisher separator only. The slash input spelling
        # ("IEC/CD 60038") is still accepted by the parser; only rendering
        # normalises. See issue #360 item 2.
        abbr = typed_stage&.abbreviation.to_s
        pub_string += " #{abbr}" unless abbr.empty?

        pub_string
      end

      def number_portion(lang_single: false)
        [
          (number ? number.to_s : ""),
          (part ? "-#{part}" : ""),
          (subpart ? "-#{subpart}" : ""),
          (stage_iteration ? ".#{stage_iteration}" : ""),
          (date ? ":#{date.render}" : ""),
        ].join
      end

      def language_portion(lang_single: false)
        return "" unless languages&.any?

        # IEC house style joins multiple language codes with '-'
        # ("IEC 60050-103:2020(en-fr)"), not ',' (pubid#491; pubid-iec 1.x
        # behavior, which metanorma-iec's fixtures encode).
        [
          "(",
          languages.map do |lang|
            lang.to_s(lang_single: lang_single)
          end.join(lang_single ? "/" : "-"),
          ")",
        ].join
      end

      def edition_portion(lang: :en)
        return nil unless edition&.number

        "ED#{edition.number}"
      end
    end
  end
end
