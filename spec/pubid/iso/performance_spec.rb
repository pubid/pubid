require "spec_helper"
require "benchmark"

RSpec.describe "ISO Parser Performance" do
  let(:simple_id) { "ISO 19115:2003" }
  let(:complex_id) { "ISO/IEC/IEEE 8802-3:2021/FDAM 1" }
  let(:multilevel_id) { "ISO/IEC 13818-1:2015/Amd 3:2016/Cor 1:2017" }
  let(:dir_sup_id) { "ISO/IEC DIR 1 ISO SUP:2022" }

  describe "parse time benchmarks" do
    it "parses simple identifiers efficiently" do
      time = Benchmark.measure do
        1000.times { Pubid::Iso::Identifier.parse(simple_id) }
      end

      (time.real / 1000 * 1000).round(2)

      expect(time.real).to be < 5.0  # <5ms per parse (allows for CI variability)
    end

    it "parses complex identifiers efficiently" do
      time = Benchmark.measure do
        1000.times { Pubid::Iso::Identifier.parse(complex_id) }
      end

      (time.real / 1000 * 1000).round(2)

      expect(time.real).to be < 8.0  # <8ms per parse (allows for CI variability)
    end

    it "parses multi-level identifiers efficiently" do
      time = Benchmark.measure do
        1000.times { Pubid::Iso::Identifier.parse(multilevel_id) }
      end

      (time.real / 1000 * 1000).round(2)

      expect(time.real).to be < 8.0  # <8ms per parse (allows for CI variability)
    end

    it "parses special patterns efficiently" do
      time = Benchmark.measure do
        1000.times { Pubid::Iso::Identifier.parse(dir_sup_id) }
      end

      (time.real / 1000 * 1000).round(2)

      expect(time.real).to be < 5.0  # <5ms per parse (allows for CI variability)
    end
  end

  describe "round-trip performance" do
    it "handles parse -> to_s -> parse efficiently" do
      time = Benchmark.measure do
        500.times do
          id = Pubid::Iso::Identifier.parse(complex_id)
          str = id.to_s
          Pubid::Iso::Identifier.parse(str)
        end
      end

      (time.real / 500 * 1000).round(2)

      expect(time.real).to be < 5.0  # round-trip is 3 operations, needs more time
    end
  end

  describe "memory efficiency" do
    it "does not leak memory on repeated parsing" do
      # Parse same identifier 10,000 times
      # GC should keep memory stable
      10_000.times { Pubid::Iso::Identifier.parse(simple_id) }

      GC.start
      mem_before = `ps -o rss= -p #{Process.pid}`.to_i

      10_000.times { Pubid::Iso::Identifier.parse(simple_id) }

      GC.start
      mem_after = `ps -o rss= -p #{Process.pid}`.to_i

      growth_kb = mem_after - mem_before

      # Allow reasonable growth (<200MB for 20k parses with lutaml-model)
      expect(growth_kb).to be < 200_000
    end
  end
end
