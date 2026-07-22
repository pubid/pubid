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

        base = ::Pubid::Iec::Identifier.from_hash(value)
        model.base = base

        # A base of the exact SingleIdentifier class is the synthetic self-base
        # of a standalone supplement ("IEC/FDAM 60038-1"); a real attached base
        # is always a concrete type (InternationalStandard, etc.). Re-engage the
        # synthetic-base state so the supplement renders in standalone form
        # (publisher/TYPE base-number-supp-number) instead of attached form.
        if base.instance_of?(::Pubid::Iec::SingleIdentifier)
          model.mark_synthetic_standalone!
        end
      end

      # Re-engage the standalone synthetic-base state on a deserialized
      # supplement. At this point `number` already holds the supplement number
      # (set from the "number" key before "base"), so preserve it as the
      # supplement number and flag the synthetic base.
      def mark_synthetic_standalone!
        @synthetic_base = true
        @supplement_number = @number
      end

      # Override base getter to ensure it's always created for standalone supplements
      def base
        @base || ensure_base
      end

      # Override number getter to trigger swap for standalone supplements
      def number
        # Guard against recursion in ensure_base
        return @number if @ensuring_base

        # For standalone supplements, trigger base creation first
        ensure_base if @synthetic_base.nil? && publisher && part

        if @synthetic_base
          @supplement_number || @number
        else
          super
        end
      end

      # Override part getter for standalone supplements (part becomes nil after swap)
      def part
        # For standalone supplements with synthetic base, part is nil (moved to number)
        if @synthetic_base
          nil
        else
          super
        end
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

      # Ensure we have a base for standalone supplements
      # Creates a synthetic base identifier from supplement attributes if needed
      # Returns the base
      def ensure_base
        return @base if @base

        # Guard flag to prevent recursion in number getter
        @ensuring_base = true

        # For standalone supplements like "IEC/FDAM 60038-1"
        # The supplement number is in the `part` attribute, while `number` is the base number
        # We need to create a synthetic base and use part as the supplement number
        return nil unless publisher && (number || part)

        # Capture original values BEFORE marking as synthetic
        # (otherwise our getters will return swapped values)
        base_number = number
        supplement_number = part

        # NOW mark that this is a synthetic base (after capturing values)
        @synthetic_base = true

        # Use SingleIdentifier which has typed_stage attribute
        base = SingleIdentifier.new
        base.publisher = publisher
        base.number = base_number if base_number
        base.part = nil # Base doesn't have part - part is the supplement number
        base.subpart = subpart if subpart
        base.date = date if date

        # Create typed_stage for the base - use "IS" (International Standard) type
        # not the supplement type
        base.typed_stage = Pubid::Components::TypedStage.new(
          abbr: ["IS"],
          type_code: :is,
          stage_code: :undated,
        )

        @base = base

        # Store the supplement number for getter override
        # The original number is the base number (moved to base)
        # The original part is the supplement number (what we want to return)
        @supplement_number = supplement_number

        @base
      ensure
        @ensuring_base = false
      end

      # Check if this supplement has a synthetic base (created for standalone format)
      def synthetic_base?
        @synthetic_base ||= false
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
    end
  end
end
