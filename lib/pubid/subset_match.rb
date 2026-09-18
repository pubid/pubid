# frozen_string_literal: true

module Pubid
  # Subset match: `reference === candidate`.
  #
  # The match is true when every part that +reference+ states matches
  # +candidate+. A part that +reference+ leaves nil or empty is a wildcard.
  # relaton uses it to match a partial user reference against index rows, so
  # the caller does not have to name the parts to ignore, as `#matches?`
  # requires.
  #
  #   reference = Pubid::Iso.parse("ISO 9001")
  #   dated = Pubid::Iso.parse("ISO 9001:2015")
  #   reference === dated # => true
  #   dated === reference # => false
  #
  # The operator is NOT symmetric: the receiver is the reference. Ruby calls
  # `===` for `case` and `Enumerable#grep`, so `catalogue.grep(reference)`
  # returns the entries that match the reference. RSpec calls it too: the
  # fuzzy matchers (`include`, `match`, `contain_exactly`, `have_attributes`)
  # and mock argument matchers (`with`) try `expected === actual` when `==` is
  # false. So an expectation with a partial identifier on the expected side
  # passes against a fuller one. Use `eq` when a spec needs exact equality.
  #
  # Rules:
  # - The two objects must be instances of the same class. A reference never
  #   falls back to the base document of a wrapper: `BS 7273-4` does not match
  #   `BS 7273-4:2015+A1:2021`.
  # - A default value is stated. `ISO 9001` means the published stage, so it
  #   does not match `ISO/DIS 9001`.
  # - A collection matches by position, and the reference can be shorter:
  #   `ISO/IEC 9001` matches `ISO/IEC/IEEE 9001`, `ISO/IEEE 9001` does not.
  # - A STRICT attribute is exempt from both wildcards: the reference always
  #   states it, so a nil value means "this document has none" and a stated
  #   collection is not a prefix. A class declares one with `subset_strict`.
  # - A reference that sets +all_parts+ matches every part of the document:
  #   `part`, `parts`, `subpart` and `all_parts` itself are skipped.
  # - A nested identifier or component that includes this module is compared
  #   with its own `===`. Any other value is compared with `==`.
  # - `#==` does not change. An error from an attribute reader propagates.
  #
  # The match walks the attributes of the objects, not their `to_hash`, so a
  # class can change the rule for its own attributes:
  # - `subset_strict` names attributes the reference always states, for
  #   example an ECMA `part` or an ETSI `parts` list.
  # - `self.subset_ignored_attributes` names attributes that `===` skips, for
  #   example a value that `from_hash` cannot restore (NIST build artifacts).
  # - `#subset_attribute_match?` decides one attribute; an override calls
  #   `super` for the attributes it does not handle.
  #
  # Every identifier and every component class includes this module. A new
  # component class must include it too; `spec/pubid/subset_match_spec.rb`
  # fails otherwise.
  module SubsetMatch
    # The parts of a document, which a reference with +all_parts+ does not
    # restrict. `all_parts` itself is here so that an all-parts reference
    # matches a candidate that states one part.
    ALL_PARTS_ATTRIBUTES = %i[part parts subpart all_parts].freeze

    def self.included(base)
      base.extend(ClassMethods)
    end

    # Class-level hooks.
    module ClassMethods
      # Declare attributes that the reference always states. A nil or empty
      # value then means "this document has none", and a stated collection
      # must match in full instead of as a prefix.
      #
      #   class Pubid::Ecma::Identifier < Pubid::Identifier
      #     subset_strict :part
      #   end
      #
      # A caller that does want every part of a document sets `all_parts` on
      # the reference, or keeps using `#matches?(other, ignore:)`.
      #
      # @param names [Array<Symbol>] the attributes of this class
      # @return [Array<Symbol>] the attributes this class itself declares
      def subset_strict(*names)
        @subset_strict_own = subset_strict_own | names.map(&:to_sym)
      end

      # @return [Array<Symbol>] the attributes that `===` compares exactly,
      #   this class's own declarations and every one it inherits
      def subset_strict_attributes
        inherited = if superclass.respond_to?(:subset_strict_attributes)
                      superclass.subset_strict_attributes
                    else
                      []
                    end
        inherited | subset_strict_own
      end

      # @return [Array<Symbol>] the attributes that `===` skips
      def subset_ignored_attributes
        []
      end

      private

      def subset_strict_own
        @subset_strict_own ||= []
      end
    end

    # @param other [Object] the candidate
    # @return [Boolean] true when +other+ holds every part that self states
    def ===(other)
      return true if equal?(other)
      return false unless other.instance_of?(self.class)

      ignored = subset_skipped_attributes
      self.class.attributes.each_key.all? do |name|
        ignored.include?(name) || subset_attribute_match?(
          name, public_send(name), other.public_send(name)
        )
      end
    end

    # @return [Array<Symbol>] the attributes this match does not compare
    def subset_skipped_attributes
      ignored = self.class.subset_ignored_attributes
      return ignored unless subset_all_parts_wildcard?

      ignored | ALL_PARTS_ATTRIBUTES
    end

    # True when the reference asks for every part of the document.
    # `Pubid::Identifier` overrides it to read its +all_parts+ attribute; a
    # component never holds a document's parts.
    # @return [Boolean]
    def subset_all_parts_wildcard?
      false
    end

    # @param name [Symbol] the attribute name
    # @param mine [Object] the value of the reference
    # @param theirs [Object] the value of the candidate
    # @return [Boolean] true when +theirs+ satisfies +mine+
    def subset_attribute_match?(name, mine, theirs)
      return SubsetMatch.exact_match?(mine, theirs) if
        self.class.subset_strict_attributes.include?(name)

      SubsetMatch.value_match?(mine, theirs)
    end

    # @return [Boolean] true when +theirs+ satisfies the reference value +mine+
    def self.value_match?(mine, theirs)
      return true if blank?(mine)

      case mine
      when ::Array then collection_match?(mine, theirs)
      when SubsetMatch then mine === theirs
      else mine == theirs
      end
    end

    # A strict attribute is compared exactly: nil and empty are the same
    # value, so a parsed identifier still matches the index row that
    # `from_hash` rebuilds from a hash that dropped the empty attribute; a
    # collection must match in full, element by element.
    #
    # Exactness composes rather than flattening: a nested value that
    # includes this module is matched in BOTH directions with its own
    # `===`, so the class that owns it keeps its rule. A plain `==` would
    # override it — `Components::TypedStage` ignores `original_abbr`
    # (the input spelling, `Amd` against `AMD`), and CEN/CENELEC declares
    # `typed_stage` strict.
    # @return [Boolean]
    def self.exact_match?(mine, theirs)
      return true if blank?(mine) && blank?(theirs)

      case mine
      when ::Array then exact_collection_match?(mine, theirs)
      when SubsetMatch then mine === theirs && theirs === mine
      else mine == theirs
      end
    end

    # A strict collection matches in full, never as a prefix.
    def self.exact_collection_match?(mine, theirs)
      theirs.is_a?(::Array) && mine.size == theirs.size &&
        mine.each_with_index.all? { |value, i| exact_match?(value, theirs[i]) }
    end

    # A shorter reference collection matches the leading elements.
    def self.collection_match?(mine, theirs)
      theirs.is_a?(::Array) && mine.size <= theirs.size &&
        mine.each_with_index.all? { |value, i| value_match?(value, theirs[i]) }
    end

    # @return [Boolean] true for nil and for an empty string or collection
    def self.blank?(value)
      value.nil? || Lutaml::Model::Utils.empty?(value)
    end
  end
end
