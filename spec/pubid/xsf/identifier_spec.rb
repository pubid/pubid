# frozen_string_literal: true

require "spec_helper"

RSpec.describe Pubid::Xsf::Identifier do
  describe ".parse" do
    context "with a basic XEP identifier" do
      subject(:input) { "XEP 0001" }

      let(:parsed) { described_class.parse(input) }

      it "parses as an Xep" do
        expect(parsed).to be_a(Pubid::Xsf::Identifiers::Xep)
      end

      it "preserves the 4-digit zero-padded number as a string" do
        expect(parsed.number).to eq("0001")
      end

      it "round-trips to its printed form" do
        expect(parsed.to_s).to eq(input)
      end

      it "renders the bare number without the publisher" do
        expect(parsed.to_s(with_publisher: false)).to eq("0001")
      end
    end

    context "with other real XEP numbers" do
      it "round-trips XEP 0060" do
        expect(described_class.parse("XEP 0060").to_s).to eq("XEP 0060")
      end

      it "round-trips XEP 0218" do
        expect(described_class.parse("XEP 0218").to_s).to eq("XEP 0218")
      end

      it "preserves leading zeros on a low number" do
        expect(described_class.parse("XEP 0004").number).to eq("0004")
      end
    end

    context "with a named document (not a number)" do
      # The XMPP extensions repository publishes two documents whose name is
      # not a number: the editor README and the `xep-xxxx` template. Both are
      # real primary docids in relaton-data-xsf.
      %w[README xxxx].each do |name|
        it "parses XEP #{name} as an Xep" do
          expect(described_class.parse("XEP #{name}"))
            .to be_a(Pubid::Xsf::Identifiers::Xep)
        end

        it "keeps #{name} as the number" do
          expect(described_class.parse("XEP #{name}").number).to eq(name)
        end

        it "round-trips XEP #{name} to its printed form" do
          expect(described_class.parse("XEP #{name}").to_s).to eq("XEP #{name}")
        end

        it "renders the bare name without the publisher for #{name}" do
          id = described_class.parse("XEP #{name}")
          expect(id.to_s(with_publisher: false)).to eq(name)
        end

        it "round-trips XEP #{name} through its URN" do
          id = described_class.parse("XEP #{name}")
          expect(id.to_urn).to eq("urn:xsf:xep:#{name}")
          expect(Pubid.parse(id.to_urn)).to eq(id)
        end

        it "round-trips XEP #{name} through to_hash" do
          id = described_class.parse("XEP #{name}")
          expect(described_class.from_hash(id.to_hash)).to eq(id)
        end
      end

      # The two names are literals, not a general slug rule. Every neighbour
      # still fails, so the flavor keeps rejecting junk after the prefix.
      ["XEP foo", "XEP readme", "XEP Readme", "XEP XXXX", "XEP READMEX",
       "XEP xxx", "XEP xxxxx", "XEP README 1"].each do |input|
        it "rejects #{input.inspect}" do
          expect { described_class.parse(input) }
            .to raise_error(Pubid::Errors::ParseError)
        end
      end
    end

    context "with malformed input" do
      it "raises for a non-XEP string" do
        expect { described_class.parse("FOO 0001") }.to raise_error(StandardError)
      end

      it "raises for an over-long string (ReDoS guard)" do
        expect { described_class.parse("XEP #{'0' * 1000}") }
          .to raise_error(ArgumentError, /maximum length/)
      end
    end
  end

  describe "via the flavor module" do
    it "Pubid::Xsf.parse delegates to the identifier" do
      expect(Pubid::Xsf.parse("XEP 0131").to_s).to eq("XEP 0131")
    end
  end
end
