# frozen_string_literal: true

module Pubid
  # Attributes that are not part of an identifier's identity: `==`, `eql?`,
  # `hash` and the subset match `===` skip them.
  #
  # The main case is a spelling-only value: the input wrote the same
  # document in another way (`Rev. 5` or `r5`, `(E)` or `(en)`, a
  # different separator). It renders the original spelling again, so
  # `to_s` and `to_hash` keep it, but a search must find the document
  # whatever the spelling. Every facet of the pubid-scheme URN (the
  # trailing `f` group) is such a value; `spec/pubid/pubid_urn_contract_spec.rb`
  # checks that an id whose facets are cut is still `==` and `===` to the
  # original (issue #656).
  #
  #   class Pubid::Components::Language < Lutaml::Model::Serializable
  #     include ::Pubid::EqualityIgnored
  #     equality_ignored :original_code
  #   end
  #
  # The declaration goes on the class that owns the attribute, and a
  # subclass inherits it. A class that writes its own `==` must skip
  # `equality_ignored_attributes` there too; the subset match reads the
  # list itself (`SubsetMatch#subset_skipped_attributes`).
  #
  # Include it explicitly. There is no `inherited` or `prepend` hook, per
  # the annotated-rendering lesson in CLAUDE.md.
  module EqualityIgnored
    def self.included(base)
      base.extend(ClassMethods)
    end

    # Class-level declaration.
    module ClassMethods
      # @param names [Array<Symbol>] attributes of this class
      # @return [Array<Symbol>] the attributes this class itself declares
      def equality_ignored(*names)
        @equality_ignored_own = equality_ignored_own | names.map(&:to_sym)
      end

      # @return [Array<Symbol>] this class's declarations and every one it
      #   inherits
      def equality_ignored_attributes
        inherited = if superclass.respond_to?(:equality_ignored_attributes)
                      superclass.equality_ignored_attributes
                    else
                      []
                    end
        inherited | equality_ignored_own
      end

      private

      def equality_ignored_own
        @equality_ignored_own ||= []
      end
    end

    # A value with no identity left: a component whose every attribute is
    # ignored or empty. "ISO 22610:2006 Ed" holds an Edition with only the
    # spelling "Ed"; with the facets cut, the edition is nil. The two must
    # compare equal, so `==` and `===` read such a value as nil.
    #
    # @return [Boolean]
    def self.identity_blank?(value)
      value.respond_to?(:identity_blank?) && value.identity_blank?
    end

    # The attributes this instance does not compare: the class's list. A
    # class overrides it when a declared attribute carries identity in some
    # instances (Components::Language: an unmapped one-letter code has no
    # +code+, so its spelling is the language).
    #
    # @return [Array<Symbol>]
    def equality_ignored_attributes
      self.class.equality_ignored_attributes
    end

    # @return [Boolean] true when every attribute that is not ignored is
    #   nil or empty (never true for an instance that ignores nothing)
    def identity_blank?
      ignored = equality_ignored_attributes
      return false if ignored.empty?

      (self.class.attributes.keys - ignored).all? do |name|
        SubsetMatch.blank?(public_send(name))
      end
    end

    # lutaml's attribute walk, without the ignored attributes, and with a
    # value that has no identity left read as nil.
    def ==(other)
      return true if equal?(other)
      return false unless other.instance_of?(self.class)

      # Only what both sides ignore, so the comparison stays symmetric.
      ignored = equality_ignored_attributes & other.equality_ignored_attributes
      self.class.attributes.each_key.all? do |name|
        ignored.include?(name) || identity_equal?(name, other)
      end
    end

    # @return [Boolean] true when attribute +name+ of self and +other+ is
    #   the same, a value with no identity left read as nil
    def identity_equal?(name, other)
      EqualityIgnored.identity_value(public_send(name)) ==
        EqualityIgnored.identity_value(other.public_send(name))
    end

    # @return [Object, nil] nil for a value with no identity left, else
    #   the value itself
    def self.identity_value(value)
      identity_blank?(value) ? nil : value
    end

    # The second parameter is lutaml's (see Pubid::Identifier#eql?).
    def eql?(other, _compared_objects = nil)
      self == other
    end

    def hash
      ignored = equality_ignored_attributes
      return super if ignored.empty?

      names = self.class.attributes.keys - ignored
      [self.class, *names.map { |name| public_send(name) }].hash
    end
  end
end
