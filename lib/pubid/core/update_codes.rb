# frozen_string_literal: true

require "yaml"
require "pathname"

module Pubid
  module Core
    # Centralized update_codes loader and applier.
    #
    # Reads YAML files from data/{flavor}/update_codes.yaml and applies
    # substitution patterns to normalize malformed identifiers BEFORE parsing.
    #
    # Each flavor's parse entry point calls UpdateCodes.apply(code, :flavor)
    # before any parser-specific preprocessing.
    #
    # Format in YAML files:
    #   plain string match: "IEC 60285-/1:1989"  ->  "IEC 60285-1:1989"
    #   regex match:        "/^NBS CIRC sup$/"  ->  "NBS CIRC 24e7sup"
    #
    # Plain strings are converted to anchored regexps at load time.
    # Regex patterns are wrapped in /.../ slashes in the YAML.
    class UpdateCodes
      DATA_DIR = Pathname.new(__dir__).join("../../../data").expand_path

      class << self
        # Apply update_codes substitutions for the given flavor.
        #
        # @param code [String] identifier string to normalize
        # @param flavor [Symbol, String] flavor name (e.g., :iso, :iec, :ieee, :nist)
        # @return [String] normalized identifier string
        def apply(code, flavor)
          codes = for_flavor(flavor)
          return code if codes.nil? || codes.empty?

          stripped = code.to_s.strip
          codes.each do |pattern, replacement|
            stripped = stripped.gsub(pattern, replacement)
          end
          stripped
        end

        # Get the compiled update_codes hash for a flavor (cached).
        #
        # @param flavor [Symbol, String] flavor name
        # @return [Hash, nil] compiled { Regexp => String } map, or nil if file doesn't exist
        def for_flavor(flavor)
          @cache ||= {}
          flavor_key = flavor.to_s.to_sym
          @cache[flavor_key] ||= load_yaml(flavor_key)
        end

        # Available flavors that have update_codes files.
        #
        # @return [Array<Symbol>] list of flavors with data/{flavor}/update_codes.yaml
        def flavors
          @flavors ||= DATA_DIR.children.select(&:directory?).map do |dir|
            dir.basename.to_s.to_sym
          end.select { |f| (DATA_DIR / f.to_s / "update_codes.yaml").exist? }
        end

        private

        # Load and compile YAML patterns into frozen Regexp=>String map.
        def load_yaml(flavor)
          yaml_path = DATA_DIR / flavor.to_s / "update_codes.yaml"
          return nil unless yaml_path.exist?

          raw = YAML.safe_load_file(yaml_path) || {}
          compiled = {}
          raw.each do |from, to|
            if from.match?(%r{^/.*/$})
              compiled[Regexp.new(from[1..-2])] = to
            else
              compiled[/^#{Regexp.escape(from)}$/] = to
            end
          end
          compiled.freeze
        end
      end
    end
  end
end
