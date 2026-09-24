# frozen_string_literal: true

module Pubid
  module Oiml
    module Identifiers
      # OIML sometimes co-publishes a document jointly with another SDO
      # (ISO confirmed so far, per pubid issue #437). The printed reference
      # carries both identifiers, joined by a bare "|":
      #
      #   ISO 4064-1:2024|OIML R 49-1:2024
      #
      # A sibling of SingleIdentifier/SupplementIdentifier — like
      # SupplementIdentifier, it inherits NOTHING from SingleIdentifier and
      # must delegate every identity-bearing reader (code/type/stage/
      # iteration/publisher, the mr_* MR-slug hooks, #root) itself. Without
      # the mr_* delegations, #to_mr_string would silently come out "" (the
      # same filename-collision gap already documented for
      # Amendment/Errata/Annex in lib/pubid/oiml/CLAUDE.md) — this class closes
      # that gap from day one instead of repeating it.
      #
      # `first`/`second` hold the two sides in their original left-to-right
      # print order, each a real, independently-typed `::Pubid::Identifier`
      # (never an attr_accessor — see IEEE's CsaDualPublished for the bug
      # that pattern causes: to_hash/from_hash/#exclude silently drop it).
      # Either side may be OIML; `#oiml_identifier`/`#external_identifier`
      # pick the OIML-typed one out of the pair regardless of order.
      class DualPublished < Identifier
        attribute :first, ::Pubid::Identifier, polymorphic: true
        attribute :second, ::Pubid::Identifier, polymorphic: true

        # Declared locally (rather than left to the inherited default)
        # because Oiml::Identifier's shared key_value block maps "language"
        # and "parsed_format" to real attributes — without a local
        # declaration here, to_hash/from_hash would call a getter/setter
        # this class never defines. Mirrors SingleIdentifier/
        # SupplementIdentifier, which do the same for the same reason.
        attribute :language, :string
        attribute :parsed_format, :string, default: -> { "short" }

        key_value do
          map "first", with: { to: :first_to_kv, from: :first_from_kv }
          map "second", with: { to: :second_to_kv, from: :second_from_kv }
        end

        # Either side may belong to any flavor, so (de)serialization goes
        # through the generic top-level Pubid.from_hash/#to_hash, not the
        # OIML-scoped Identifier.from_hash (which only resolves OIML types).
        def first_to_kv(model, doc)
          value = model.first
          return unless value

          doc.add_child(
            Lutaml::KeyValue::DataModel::Element.new("first", value.to_hash),
          )
        end

        def first_from_kv(model, value)
          model.first = ::Pubid.from_hash(value) if value
        end

        def second_to_kv(model, doc)
          value = model.second
          return unless value

          doc.add_child(
            Lutaml::KeyValue::DataModel::Element.new("second", value.to_hash),
          )
        end

        def second_from_kv(model, value)
          model.second = ::Pubid.from_hash(value) if value
        end

        # The member that belongs to THIS flavor, wherever print order put
        # it. relaton-index sorts on this side's root.number.
        def oiml_identifier
          [first, second].find { |member| member.is_a?(Oiml::Identifier) }
        end

        # The other SDO's identifier for the same document.
        def external_identifier
          [first, second].find { |member| !member.is_a?(Oiml::Identifier) }
        end

        def root
          oiml_identifier ? oiml_identifier.root : self
        end

        def code
          oiml_identifier&.code
        end

        def type
          oiml_identifier&.type
        end

        def stage
          oiml_identifier&.stage
        end

        def iteration
          oiml_identifier&.iteration
        end

        def publisher
          oiml_identifier&.publisher
        end

        def mr_publisher
          oiml_identifier&.mr_publisher
        end

        def mr_type
          oiml_identifier&.mr_type
        end

        def mr_number_with_part
          oiml_identifier&.mr_number_with_part
        end

        def mr_year
          oiml_identifier&.mr_year
        end

        # Splits `identifier` on "|" and, if it looks like an OIML dual-
        # published reference (exactly two non-empty sides, exactly one of
        # which starts with an OIML prefix), parses each side through its
        # own flavor and returns the wrapper. Returns nil for anything else,
        # so the caller (Pubid::Oiml.parse) falls through to the ordinary
        # grammar, which raises the standard Parslet::ParseFailed for a
        # string containing "|" (the grammar defines no rule for it).
        def self.build(identifier)
          sides = split_sides(identifier)
          return nil unless sides

          left, right = parse_sides(*sides)
          return nil unless left && right

          new(first: left, second: right)
        end

        # Two non-empty, stripped sides, or nil if `identifier` isn't
        # shaped like "A|B".
        def self.split_sides(identifier)
          parts = identifier.split("|").map(&:strip)
          return nil unless parts.length == 2
          return nil if parts.any?(&:empty?)

          parts
        end
        private_class_method :split_sides

        # Parses each side through its own flavor, provided exactly one side
        # looks like OIML (by prefix, not position). [nil, nil] otherwise.
        def self.parse_sides(left, right)
          left_is_oiml = Oiml::PREFIXES.any? { |p| left.start_with?(p) }
          right_is_oiml = Oiml::PREFIXES.any? { |p| right.start_with?(p) }
          return [nil, nil] if left_is_oiml == right_is_oiml

          [parse_side(left, oiml: left_is_oiml),
           parse_side(right, oiml: right_is_oiml)]
        end
        private_class_method :parse_sides

        def self.parse_side(str, oiml:)
          oiml ? Oiml.parse(str) : ::Pubid.parse(str)
        rescue Parslet::ParseFailed, Pubid::Errors::InvalidInputError
          nil
        end
        private_class_method :parse_side
      end
    end
  end
end
