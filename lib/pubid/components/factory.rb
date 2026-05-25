# frozen_string_literal: true

require_relative "code"
require_relative "date"
require_relative "edition"
require_relative "language"
require_relative "publisher"

module Pubid
  module Components
    # Coerces loose primitive kwargs (matching pubid 1.x's `Identifier.create`
    # signature) into the structured Component objects pubid 2.x expects.
    #
    # Used by per-flavor `.create` factories.
    module Factory
      # Per-kwarg coercer. Returns a Component, or an Array<Component> for
      # collection attributes such as `languages`.
      COERCERS = {
        publisher: ->(v) { Publisher.new(body: v.to_s) },
        number:    ->(v) { Code.new(value: v.to_s) },
        part:      ->(v) { Code.new(value: v.to_s) },
        subpart:   ->(v) { Code.new(value: v.to_s) },
        year:      ->(v) { Date.new(year: v.to_s) },
        edition:   ->(v) { Edition.new(number: v) },
        language:  ->(v) { [Language.new(code: v.to_s)] },
      }.freeze

      # 1.x kwarg name → 2.x attribute name.
      # Applied after coercion.
      KEY_RENAMES = {
        year: :date,
        language: :languages,
      }.freeze

      # Convert a hash of 1.x-style primitive kwargs into a hash of 2.x-style
      # Component-valued attributes ready for `<IdentifierClass>.new(...)`.
      #
      # Unknown keys pass through unchanged; nil values are dropped.
      def self.from_hash(opts)
        opts.each_with_object({}) do |(k, v), out|
          next if v.nil?

          target = KEY_RENAMES.fetch(k, k)
          coercer = COERCERS[k]
          out[target] = coercer ? coercer.call(v) : v
        end
      end
    end
  end
end
