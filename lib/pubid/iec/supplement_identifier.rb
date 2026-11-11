# frozen_string_literal: true

module Pubid
  module Iec
    # Identifier that represents a supplement to a base identifier.
    class SupplementIdentifier < SingleIdentifier
      attribute :base, Identifier, polymorphic: true

      # Serialize the supplemented document under "base". The supplement's own
      # number/date/stage come from the inherited common maps; route the nested
      # base hash back through Identifier.from_hash so its concrete subclass (and
      # any further nesting) is reconstructed.
      key_value do
        map "base", with: { to: :base_to_kv, from: :base_from_kv }
      end

      def base_to_kv(model, doc)
        base = model.base
        return unless base

        # `base` synthesises a base for a supplement that has none
        # (e.g. a bare "+AMD1:2008" nested in a consolidation): a fake doc whose
        # number equals the supplement's own. It renders nothing and the getter
        # recreates it identically on load, so don't persist it. A standalone
        # supplement ("IEC/FDAM 60038-1") instead moves the real base number into
        # the synthetic base (base.number != own number), which must be kept.
        return if model.synthetic_base? && base.number.to_s == model.number.to_s

        doc.add_child(Lutaml::KeyValue::DataModel::Element.new("base",
                                                              base.to_hash))
      end

      def base_from_kv(model, value)
        return unless value

        # A bare SingleIdentifier here is the synthetic base of a standalone
        # supplement; #synthetic_base? reads that class, so nothing else needs
        # restoring. "number" already holds the supplement number, which is
        # what ensure_base stores on the parse path too.
        model.base = ::Pubid::Iec::Identifier.from_hash(value)
      end

      # Override base getter to ensure it's always created for standalone supplements
      def base
        @base || ensure_base
      end

      # A standalone supplement holds the grammar's layout (base number in
      # `number`, supplement number in `part`) until #ensure_base moves it.
      # Not every construction path goes through one builder branch ("IEC FDAM
      # 60038-1" does not, nor a hand-built Amendment), so these readers make
      # the move before they answer: the result never depends on which reader
      # ran first, and #exclude, which copies through the readers, copies the
      # moved layout. They only TRIGGER the move; they return the stored value.
      def number
        settle_standalone_layout
        super
      end

      def part
        settle_standalone_layout
        super
      end

      # Delegate publisher and copublishers to base whenever there is
      # a base (a supplement carries the publisher of the document it
      # supplements). Checking base first — rather than `@publisher || base` — is
      # required now that the publisher attribute has an IEC default, which would
      # otherwise mask the delegation.
      def publisher
        return @publisher if @ensuring_base

        base ? base.publisher : @publisher
      end

      def copublishers
        return @copublishers if @ensuring_base

        base ? base.copublishers : @copublishers
      end

      # Synthesise the base of a supplement that names none, and return it.
      #
      # A standalone supplement ("IEC/FDAM 60038-1") arrives from the grammar
      # with the BASE number in `number` and the SUPPLEMENT number in `part`.
      # This moves the base number onto a bare SingleIdentifier base and stores
      # the supplement number in `number`, so the attributes hold what they
      # mean — the layout `from_hash` rebuilds from the serialized hash. A
      # supplement with no part (a bare "+AMD1:2008" in a consolidation,
      # "IEC/AMD 1:2017") gets a self-base whose number equals its own; its
      # `number` is left as it is.
      #
      # The base deliberately gets NO typed_stage. A stage without a code is
      # not serialized, so `from_hash` cannot restore one, and a stage set
      # here alone made `parse != from_hash(to_hash)` — `==` compares `base`
      # (`lib/pubid/iec/CLAUDE.md`).
      def ensure_base
        return @base if @base

        # publisher/copublishers read through `base`; this guard makes them
        # read the supplement's own value while the base is being built.
        @ensuring_base = true
        return nil unless publisher && (@number || @part)

        base = SingleIdentifier.new
        base.publisher = publisher
        base.number = @number if @number
        base.subpart = @subpart if @subpart
        base.date = date if date

        if @part
          @number = @part
          @part = nil
        end

        @base = base
      ensure
        @ensuring_base = false
      end

      # True when the base is the bare SingleIdentifier that #ensure_base (or
      # from_hash) synthesised for a standalone supplement; a real attached
      # base is always a concrete type (InternationalStandard, SheetIdentifier
      # …). Read from the base itself, so it survives #exclude, which copies
      # `base` into a new object.
      def synthetic_base?
        base.instance_of?(::Pubid::Iec::SingleIdentifier)
      end

      def to_s(**opts)
        render(format: :human, **opts)
      end

      # MR supplement suffix: `/{type}.{number}.{year}` (e.g. "/amd.1.2016").
      # The MrString renderer recurses into `base` and appends this so the
      # full supplement chain round-trips losslessly (issue #142).
      def mr_supplement_suffix
        segments = []
        segments << mr_type if mr_type
        segments << number&.to_s if number
        segments << date&.year&.to_s if date&.year
        return nil if segments.empty?

        segments.join(".")
      end

      private

      def settle_standalone_layout
        ensure_base if @base.nil? && @part && !@ensuring_base
      end
    end
  end
end
