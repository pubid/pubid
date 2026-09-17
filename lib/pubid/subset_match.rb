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
  # - A nested identifier or component that includes this module is compared
  #   with its own `===`. Any other value is compared with `==`.
  # - `#==` does not change. An error from an attribute reader propagates.
  #
  # The match walks the attributes of the objects, not their `to_hash`, so a
  # class can change the rule for its own attributes:
  # - `self.subset_ignored_attributes` names attributes that `===` skips, for
  #   example a value that `from_hash` cannot restore (NIST build artifacts).
  # - `#subset_attribute_match?` decides one attribute; an override calls
  #   `super` for the attributes it does not handle.
  #
  # Every identifier and every component class includes this module. A new
  # component class must include it too; `spec/pubid/subset_match_spec.rb`
  # fails otherwise.
  module SubsetMatch
    def self.included(base)
      base.extend(ClassMethods)
    end

    # Class-level hooks.
    module ClassMethods
      # @return [Array<Symbol>] the attributes that `===` skips
      def subset_ignored_attributes
        []
      end
    end

    # @param other [Object] the candidate
    # @return [Boolean] true when +other+ holds every part that self states
    def ===(other)
      return true if equal?(other)
      return false unless other.instance_of?(self.class)

      ignored = self.class.subset_ignored_attributes
      self.class.attributes.each_key.all? do |name|
        ignored.include?(name) ||
          subset_attribute_match?(name, public_send(name),
                                  other.public_send(name))
      end
    end

    # @param _name [Symbol] the attribute name
    # @param mine [Object] the value of the reference
    # @param theirs [Object] the value of the candidate
    # @return [Boolean] true when +theirs+ satisfies +mine+
    def subset_attribute_match?(_name, mine, theirs)
      SubsetMatch.value_match?(mine, theirs)
    end

    # @return [Boolean] true when +theirs+ satisfies the reference value +mine+
    def self.value_match?(mine, theirs)
      return true if mine.nil? || Lutaml::Model::Utils.empty?(mine)

      case mine
      when ::Array then collection_match?(mine, theirs)
      when SubsetMatch then mine === theirs
      else mine == theirs
      end
    end

    # A shorter reference collection matches the leading elements.
    def self.collection_match?(mine, theirs)
      theirs.is_a?(::Array) && mine.size <= theirs.size &&
        mine.each_with_index.all? { |value, i| value_match?(value, theirs[i]) }
    end
  end
end
