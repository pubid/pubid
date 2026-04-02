# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)
require "pubid_new"
require "benchmark"

# Performance benchmark for PubID v2 optimizations
module PubidNew
  module Benchmark
    class PerformanceTest
      # Test identifiers for parsing
      ISO_IDENTIFIERS = [
        "ISO 9001:2015",
        "ISO/IEC 27001:2022",
        "ISO 14001:2015/Amd 1:2018",
        "ISO/TS 29001:2020",
        "ISO/IEC/IEEE 8802-3:2021",
        "ISO 9001:2015/Amd 1:2016/Cor 1:2017",
        "ISO/DIS 9001",
        "ISO/FDIS 14001",
        "ISO/PAS 28001",
        "ISO 19115:2014",
      ].freeze

      NIST_IDENTIFIERS = [
        "NIST SP 800-53",
        "NIST SP 800-53r5",
        "NIST FIPS 197",
        "NIST SP 800-171r2",
        "NISTIR 7298",
        "NIST SP 800-57r1",
        "NIST SP 800-38A",
        "NIST SP 800-30",
      ].freeze

      def initialize
        @iterations = 1000
      end

      def run_all
        puts "=" * 80
        puts "PubID v2 Performance Benchmark"
        puts "=" * 80
        puts

        benchmark_parsing
        puts
        benchmark_registry_lookup
        puts
        benchmark_hash_operations
        puts
        benchmark_set_operations
        puts
      end

      def benchmark_parsing
        puts "1. PARSING PERFORMANCE (#{@iterations} iterations)"
        puts "-" * 80

        # Warm up JIT - only ISO for now
        10.times { ISO_IDENTIFIERS.each { |id| PubidNew::Iso.parse(id) } }

        # ISO parsing
        iso_time = ::Benchmark.realtime do
          @iterations.times do
            ISO_IDENTIFIERS.each { |id| PubidNew::Iso.parse(id) }
          end
        end

        ops_per_sec = (@iterations * ISO_IDENTIFIERS.size) / iso_time
        puts "ISO Parsing:"
        puts "  Total time: #{iso_time.round(4)}s"
        puts "  Operations: #{@iterations * ISO_IDENTIFIERS.size}"
        puts "  Ops/sec: #{ops_per_sec.round(0)}"
        puts "  Avg parse: #{(iso_time / (@iterations * ISO_IDENTIFIERS.size) * 1_000_000).round(2)}μs"

        # NIST parsing - skip if identifiers can't be parsed
        begin
          # Test NIST identifiers first
          valid_nist = []
          NIST_IDENTIFIERS.each do |id|
            begin
              PubidNew::Nist.parse(id)
              valid_nist << id
            rescue Parslet::ParseFailed
              # Skip unparsable identifiers
              next
            end
          end

          if valid_nist.any?
            # Warm up
            10.times { valid_nist.each { |id| PubidNew::Nist.parse(id) } }

            nist_time = ::Benchmark.realtime do
              @iterations.times do
                valid_nist.each { |id| PubidNew::Nist.parse(id) }
              end
            end

            ops_per_sec = (@iterations * valid_nist.size) / nist_time
            puts "NIST Parsing:"
            puts "  Total time: #{nist_time.round(4)}s"
            puts "  Operations: #{@iterations * valid_nist.size}"
            puts "  Ops/sec: #{ops_per_sec.round(0)}"
            puts "  Avg parse: #{(nist_time / (@iterations * valid_nist.size) * 1_000_000).round(2)}μs"
          else
            puts "NIST Parsing: Skipped (no valid identifiers)"
          end
        rescue => e
          puts "NIST Parsing: Skipped (#{e.message})"
        end
      end

      def benchmark_registry_lookup
        puts "2. REGISTRY LOOKUP PERFORMANCE (#{@iterations} iterations)"
        puts "-" * 80

        scheme = PubidNew::Iso::Scheme.instance

        # Warm up
        100.times { scheme.locate_typed_stage_by_abbr("WD") }

        # Test various abbreviations
        abbrs = ["WD", "CD", "FDIS", "Amd", "Cor", "PWI", "NP", "IS", ""]
        total_lookups = @iterations * abbrs.size

        lookup_time = ::Benchmark.realtime do
          @iterations.times do
            abbrs.each { |abbr| scheme.locate_typed_stage_by_abbr(abbr) }
          end
        end

        ops_per_sec = total_lookups / lookup_time
        puts "Typed Stage Lookup:"
        puts "  Total time: #{lookup_time.round(4)}s"
        puts "  Operations: #{total_lookups}"
        puts "  Ops/sec: #{ops_per_sec.round(0)}"
        puts "  Avg lookup: #{(lookup_time / total_lookups * 1_000_000).round(2)}μs"
      end

      def benchmark_hash_operations
        puts "3. HASH OPERATIONS PERFORMANCE (#{@iterations} iterations)"
        puts "-" * 80

        id1 = PubidNew::Iso.parse("ISO 9001:2015")
        id2 = PubidNew::Iso.parse("ISO 14001:2015")
        id3 = PubidNew::Iso.parse("ISO 9001:2015")

        # Warm up
        100.times { [id1, id2, id3].each(&:hash) }

        hash_time = ::Benchmark.realtime do
          @iterations.times do
            [id1, id2, id3].each(&:hash)
          end
        end

        ops_per_sec = (@iterations * 3) / hash_time
        puts "Hash Code Computation:"
        puts "  Total time: #{hash_time.round(4)}s"
        puts "  Operations: #{@iterations * 3}"
        puts "  Ops/sec: #{ops_per_sec.round(0)}"
        puts "  Avg hash: #{(hash_time / (@iterations * 3) * 1_000_000).round(2)}μs"
      end

      def benchmark_set_operations
        puts "4. SET OPERATIONS PERFORMANCE (#{@iterations} iterations)"
        puts "-" * 80

        ids = ISO_IDENTIFIERS.map { |id| PubidNew::Iso.parse(id) }
        set = ids.to_set

        # Warm up
        100.times { set.include?(ids.first) }

        # Set membership test
        membership_time = ::Benchmark.realtime do
          @iterations.times do
            ids.each { |id| set.include?(id) }
          end
        end

        ops_per_sec = (@iterations * ids.size) / membership_time
        puts "Set Membership:"
        puts "  Total time: #{membership_time.round(4)}s"
        puts "  Operations: #{@iterations * ids.size}"
        puts "  Ops/sec: #{ops_per_sec.round(0)}"
        puts "  Avg lookup: #{(membership_time / (@iterations * ids.size) * 1_000_000).round(2)}μs"

        # Set union
        set2 = ids.take(5).to_set
        union_time = ::Benchmark.realtime do
          @iterations.times { set | set2 }
        end

        ops_per_sec = @iterations / union_time
        puts "Set Union:"
        puts "  Total time: #{union_time.round(4)}s"
        puts "  Operations: #{@iterations}"
        puts "  Ops/sec: #{ops_per_sec.round(0)}"
      end
    end
  end
end

# Run benchmarks
PubidNew::Benchmark::PerformanceTest.new.run_all
