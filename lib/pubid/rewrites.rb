# frozen_string_literal: true

require "yaml"

module Pubid
  # Pre-parse input rewrite map ("legacy code → canonical code").
  #
  # Some flavors accumulated input identifiers that cannot be parsed by the
  # current grammar but must round-trip to a canonical equivalent — e.g.
  # `ISO/TR 17716.2` should be normalized to `ISO/TR 17716`. V1 stored these
  # rewrites in flavor-local YAML files (`gems/pubid-<flavor>/update_codes.yaml`).
  # V2's rewrite of the parser handles many of those cases natively, but a
  # data-driven escape hatch is still needed for irregular legacy strings.
  #
  # Usage:
  #
  #   rewrites = Pubid::Rewrites.load_yaml("path/to/update_codes.yaml")
  #   rewrites.apply("ISO/TR 17716.2")
  #   # => "ISO/TR 17716"
  #
  # Each flavor's entry point (e.g. `Pubid::Iso.parse`) calls `apply` before
  # handing the string to the grammar. If the input is not in the map, it
  # passes through unchanged.
  class Rewrites
    def initialize(map)
      @map = map
    end

    # Load a YAML mapping file. Missing files become empty rewrite sets so
    # callers can wire this up unconditionally without raising on flavors
    # that have no legacy codes.
    #
    # @param path [String] absolute path to the YAML file
    # @return [Pubid::Rewrites]
    def self.load_yaml(path)
      return EMPTY unless path && File.file?(path)

      data = YAML.safe_load(File.read(path)) || {}
      new(data.is_a?(Hash) ? data.dup.freeze : {}.freeze)
    end

    # Returns the canonical form of the given input, or the input unchanged
    # if no rewrite applies. Whitespace is normalized (leading/trailing only)
    # before lookup so cosmetic variations still hit.
    def apply(input)
      return input if input.nil? || @map.empty?

      key = input.to_s.strip
      @map[key] || @map[input.to_s] || input
    end

    def empty?
      @map.empty?
    end

    def keys
      @map.keys
    end

    EMPTY = new({}.freeze)
  end
end
