# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)
require "pubid_new"
require "benchmark"

# Comparison benchmark: Before vs After optimization
module PubidNew
  module Benchmark
    class ComparisonTest
      def initialize
        @iterations = 10_000
      end

      def run_all
        puts "=" * 80
        puts "PubID v2 Optimization Comparison (Before vs After)"
        puts "=" * 80
        puts

        compare_registry_lookup
        puts
        compare_hash_operations
        puts
      end

      def compare_registry_lookup
        puts "1. REGISTRY LOOKUP COMPARISON"
        puts "-" * 80

        scheme = PubidNew::Iso::Scheme.instance
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

        speedup = linear_time / hash_time
        ops_before = total_lookups / linear_time
        ops_after = total_lookups / hash_time

        puts "BEFORE (Linear Search):"
        puts "  Total time: #{linear_time.round(4)}s"
        puts "  Operations: #{total_lookups}"
        puts "  Ops/sec: #{ops_before.round(0)}"
        puts
        puts "AFTER (Hash-based Index):"
        puts "  Total time: #{hash_time.round(4)}s"
        puts "  Operations: #{total_lookups}"
        puts "  Ops/sec: #{ops_after.round(0)}"
        puts
        puts "Speedup: #{speedup.round(2)}x faster"
      end

      def compare_hash_operations
        puts "2. HASH OPERATIONS COMPARISON"
        puts "-" * 80

        ids = [
          PubidNew::Iso.parse("ISO 9001:2015"),
          PubidNew::Iso.parse("ISO 14001:2015"),
          PubidNew::Iso.parse("ISO 27001:2022"),
          PubidNew::Iso.parse("ISO/IEC 27001:2022"),
        ]

        # Create a set for membership testing
        set = ids.to_set

        # BEFORE: Without proper hash, set membership is slower
        # Simulate by using == comparisons
        compare_time = ::Benchmark.realtime do
          @iterations.times do
            ids.each do |id|
              # Linear search through array (simulating no hash)
              ids.any? { |other| other == id }
            end
          end
        end

        # AFTER: With proper hash, set membership is fast
        hash_time = ::Benchmark.realtime do
          @iterations.times do
            ids.each { |id| set.include?(id) }
          end
        end

        speedup = compare_time / hash_time
        ops_before = (@iterations * ids.size) / compare_time
        ops_after = (@iterations * ids.size) / hash_time

        puts "BEFORE (Linear Comparison):"
        puts "  Total time: #{compare_time.round(4)}s"
        puts "  Operations: #{@iterations * ids.size}"
        puts "  Ops/sec: #{ops_before.round(0)}"
        puts
        puts "AFTER (Hash-based Set):"
        puts "  Total time: #{hash_time.round(4)}s"
        puts "  Operations: #{@iterations * ids.size}"
        puts "  Ops/sec: #{ops_after.round(0)}"
        puts
        puts "Speedup: #{speedup.round(2)}x faster"
      end
    end
  end
end

# Run comparison benchmarks
PubidNew::Benchmark::ComparisonTest.new.run_all
