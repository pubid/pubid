# frozen_string_literal: true

require "yaml"

module Pubid
  module Iho
    # The S-4 reserved specification registry
    # (data/iho/s4-reserved-specs.yaml): the "NOT CURRENTLY USED"
    # numbers, edition-keyed (owner rulings of 2026-11-11, issue #691).
    # {Reserved?} answers from this table — a reserved number parses and
    # resolves AS RESERVED, never invalid.
    module ReservedSpecs
      DATA_PATH =
        File.expand_path("../../../data/iho/s4-reserved-specs.yaml", __dir__)

      class << self
        # True when the part-lettered spec number is reserved in the
        # given S-4 edition. An edition-less reference is reserved when
        # ANY seeded edition reserves the number: the number is out of
        # circulation in every edition that names it.
        def reserved?(edition, part, spec)
          return false unless part && spec

          if edition
            specs_for(edition, part).include?(spec)
          else
            registry.values.any? do |parts|
              specs_for_parts(parts, part).include?(spec)
            end
          end
        end

        # The edition-keyed registry: edition => part letter => spec
        # numbers.
        def registry
          @registry ||=
            (YAML.safe_load_file(DATA_PATH) || {}).transform_values do |parts|
              parts.transform_values { |specs| Array(specs) }
            end
        end

        private

        def specs_for(edition, part)
          specs_for_parts(registry.fetch(edition, {}), part)
        end

        def specs_for_parts(parts, part)
          parts.fetch(part, [])
        end
      end
    end
  end
end
