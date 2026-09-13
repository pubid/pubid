# frozen_string_literal: true

require "spec_helper"

# Populate the registry at collection time so the per-flavor examples below are
# generated for every registered flavor (flavor_names is empty until loaded).
Pubid.eager_load_flavors!

# `Pubid.from_hash` is the hash counterpart of `Pubid.parse`: it builds the
# concrete identifier class from a serialized identifier — typically the `:id`
# of a relaton-data `index-v2.yaml` row — without the caller naming the
# flavor. The `_type` key ("pubid:<flavor>:<type>") carries the routing
# information.
RSpec.describe "Pubid.from_hash" do
  # Registry flavor name => one identifier of that flavor. The meta-examples
  # below fail when a flavor is registered without an entry, so the table
  # cannot go stale silently.
  FROM_HASH_SAMPLES = {
    "3gpp" => "TS 23.207:REL-4/2.0.0",
    "adobe" => "Adobe TN 5014",
    "amca" => "ANSI/AMCA Standard 99-25",
    "ansi" => "ANSI 802.3-2012",
    "api" => "API BULL 11L2",
    "ashrae" => "ASHRAE 55-2017",
    "asme" => "ASME B18.3-2012",
    "astm" => "ASTM ADJD2148",
    "bipm" => "CCTF REC 2 (2012)",
    "bsi" => "BS 5839-1:2017",
    "calconnect" => "CC 11001:2024",
    "ccsds" => "CCSDS 100.0-G-1",
    "cen" => "EN 50128:2011",
    "cen_cenelec" => "EN ISO 14090:2019",
    "cie" => "CIE 198:2011",
    "csa" => "CAN/CSA-A123.2-03 (R2023)",
    "doi" => "doi:10.1000/182",
    "easc" => "ПМГ В 31-2001",
    "ecma" => "ECMA-434 ed1",
    "etsi" => "ETSI EG 200 053 V1.5.1 (2004-06)",
    "gb" => "JB/T 13368-2018",
    "gost" => "GOST R 34.12-2015",
    "iala" => "IALA S1070",
    "iana" => "IANA _6lowpan-parameters",
    "idf" => "IDF 1:2010",
    "iec" => "CISPR 12:2007/AMD1:2009",
    "ieee" => "IEEE 802.3-2018",
    "ietf" => "RFC 2119",
    "iho" => "IHO B-1 1.0.0",
    "isbn" => "ISBN 0-306-40615-2",
    "iso" => "ISO 9001:2015",
    "itu" => "ITU-T G.711",
    "jcgm" => "JCGM 100:2008/Amd 1",
    "jis" => "JIS A 0001:1999",
    "nist" => "NIST IR 88-4008",
    "oasis" => "OASIS EDXL",
    "ogc" => "01-009a",
    "oiml" => "OIML R 138",
    "omg" => "OMG AMI4CCM 1.0",
    "plateau" => "PLATEAU Handbook #00",
    "sae" => "SAE J1939",
    "un" => "A/RES/78/1",
    "w3c" => "W3C WD-charmod-19991129",
    "xsf" => "XEP 0001",
  }.freeze

  it "has a sample for every registered flavor" do
    expect(Pubid::Registry.flavor_names - FROM_HASH_SAMPLES.keys).to eq([])
  end

  it "has no sample for an unregistered flavor" do
    expect(FROM_HASH_SAMPLES.keys - Pubid::Registry.flavor_names).to eq([])
  end

  describe "round trip through the serialized hash" do
    FROM_HASH_SAMPLES.each do |flavor, ref|
      context "with #{flavor} (#{ref})" do
        let(:id) { Pubid::Registry.get(flavor).parse(ref) }

        # `==` is deliberately not asserted: a few flavors have known
        # parse-vs-from_hash equality gaps that are not this method's concern.
        # The class and the canonical hash are what an index lookup relies on.
        it "builds the same concrete class with the same hash" do
          built = Pubid.from_hash(id.to_hash)

          expect(built.class).to eq(id.class)
          expect(built.to_hash).to eq(id.to_hash)
        end
      end
    end
  end

  describe "input shapes" do
    it "accepts a Symbol _type key" do
      hash = { _type: "pubid:iso:international-standard", number: "9001" }

      expect(Pubid.from_hash(hash))
        .to be_a(Pubid::Iso::Identifiers::InternationalStandard)
    end

    it "builds a nested identifier of another flavor" do
      built = Pubid.from_hash(
        Pubid::CenCenelec.parse("EN ISO 14090:2019").to_hash,
      )

      expect(built.adopted).to be_a(Pubid::Iso::Identifier)
      expect(built.to_s).to eq("EN ISO 14090:2019")
    end

    it "does not change the hash it gets" do
      hash = Pubid::Iso.parse("ISO 9001:2015").to_hash
      copy = Marshal.load(Marshal.dump(hash))

      Pubid.from_hash(hash)

      expect(hash).to eq(copy)
    end
  end

  describe "invalid input" do
    {
      "a non-Hash" => "ISO 9001",
      "nil" => nil,
      "a hash with no _type" => { "number" => "9001" },
      "an unknown flavor" => { "_type" => "pubid:nope:standard" },
      "an unknown type of a known flavor" => { "_type" => "pubid:iso:nope" },
      "a malformed _type" => { "_type" => "iso" },
    }.each do |label, input|
      it "raises InvalidInputError for #{label}" do
        expect { Pubid.from_hash(input) }
          .to raise_error(Pubid::Errors::InvalidInputError)
      end
    end

    it "raises an error that is rescuable as a pubid error" do
      expect { Pubid.from_hash({}) }.to raise_error(Pubid::Errors::Error)
    end

    it "names the unknown type in the message" do
      expect { Pubid.from_hash({ "_type" => "pubid:iso:nope" }) }
        .to raise_error(/pubid:iso:nope/)
    end
  end

  describe "Pubid::Registry.from_hash" do
    it "delegates to Pubid.from_hash" do
      hash = Pubid::Iso.parse("ISO 9001:2015").to_hash

      expect(Pubid::Registry.from_hash(hash).to_s).to eq("ISO 9001:2015")
    end
  end
end
