# frozen_string_literal: true

require "pubid"
module Pubid
  # Every part of one document, e.g. "ISO 9000 (all parts)".
  #
  # The class that includes this module holds part identifiers of one
  # document in `identifiers`, in natural order and without duplicates. A
  # member with no part stands for the whole document; it is permitted only
  # as the sole member.
  #
  # A flavor includes it in a subclass of its own `Identifier`, so the
  # all-parts identifier of a flavor is an identifier of that flavor
  # (`Pubid::Iso::Identifiers::AllParts < Pubid::Iso::Identifier`). The
  # subclass names its own suffix or URN; everything else comes from here.
  # A flavor with no such class uses {Pubid::AllPartsIdentifier}.
  #
  # `==` compares the members. `===` compares the document only: the first
  # member without its part and its edition (see #identity).
  module AllParts
    SUFFIX = " (all parts)"

    # The members hold the whole identity, so the hash carries nothing else.
    # Without the key_value block the serializer reads every inherited
    # attribute, and the derived #number below would be written too.
    def self.included(base)
      base.attribute :identifiers, ::Pubid::Identifier, polymorphic: true,
                                                        collection: true,
                                                        initialize_empty: true
      declare_key_value(base)
      base.extend(ClassMethods)
    end

    # lutaml MERGES a subclass block onto the flavor's own block, so the
    # derived #number below would be written as a top-level key. A no-op
    # converter keeps it out.
    def self.declare_key_value(base)
      base.key_value do
        map "_type", to: :_type
        map "identifiers", to: :identifiers
        map "number", with: { to: :number_to_kv, from: :number_from_kv }
      end
    end

    module ClassMethods
      # lutaml's from_hash builds the object with no attributes and assigns
      # `identifiers` after #initialize, so it normalizes here too.
      def from_hash(data, options = {})
        super.tap do |id|
          id.send(:normalize_identifiers!) if id.is_a?(::Pubid::AllParts)
        end
      end
    end

    def initialize(attrs = {}, options = {})
      super
      normalize_identifiers!
    end

    # The members hold the number, so it is neither written nor read.
    def number_to_kv(_model, _doc); end

    def number_from_kv(_model, _value); end

    # @param other [Object] a candidate identifier
    # @return [Boolean] true when +other+ is any part of the same document,
    #   in any edition
    def ===(other)
      return false unless other.is_a?(::Pubid::Identifier) && identity

      identity === document_of(other)
    end

    # Another all-parts identifier with +other+ added. The receiver does not
    # change.
    # @param other [Pubid::Identifier] a part of the same document, or
    #   another all-parts identifier of it
    # @return [Pubid::Identifier] an all-parts identifier of the same class
    # @raise [ArgumentError] for a different document, an identifier with no
    #   part, or a part that is already a member
    def +(other)
      members = other.is_a?(::Pubid::AllParts) ? other.identifiers : [other]
      members.each { |member| validate_member!(member) }
      self.class.new(identifiers: identifiers + members)
    end

    def to_s(**opts)
      return "" unless identity

      annotate_plain_render(
        "#{identity.to_s(**opts.except(:annotated))}#{self.class::SUFFIX}",
        **opts,
      )
    end

    # The all-parts attributes are empty, so the flavor renderers cannot
    # print it. Only the human form exists yet; `to_mr_string` and `to_slug`
    # come through here and raise too.
    def render(format: :human, **opts)
      return to_s(**opts) if format == :human

      raise NotImplementedError,
            "an all-parts identifier has no #{format} form yet"
    end

    def to_urn
      raise NotImplementedError, "an all-parts identifier has no URN yet"
    end

    def to_all_parts
      self
    end

    def root
      identifiers.first&.root
    end

    # The document number, e.g. "9000". The index keys on it.
    def number
      identity&.number
    end

    # True here and false for every other identifier, so a caller that reads
    # the old flag still works.
    # rubocop:disable Naming/PredicateMethod
    def all_parts
      true
    end
    # rubocop:enable Naming/PredicateMethod

    def all_parts?
      true
    end

    def base_document
      identifiers.first&.base_document
    end

    protected

    # The document: the first member without its part, its subpart and its
    # edition. #document_of reads it from another all-parts identifier, so it
    # is protected and not private.
    # @return [Pubid::Identifier, nil]
    def identity
      first = identifiers.first
      first && document_of(first)
    end

    private

    # The document of +id+: +id+ without its part and its edition.
    def document_of(id)
      return id.identity if id.is_a?(::Pubid::AllParts)

      id.without_parts(*id.class.all_parts_edition_keys)
    end

    def validate_member!(id)
      unless id.is_a?(::Pubid::Identifier)
        raise ArgumentError, "not an identifier: #{id.inspect}"
      end

      raise ArgumentError, "#{id} is not a part of #{self}" unless self === id
      raise ArgumentError, "#{id} has no part" unless id.part?
      return unless identifiers.any? { |member| same_member?(member, id) }

      raise ArgumentError, "#{id} is already a member of #{self}"
    end

    def same_member?(one, other)
      one.normalized_copy == other.normalized_copy
    end

    # Sort, remove duplicates, and drop the whole-document member when a
    # part is present. `==` and `to_hash` depend on this order.
    def normalize_identifiers!
      members = unique_members
      parts = members.select(&:part?)
      self.identifiers = sorted(parts.empty? ? members : parts)
    end

    def unique_members
      identifiers.each_with_object([]) do |member, acc|
        acc << member unless acc.any? { |kept| same_member?(kept, member) }
      end
    end

    # One member needs no sort, and #to_s raises on an abstract class.
    def sorted(members)
      return members if members.size < 2

      members.sort_by { |member| natural_key(member.to_s) }
    end

    # "ISO 9000-10" sorts after "ISO 9000-2".
    def natural_key(str)
      str.split(/(\d+)/).map { |s| s.match?(/\A\d+\z/) ? [0, s.to_i] : [1, s] }
    end
  end
end
