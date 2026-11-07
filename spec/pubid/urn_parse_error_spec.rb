# frozen_string_literal: true

require "spec_helper"

# Populate the registry at collection time so the per-flavor examples below are
# generated for every registered flavor.
Pubid.eager_load_flavors!

# Issue #670, the per-flavor half. `Pubid.parse_urn` wraps every decode
# failure as a pubid error, but relaton and the flavor modules call a
# flavor's `UrnParser.parse` (and `Pubid::Iso.parse_urn` /
# `Pubid::Iec.parse_urn`) directly. Those entry points leaked raw
# `ArgumentError` for invalid encoding bytes and for ISO's namespace check,
# `NoMethodError` for nil, and `NoMethodError` / `IndexError` for a
# malformed body in 11 flavors. The contract here:
#
#   non-String              -> Pubid::Errors::InvalidInputError
#   invalid encoding bytes  -> Pubid::Errors::UrnParseError
#   wrong or malformed URN  -> Pubid::Errors::UrnParseError (a pubid error)
#
# Registry-driven: a new flavor with a UrnParser is covered with no edit.
module UrnParseErrorContract
  BAD_URN_BYTES = (+"urn:x:\xFF").force_encoding(Encoding::UTF_8).freeze
  MALFORMED_BODIES = ["", ":", "::", "x", "x:", ":x", "-", "~"].freeze
  ISO_BAD_URNS = ["", "urn:iec:std:iec:60445", "urn:iso:iso:9001",
                  "urn:iso:std:", "urn:iso:std:iso"].freeze
  IEC_BAD_URNS = ["", "urn:iso:std:iso:1", "urn:iec:std:"].freeze
  WRONG_URNS = ["", "urn:zz-not-a-namespace:1"].freeze

  def self.modules
    Pubid::Registry.flavor_names
      .map { |name| Pubid::Registry.get(name) }
      .uniq
      .select { |mod| mod.const_defined?(:UrnParser, false) }
  end

  # The namespace a parser strips. ISO and IEC parsers do not inherit
  # Base, so they have no flavor_name; theirs is "urn:<flavor>:std:".
  def self.namespace(mod, parser)
    if parser < Pubid::UrnParser::Base
      parser.new.send(:flavor_name)
    else
      "#{mod.name.split('::').last.downcase}:std"
    end
  end

  # :parsed, :pubid_error, or the leaked error itself propagates.
  def self.outcome(parser, urn)
    parser.parse(urn)
    :parsed
  rescue Pubid::Errors::Error
    :pubid_error
  end
end

RSpec.describe "URN parse failure contract (cross-flavor)" do
  it "covers the flavors with a URN parser" do
    expect(UrnParseErrorContract.modules)
      .to include(Pubid::Iso, Pubid::Iec, Pubid::Etsi)
  end

  UrnParseErrorContract.modules.each do |mod|
    describe "#{mod}::UrnParser.parse" do
      let(:parser) { mod.const_get(:UrnParser) }
      let(:bad_bytes) { UrnParseErrorContract::BAD_URN_BYTES }

      it "raises InvalidInputError for nil" do
        expect { parser.parse(nil) }
          .to raise_error(Pubid::Errors::InvalidInputError, /must be a String/)
      end

      it "raises UrnParseError for invalid encoding bytes" do
        expect { parser.parse(bad_bytes) }
          .to raise_error(Pubid::Errors::UrnParseError, /invalid encoding/)
      end

      it "raises UrnParseError for binary non-UTF-8 bytes" do
        expect { parser.parse(bad_bytes.b) }
          .to raise_error(Pubid::Errors::UrnParseError, /invalid encoding/)
      end

      UrnParseErrorContract::WRONG_URNS.each do |bad|
        it "raises a pubid error for #{bad.inspect}" do
          expect { parser.parse(bad) }.to raise_error(Pubid::Errors::Error)
        end
      end

      # A body may legitimately parse (adobe and iana take any slug), so
      # the contract is "an identifier or a pubid error"; any other class
      # propagates out of `outcome` and fails the example.
      UrnParseErrorContract::MALFORMED_BODIES.each do |body|
        it "raises only a pubid error for the body #{body.inspect}" do
          namespace = UrnParseErrorContract.namespace(mod, parser)
          outcome = UrnParseErrorContract
            .outcome(parser, "urn:#{namespace}:#{body}")
          expect(outcome).to eq(:parsed).or eq(:pubid_error)
        end
      end
    end
  end

  describe "ISO" do
    UrnParseErrorContract::ISO_BAD_URNS.each do |bad|
      it "Pubid::Iso.parse_urn raises UrnParseError for #{bad.inspect}" do
        expect { Pubid::Iso.parse_urn(bad) }
          .to raise_error(Pubid::Errors::UrnParseError)
      end
    end
  end

  describe "IEC" do
    UrnParseErrorContract::IEC_BAD_URNS.each do |bad|
      it "Pubid::Iec.parse_urn raises UrnParseError for #{bad.inspect}" do
        expect { Pubid::Iec.parse_urn(bad) }
          .to raise_error(Pubid::Errors::UrnParseError)
      end
    end
  end

  describe "a URN in another encoding or as binary ASCII" do
    let(:urn) { Pubid::Iso.parse("ISO 9001:2015").to_urn }

    it "accepts ASCII bytes tagged binary" do
      expect(Pubid::Iso::UrnParser.parse(urn.b).to_urn).to eq(urn)
      expect(Pubid.parse_urn(urn.b).to_urn).to eq(urn)
    end

    it "converts an ISO-8859-1 URN" do
      latin1 = urn.encode(Encoding::ISO_8859_1)
      expect(Pubid::Iso::UrnParser.parse(latin1).to_urn).to eq(urn)
      expect(Pubid.parse_urn(latin1).to_urn).to eq(urn)
    end

    it "converts a UTF-16LE URN on the shared base" do
      etsi = Pubid::Etsi.parse("ETSI EN 300 175-1 V2.6.1 (2015-07)").to_urn
      utf16 = etsi.encode(Encoding::UTF_16LE)
      expect(Pubid::Etsi::UrnParser.parse(utf16).to_urn).to eq(etsi)
    end
  end

  # The wrap keeps the raw error as the cause, so a parser defect is still
  # visible to whoever debugs it.
  it "keeps the raw error as the cause of a wrapped failure" do
    expect { Pubid::Etsi::UrnParser.parse("urn:etsi:") }
      .to raise_error(Pubid::Errors::UrnParseError) { |e|
        expect(e.cause).to be_a(StandardError)
        expect(e.cause).not_to be_a(Pubid::Errors::Error)
      }
  end
end
