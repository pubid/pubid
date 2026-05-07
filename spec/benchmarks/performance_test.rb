# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)
require "pubid"
require "benchmark"

# Performance benchmark for PubID v2 optimizations
module Pubid
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
        benchmark_parsing

        benchmark_registry_lookup

        benchmark_hash_operations

        benchmark_set_operations
      end

      def benchmark_parsing
        # Warm up JIT - only ISO for now
        10.times { ISO_IDENTIFIERS.each { |id| Pubid::Iso.parse(id) } }

        # ISO parsing
        iso_time = ::Benchmark.realtime do
          @iterations.times do
            ISO_IDENTIFIERS.each { |id| Pubid::Iso.parse(id) }
          end
        end

        (@iterations * ISO_IDENTIFIERS.size) / iso_time

        # NIST parsing - skip if identifiers can't be parsed
        begin
          # Test NIST identifiers first
          valid_nist = []
          NIST_IDENTIFIERS.each do |id|
            Pubid::Nist.parse(id)
            valid_nist << id
          rescue Parslet::ParseFailed
            # Skip unparsable identifiers
            next
          end

          if valid_nist.any?
            # Warm up
            10.times { valid_nist.each { |id| Pubid::Nist.parse(id) } }

            nist_time = ::Benchmark.realtime do
              @iterations.times do
                valid_nist.each { |id| Pubid::Nist.parse(id) }
              end
            end

            (@iterations * valid_nist.size) / nist_time

          end
        rescue StandardError
        end
      end

      def benchmark_registry_lookup
        scheme = Pubid::Iso::Scheme.instance

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

        total_lookups / lookup_time
      end

      def benchmark_hash_operations
        id1 = Pubid::Iso.parse("ISO 9001:2015")
        id2 = Pubid::Iso.parse("ISO 14001:2015")
        id3 = Pubid::Iso.parse("ISO 9001:2015")

        # Warm up
        100.times { [id1, id2, id3].each(&:hash) }

        hash_time = ::Benchmark.realtime do
          @iterations.times do
            [id1, id2, id3].each(&:hash)
          end
        end

        (@iterations * 3) / hash_time
      end

      def benchmark_set_operations
        ids = ISO_IDENTIFIERS.map { |id| Pubid::Iso.parse(id) }
        set = ids.to_set

        # Warm up
        100.times { set.include?(ids.first) }

        # Set membership test
        membership_time = ::Benchmark.realtime do
          @iterations.times do
            ids.each { |id| set.include?(id) }
          end
        end

        (@iterations * ids.size) / membership_time

        # Set union
        set2 = ids.take(5).to_set
        union_time = ::Benchmark.realtime do
          @iterations.times { set | set2 }
        end

        @iterations / union_time
      end
    end
  end
end

# Run benchmarks
Pubid::Benchmark::PerformanceTest.new.run_all
