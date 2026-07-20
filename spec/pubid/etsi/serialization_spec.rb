# frozen_string_literal: true

require "spec_helper"
require "pubid/etsi"

RSpec.describe "ETSI serialization" do
  # Round-trip: parse -> to_hash -> from_hash preserves to_s (byte-identical)
  # and is idempotent (from_hash(to_hash).to_hash == to_hash). URN equality is
  # asserted only for standards; supplement #to_urn raises in pristine code
  # (ArgumentError on the zero-padded month) — a pre-existing issue this change
  # does not touch.
  describe "#to_hash / .from_hash round-trip" do
    {
      "ETSI GS ZSM 012 V1.1.1 (2022-12)" => "pubid:etsi:etsi-standard",
      "ETSI GR ZSM 009-3 V1.1.1 (2023-08)" => "pubid:etsi:etsi-standard",
      "ETSI EN 300 019-1-2 V2.2.1 (2014-04)" => "pubid:etsi:etsi-standard",
      "ETSI GTS GSM 02.01 V5.5.0 (1999-01)" => "pubid:etsi:etsi-standard",
      "ETSI ETS 300 011/A1 ed.1 (1994-12)" => "pubid:etsi:amendment",
      "ETSI ETR 053/C1 ed.2 (1997-03)" => "pubid:etsi:corrigendum",
    }.each do |id_str, expected_type|
      describe id_str do
        let(:identifier) { Pubid::Etsi.parse(id_str) }
        let(:hash) { identifier.to_hash }

        it "produces a non-empty hash" do
          expect(hash).to be_a(Hash)
          expect(hash).not_to be_empty
        end

        it "carries the polymorphic _type #{expected_type.inspect}" do
          expect(hash["_type"]).to eq(expected_type)
        end

        it "rebuilds via from_hash and round-trips to_s" do
          rebuilt = Pubid::Etsi::Identifiers::Base.from_hash(hash)
          expect(rebuilt.to_s).to eq(id_str)
        end

        it "is idempotent under from_hash(to_hash)" do
          rebuilt = Pubid::Etsi::Identifiers::Base.from_hash(hash)
          expect(rebuilt.to_hash).to eq(hash)
        end

        it "rebuilds from a symbol-keyed hash equally" do
          symbolized = deep_symbolize(hash)
          rebuilt = Pubid::Etsi::Identifiers::Base.from_hash(symbolized)
          expect(rebuilt.to_hash).to eq(hash)
        end
      end
    end

    it "preserves the URN for standards" do
      %w[
        ETSI\ GS\ ZSM\ 012\ V1.1.1\ (2022-12)
        ETSI\ GTS\ GSM\ 02.01\ V5.5.0\ (1999-01)
      ].each do |id_str|
        id = Pubid::Etsi.parse(id_str)
        rebuilt = Pubid::Etsi::Identifiers::Base.from_hash(id.to_hash)
        expect(rebuilt.to_urn).to eq(id.to_urn)
      end
    end
  end

  # The flattened hash carries only per-instance information: the code component
  # collapses to a bare `number` scalar (plus a `parts` array when present),
  # version flattens to a scalar `version` string with an `is_edition` boolean
  # flag (omitted when false), and date flattens to top-level year/month. The
  # constant publisher ("ETSI") is dropped and reconstructed from the default.
  # A supplement is exactly {_type, number, base:{...}} with no duplicated
  # top-level type/code/version/date. Mirrors ISO/JCGM/OIML.
  describe "compact shape" do
    {
      "ETSI GS ZSM 012 V1.1.1 (2022-12)" => {
        "_type" => "pubid:etsi:etsi-standard", "type" => "GS",
        "number" => "ZSM 012", "version" => "1.1.1",
        "year" => "2022", "month" => "12"
      },
      "ETSI GR ZSM 009-3 V1.1.1 (2023-08)" => {
        "_type" => "pubid:etsi:etsi-standard", "type" => "GR",
        "number" => "ZSM 009", "parts" => ["3"], "version" => "1.1.1",
        "year" => "2023", "month" => "08"
      },
      "ETSI EN 300 019-1-2 V2.2.1 (2014-04)" => {
        "_type" => "pubid:etsi:etsi-standard", "type" => "EN",
        "number" => "300 019", "parts" => %w[1 2], "version" => "2.2.1",
        "year" => "2014", "month" => "04"
      },
      "ETSI GTS GSM 02.01 V5.5.0 (1999-01)" => {
        "_type" => "pubid:etsi:etsi-standard", "type" => "GTS",
        "number" => "GSM 02.01", "version" => "5.5.0",
        "year" => "1999", "month" => "01"
      },
      "ETSI ETS 300 011/A1 ed.1 (1994-12)" => {
        "_type" => "pubid:etsi:amendment", "number" => 1,
        "base" => {
          "_type" => "pubid:etsi:etsi-standard", "type" => "ETS",
          "number" => "300 011", "version" => "1", "is_edition" => true,
          "year" => "1994", "month" => "12"
        }
      },
      "ETSI ETR 053/C1 ed.2 (1997-03)" => {
        "_type" => "pubid:etsi:corrigendum", "number" => 1,
        "base" => {
          "_type" => "pubid:etsi:etsi-standard", "type" => "ETR",
          "number" => "053", "version" => "2", "is_edition" => true,
          "year" => "1997", "month" => "03"
        }
      },
    }.each do |id_str, expected|
      it "#{id_str} serializes to #{expected.inspect}" do
        expect(Pubid::Etsi.parse(id_str).to_hash).to eq(expected)
      end
    end
  end

  # Guards the bare-Base regression: the nested base must rebuild as the
  # concrete EtsiStandard, and the top object as the concrete supplement class.
  describe "concrete class reconstruction" do
    it "rebuilds an amendment's base as EtsiStandard" do
      id = Pubid::Etsi.parse("ETSI ETS 300 011/A1 ed.1 (1994-12)")
      rebuilt = Pubid::Etsi::Identifiers::Base.from_hash(id.to_hash)
      expect(rebuilt).to be_a(Pubid::Etsi::Identifiers::Amendment)
      expect(rebuilt.base).to be_a(Pubid::Etsi::Identifiers::EtsiStandard)
    end
  end

  # Strongest guard: the whole real fixture corpus round-trips through the new
  # compact hash without loss.
  describe "full fixture corpus round-trip" do
    let(:ids) do
      dir = File.expand_path("../../fixtures/etsi/identifiers/pass", __dir__)
      Dir[File.join(dir, "*.txt")].flat_map do |f|
        File.readlines(f, chomp: true)
          .reject { |l| l.strip.empty? || l.start_with?("#", "!") }
      end
    end

    it "loaded a non-trivial number of fixtures" do
      expect(ids.size).to be > 1000
    end

    it "round-trips every fixture id (to_s + idempotent to_hash)" do
      failures = []
      ids.each do |id_str|
        id = Pubid::Etsi.parse(id_str)
        hash = id.to_hash
        rebuilt = Pubid::Etsi::Identifiers::Base.from_hash(hash)
        unless rebuilt.to_s == id_str && rebuilt.to_hash == hash
          failures << id_str
        end
      rescue StandardError => e
        failures << "#{id_str} (#{e.class}: #{e.message})"
      end
      expect(failures).to be_empty,
                          "#{failures.size} failed, e.g.: " \
                          "#{failures.first(5).join(' | ')}"
    end
  end

  def deep_symbolize(obj)
    case obj
    when Hash
      obj.each_with_object({}) { |(k, v), h| h[k.to_sym] = deep_symbolize(v) }
    when Array
      obj.map { |e| deep_symbolize(e) }
    else
      obj
    end
  end
end
