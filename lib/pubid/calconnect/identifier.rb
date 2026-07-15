# frozen_string_literal: true

module Pubid
  module Calconnect
    # Base class for every CalConnect identifier AND the flavor's parse entry
    # point — mirrors Pubid::Jis::Identifier. Concrete identifiers under
    # Pubid::Calconnect::Identifiers descend from this class, so a parsed
    # CalConnect id is an instance of Pubid::Calconnect::Identifier and
    # relaton-index can pass this class as `pubid_class` for from_hash/to_hash.
    class Identifier < ::Pubid::Identifier
      # `number` is a CalConnect-specific plain string (preserves leading zeros
      # like "0514" and the sub-part separator, "0812-1"/"0707.1"), so it
      # overrides the inherited Components::Code type. The publication date uses
      # the shared Pubid::Components::Date (inherited attribute): `year` is
      # always present, `month`/`day` only for the rare full-date form
      # ("CC/WD 51017:2024-07-23").
      attribute :series, :string # Optional series letter/token (A, WD, DIR, …)
      attribute :number, :string
      attribute :date, ::Pubid::Components::Date

      # Polymorphic type map for lutaml::Model key_value (de)serialization,
      # mapping the concrete class's polymorphic_name to its class name so a
      # stored hash rebuilds the correct identifier type via from_hash.
      CALCONNECT_TYPE_MAP = {
        "pubid:calconnect:standard" => "Pubid::Calconnect::Identifiers::Standard",
      }.freeze

      # The date serializes FLAT as year/month/day string keys (nils omitted),
      # mirroring lib/pubid/iso/identifier.rb — not as a nested "date" object —
      # so the index row stays a shallow hash and round-trips exactly.
      key_value do
        map "_type", to: :_type, polymorphic_map: CALCONNECT_TYPE_MAP
        map "series", to: :series
        map "number", to: :number
        map "year", with: { to: :year_to_kv, from: :year_from_kv }
        map "month", with: { to: :month_to_kv, from: :month_from_kv }
        map "day", with: { to: :day_to_kv, from: :day_from_kv }
      end

      # Publisher is always "CC". A plain constant (not a `publisher` method) so
      # it doesn't shadow the inherited lutaml `publisher` attribute, which
      # would otherwise fail serialization type validation.
      PUBLISHER = "CC"

      attr_reader :with_publisher

      # Render the publication date, e.g. "2018" or "2024-07-23". Shared by the
      # renderer and the URN generator so they always agree.
      # Pubid::Components::Date#to_s yields the year alone, or the zero-padded
      # "YYYY-MM-DD" when month/day are present.
      def date_string
        date&.to_s
      end

      # Basic string representation. Delegates to the human renderer. The
      # printed CalConnect id carries the "CC" publisher token by default; pass
      # with_publisher: false to drop it (and the series slash).
      def to_s(**opts)
        render(format: :human, **opts)
      end

      # Capture the with_publisher flag on EVERY render call (default true), so
      # it can never leak across calls. The base `render` only forwards
      # `:with_edition` to the renderer, so the flag is threaded via this
      # per-call instance write (the renderer reads `id.with_publisher`).
      def render(format: :human, with_publisher: true, **opts)
        @with_publisher = with_publisher
        super(format: format, **opts)
      end

      # --- date serialized flat as year/month/day (mirrors ISO) ---
      def year_to_kv(model, doc)
        emit_date_part(doc, "year", model.date&.year)
      end

      def month_to_kv(model, doc)
        emit_date_part(doc, "month", model.date&.month)
      end

      def day_to_kv(model, doc)
        emit_date_part(doc, "day", model.date&.day)
      end

      def year_from_kv(model, value) = date_for(model).year = value.to_s
      def month_from_kv(model, value) = date_for(model).month = value.to_s
      def day_from_kv(model, value) = date_for(model).day = value.to_s

      def emit_date_part(doc, key, val)
        return if val.nil? || val.to_s.empty?

        doc.add_child(Lutaml::KeyValue::DataModel::Element.new(key, val.to_s))
      end

      def date_for(model)
        model.date ||= ::Pubid::Components::Date.new
      end

      # from_hash is the shared polymorphic dispatch on Pubid::Identifier.
      # CALCONNECT_TYPE_MAP remains as the key_value polymorphic_map.

      # Parse a CalConnect identifier string into an identifier object.
      # @param identifier [String] The CalConnect identifier string to parse
      # @return [Identifier] The appropriate identifier object
      # @raise [ArgumentError] If the input exceeds the maximum length
      # @raise [RuntimeError] If parsing fails
      def self.parse(identifier)
        if identifier.length > Pubid::MAX_INPUT_LENGTH
          raise ArgumentError, Pubid::INPUT_TOO_LONG_MESSAGE
        end

        Builder.build(Parser.parse(identifier))
      rescue Parslet::ParseFailed => e
        raise "Failed to parse CalConnect '#{identifier}': #{e.message}"
      end
    end
  end
end
