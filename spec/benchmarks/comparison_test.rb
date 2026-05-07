# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)
require "pubid"
require "benchmark"

# Comparison benchmark: Before vs After optimization
module Pubid
  module Benchmark
    class ComparisonTest
      def initialize
        @iterations = 10_000
      end

      def run_all
        compare_registry_lookup

        compare_hash_operations
      end

      def compare_registry_lookup
        scheme = Pubid::Iso::Scheme.instance
        abbrs = ["WD", "CD", "FDIS", "Amd", "Cor", "PWI", "NP", "IS", "", "FDAM", "CDAMD",
                 "PWI Guide", "NP Guide", "AWI", "DAmd", "DAnnex", "DEx"]
        total_lookups = @iterations * abbrs.size

        # BEFORE: Linear search (using all_typed_stages.detect)
        linear_time = ::Benchmark.realtime do
          @iterations.times do
            abbrs.each do |abbr|
              # Simulate old linear search
              all_stages = scheme.all_typed_stages
              all_stages.detect { |ts| ts.abbr.include?(abbr) }
            end
          end
        end

        # AFTER: Hash-based index lookup
        hash_time = ::Benchmark.realtime do
          @iterations.times do
            abbrs.each { |abbr| scheme.locate_typed_stage_by_abbr(abbr) }
          end
        end

        linear_time / hash_time
        total_lookups / linear_time
        total_lookups / hash_time
      end

      def compare_hash_operations
        ids = [
          Pubid::Iso.parse("ISO 9001:2015"),
          Pubid::Iso.parse("ISO 14001:2015"),
          Pubid::Iso.parse("ISO 27001:2022"),
          Pubid::Iso.parse("ISO/IEC 27001:2022"),
        ]

        # Create a set for membership testing
        set = ids.to_set

        # BEFORE: Without proper hash, set membership is slower
        # Simulate by using == comparisons
        compare_time = ::Benchmark.realtime do
          @iterations.times do
            ids.each do |id|
              # Linear search through array (simulating no hash)
              ids.any?(id)
            end
          end
        end

        # AFTER: With proper hash, set membership is fast
        hash_time = ::Benchmark.realtime do
          @iterations.times do
            ids.each { |id| set.include?(id) }
          end
        end

        compare_time / hash_time
        (@iterations * ids.size) / compare_time
        (@iterations * ids.size) / hash_time
      end
    end
  end
end

# Run comparison benchmarks
Pubid::Benchmark::ComparisonTest.new.run_all
