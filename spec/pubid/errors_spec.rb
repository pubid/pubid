# frozen_string_literal: true

require "spec_helper"

# The unified failure contract.
#
# pubid raises exactly three kinds of failure, and every one of them includes
# the marker module `Pubid::Errors::Error`, so `rescue Pubid::Errors::Error`
# is exhaustive:
#
#   Pubid::Errors::ParseError        < ::Parslet::ParseFailed   a printed id
#   Pubid::Errors::UrnParseError     < ::StandardError          a URN
#   Pubid::Errors::InvalidInputError < ::ArgumentError          bad input
#
# The superclasses are the backward-compatibility contract, not an accident:
# every pre-existing `rescue Parslet::ParseFailed` (relaton-cli) and
# `rescue ArgumentError` keeps working by inheritance. A URN failure has no
# parslet cause, so it deliberately does NOT inherit `Parslet::ParseFailed` —
# the marker module, not a shared superclass, is what unifies the two.
RSpec.describe Pubid::Errors do
  describe "the tree" do
    it "unifies every failure under a marker module" do
      Pubid::Nist::Configuration # autoloads ConfigurationError

      expect(Pubid::Errors::Error).to be_a(Module)
      expect(Pubid::Errors::Error).not_to be_a(Class)

      [Pubid::Errors::ParseError,
       Pubid::Errors::UrnParseError,
       Pubid::Errors::InvalidInputError,
       Pubid::Nist::ConfigurationError].each do |klass|
        expect(klass.ancestors).to include(Pubid::Errors::Error)
      end
    end

    it "keeps the pre-existing superclasses, so old rescues still fire" do
      expect(Pubid::Errors::ParseError.superclass)
        .to eq(Parslet::ParseFailed)
      expect(Pubid::Errors::InvalidInputError.superclass).to eq(ArgumentError)
      expect(Pubid::Errors::UrnParseError.superclass).to eq(StandardError)
    end

    it "does not make a URN failure look like a grammar failure" do
      expect(Pubid::Errors::UrnParseError.ancestors)
        .not_to include(Parslet::ParseFailed)
    end

    it "keeps Pubid::UrnParser::Errors::ParseError as an alias" do
      expect(Pubid::UrnParser::Errors::ParseError)
        .to equal(Pubid::Errors::UrnParseError)
    end
  end

  describe Pubid::Errors::ParseError do
    it "accepts parslet's two positional arguments" do
      cause = nil
      begin
        Pubid::Iso::Parser.new.parse("@@@ not an identifier @@@")
      rescue described_class => e
        cause = e.parse_failure_cause
      end

      error = described_class.new("boom", cause)
      expect(error.message).to eq("boom")
      expect(error.parse_failure_cause).to equal(cause)
    end

    it "supports the bare `raise Klass, message` shape" do
      expect { raise described_class, "boom" }
        .to raise_error(described_class, "boom")
    end

    it "carries the input and the flavor" do
      error = described_class.new("boom", nil, input: "X 1", flavor: "iso")
      expect(error.input).to eq("X 1")
      expect(error.flavor).to eq("iso")
    end

    it "defaults input and flavor to nil" do
      error = described_class.new("boom")
      expect(error.input).to be_nil
      expect(error.flavor).to be_nil
      expect(error.parse_failure_cause).to be_nil
    end
  end

  describe "a grammar failure" do
    subject(:error) do
      Pubid::Iso.parse("@@@ not an identifier @@@")
    rescue StandardError => e
      e
    end

    it "is a Pubid::Errors::ParseError" do
      expect(error).to be_a(Pubid::Errors::ParseError)
    end

    it "still satisfies the old rescue" do
      expect(error).to be_a(Parslet::ParseFailed)
    end

    it "is caught by the marker" do
      expect(error).to be_a(Pubid::Errors::Error)
    end

    it "keeps parslet's structured cause, which v1 discarded" do
      expect(error.parse_failure_cause).to be_a(Parslet::Cause)
      expect(error.parse_failure_cause.ascii_tree).to be_a(String)
    end

    it "records the input and the flavor that failed" do
      expect(error.input).to eq("@@@ not an identifier @@@")
      expect(error.flavor).to eq("iso")
    end

    it "chains the original parslet failure as the Ruby cause" do
      expect(error.cause).to be_a(Parslet::ParseFailed)
    end
  end

  describe "#flavor" do
    # The module name and the registered name disagree for two flavors, so
    # deriving the name from the class would hand back something
    # Pubid::Registry.get cannot resolve.
    it "reports the REGISTERED name, not the module name" do
      Pubid.eager_load_flavors!

      expect { Pubid::Tgpp.parse("@@@ nope @@@") }
        .to raise_error(Pubid::Errors::ParseError) { |e|
          expect(e.flavor).to eq("3gpp")
          expect(Pubid::Registry.get(e.flavor)).to eq(Pubid::Tgpp)
        }
    end

    it "picks the canonical name when a flavor is registered twice" do
      Pubid.eager_load_flavors!

      expect { Pubid::CenCenelec.parse("@@@ nope @@@") }
        .to raise_error(Pubid::Errors::ParseError) { |e|
          expect(e.flavor).to eq("cen_cenelec")
        }
    end

    it "reports the delegate that actually ran, not the caller" do
      expect { Pubid::Iso.parse("ITU-T G.711zzz!!!") }
        .to raise_error(Pubid::Errors::ParseError) { |e|
          expect(e.flavor).to eq("itu")
        }
    end
  end

  describe "the double-wrap guard in Pubid::Parser::Grammar" do
    # A grammar nested inside another grammar would otherwise be re-wrapped by
    # the outer one, replacing the inner flavor and input with the outer's.
    # No production path reaches this today, so it is exercised directly.
    let(:inner) do
      Class.new(Pubid::Parser::Grammar) do
        def self.name = "Pubid::Iso::Parser"

        rule(:only_a) { str("a") }
        root(:only_a)
      end
    end

    let(:outer) do
      nested = inner
      Class.new(Pubid::Parser::Grammar) do
        define_method(:parse) { |io, options = {}| nested.new.parse(io, options) }
        def self.name = "Pubid::Iec::Parser"

        rule(:only_b) { str("b") }
        root(:only_b)
      end
    end

    it "keeps the inner failure untouched" do
      expect { outer.new.parse("zzz") }
        .to raise_error(Pubid::Errors::ParseError) { |e|
          expect(e.flavor).to eq("iso")
          expect(e.cause).to be_a(Parslet::ParseFailed)
          expect(e.cause).not_to be_a(Pubid::Errors::ParseError)
        }
    end
  end

  describe "a synthetic failure (no grammar involved)" do
    # CSA rejects comment lines and non-standards before the grammar runs, and
    # ISBN turns a check-digit ArgumentError into a parse failure. These carry
    # no parslet cause, which is why `parse_failure_cause` is documented as
    # nillable.
    it "raises the same class for a CSA comment line" do
      expect { Pubid::Csa.parse("# a comment") }
        .to raise_error(Pubid::Errors::ParseError, /comment/)
    end

    it "raises the same class for a non-CSA standard" do
      expect { Pubid::Csa.parse("CSA Learning something") }
        .to raise_error(Pubid::Errors::ParseError, /Not a CSA standard/)
    end

    it "raises the same class for a bad ISBN check digit" do
      expect { Pubid::Isbn.parse("978-0-306-40615-8") }
        .to raise_error(Pubid::Errors::ParseError)
    end

    it "leaves parse_failure_cause nil rather than faking one" do
      Pubid::Csa.parse("# a comment")
    rescue Pubid::Errors::ParseError => e
      expect(e.parse_failure_cause).to be_nil
      expect(e.input).to eq("# a comment")
    end
  end

  describe "a URN failure" do
    subject(:error) do
      Pubid::Iec.parse_urn("urn:iso:std:iso:9001")
    rescue StandardError => e
      e
    end

    it "is a Pubid::Errors::UrnParseError" do
      expect(error).to be_a(Pubid::Errors::UrnParseError)
    end

    it "is caught by the marker, alongside grammar failures" do
      expect(error).to be_a(Pubid::Errors::Error)
    end

    it "is not disguised as a parslet failure" do
      expect(error).not_to be_a(Parslet::ParseFailed)
    end

    it "still satisfies the old alias" do
      expect(error).to be_a(Pubid::UrnParser::Errors::ParseError)
    end

    it "covers the shared UrnParser::Base prefix check too" do
      expect { Pubid::Sae::UrnParser.parse("urn:iso:std:iso:9001") }
        .to raise_error(Pubid::Errors::UrnParseError)
    end
  end

  describe "an input-validation failure" do
    it "raises InvalidInputError for a non-String" do
      expect { Pubid::Iso.parse(nil) }
        .to raise_error(Pubid::Errors::InvalidInputError, /must be a String/)
    end

    it "raises InvalidInputError for an over-long string" do
      expect { Pubid::Iso.parse("A#{'9' * Pubid::MAX_INPUT_LENGTH}") }
        .to raise_error(Pubid::Errors::InvalidInputError, /maximum length/)
    end

    it "still satisfies the old rescue" do
      expect { Pubid::Iso.parse(nil) }.to raise_error(ArgumentError)
    end

    it "is caught by the marker" do
      expect { Pubid::Iso.parse(nil) }.to raise_error(Pubid::Errors::Error)
    end
  end

  describe "rescue Pubid::Errors::Error is exhaustive" do
    {
      "a grammar failure" => -> { Pubid::Iso.parse("@@@ nope @@@") },
      "a synthetic failure" => -> { Pubid::Csa.parse("# a comment") },
      "a URN failure" => -> { Pubid::Iec.parse_urn("urn:iso:std:iso:9001") },
      "a non-String" => -> { Pubid::Iso.parse(nil) },
      "an over-long string" => lambda {
        Pubid::Iso.parse("A#{'9' * Pubid::MAX_INPUT_LENGTH}")
      },
    }.each do |name, call|
      it "catches #{name}" do
        expect { call.call }.to raise_error(Pubid::Errors::Error)
      end
    end
  end
end
