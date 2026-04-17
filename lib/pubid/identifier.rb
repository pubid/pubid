require_relative "components/code"
# frozen_string_literal: true
require_relative "components/date"
require_relative "components/edition"
require_relative "components/language"
require_relative "components/locality"
require_relative "components/publisher"
require_relative "components/stage"
require_relative "components/type"
require_relative "serializable"

module Pubid
  # Identifier that supports two-way machine-readable conversion
  class Identifier < Lutaml::Model::Serializable
    include Pubid::Serializable

    attribute :number, Components::Code
    attribute :part, Components::Code
    attribute :subpart, Components::Code
    attribute :stage_iteration, Components::Code
    attribute :date, Components::Date
    attribute :edition, Components::Edition
    attribute :languages, Components::Language, collection: true
    attribute :publisher, Components::Publisher
    attribute :copublishers, Components::Publisher, collection: true
    attribute :type, Components::Type
    attribute :stage, Components::Stage
    attribute :locality, Components::Locality

    # Returns the root/base identifier by traversing supplement chain
    #
    # @return [Identifier] root identifier
    #
    # @example Get root from amendment
    #   id = Pubid::Iso.parse("ISO 9001:2015/Amd 1:2020")
    #   id.root.to_s # => "ISO 9001:2015"
    def root
      return base_identifier.root if respond_to?(:base_identifier) && base_identifier

      self
    end

    # Returns a new identifier without specified attributes
    #
    # @param args [Array<Symbol, Hash>] attributes to exclude
    # @return [Identifier] new identifier without specified attributes
    #
    # @example Exclude year and edition
    #   id = Pubid::Iso.parse("ISO 9001:2015")
    #   id.exclude(:year, :edition)
    #   # => #<Pubid::Iso::Identifiers::InternationalStandard number: 9001>
    #
    # @example Exclude nested attributes
    #   id.exclude({ stage: [:abbr] })
    def exclude(*args)
      nested_exclusions, top_level_exclusions = args.partition do |arg|
        arg.is_a?(Hash)
      end

      nested_exclusions = nested_exclusions.reduce({}, :merge)

      excluded_hash = to_h(include_metadata: false)
        .except(*top_level_exclusions)
        .each_with_object({}) do |(k, v), memo|
          memo[k] = if v.is_a?(Hash) && nested_exclusions.key?(k)
                      v.except(*nested_exclusions[k])
                    else
                      v
                    end
        end

      # Use Deserializer to create new identifier
      Pubid::Serializable.from_h(excluded_hash)
    end

    # Checks if another identifier is newer edition of the same document
    #
    # @param other [Identifier] identifier to compare with
    # @return [Boolean] true if this identifier is newer edition
    #
    # @example Compare editions
    #   id1 = Pubid::Iso.parse("ISO 9001:2015")
    #   id2 = Pubid::Iso.parse("ISO 9001:2019")
    #   id2.new_edition_of?(id1) # => true
    #
    # @raise [ArgumentError] if comparing different documents or undated identifiers
    def new_edition_of?(other)
      # Compare core attributes (publisher, number, part, type)
      core_attrs = %i[publisher number part]
      core_attrs.each do |attr|
        next unless respond_to?(attr) && other.respond_to?(attr)

        if send(attr) != other.send(attr)
          raise ArgumentError,
                "Cannot compare edition: different #{attr}"
        end
      end

      # Check if both have year
      if !respond_to?(:date) || !date || !other.respond_to?(:date) || !other.date
        raise ArgumentError,
              "Cannot compare identifier without date/year"
      end

      # Compare years
      return date.year > other.date.year if date.year != other.date.year

      # Same year, compare edition if present
      if respond_to?(:edition) && other.respond_to?(:edition) && edition && other.edition
        return edition.number > other.edition.number
      end

      false
    end

    # Returns hash code for identifier
    # @return [Integer] hash code
    # @note Memoized for performance
    def hash
      @hash ||= compute_hash
    end

    # Checks equality with another identifier
    # @param other [Object] object to compare with
    # @return [Boolean] true if equal
    def eql?(other)
      return false unless other.is_a?(self.class)

      hash == other.hash && self == other
    end

    private

    # Compute hash code from identifier attributes
    # @return [Integer] hash code
    def compute_hash
      # Use attributes that define identity
      attrs = [
        publisher,
        number,
        part,
        subpart,
        date,
        type,
        stage,
      ]
      attrs.compact.map(&:hash).hash
    end
  end
end
