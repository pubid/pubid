# frozen_string_literal: true

require "spec_helper"

RSpec.describe PubidNew::Csa::Identifiers::Package do
  subject { described_class }

  describe ".parse" do
    context "Code & Handbook packages" do
      describe "CSA B149.1:25 Code, Handbook & Training Package" do
        subject { "CSA B149.1:25 Code, Handbook & Training Package" }
        let(:parsed) { PubidNew::Csa.parse(subject) }

        it "parses as Package" do
          expect(parsed).to be_a(described_class)
        end

        it "parses base identifier" do
          expect(parsed.base_identifier).to be_a(PubidNew::Csa::Identifiers::Standard)
          expect(parsed.base_identifier.code.value).to eq("B149.1")
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end
      end

      describe "CSA C22.1:24 Code & Handbook Package" do
        subject { "CSA C22.1:24 Code & Handbook Package" }
        let(:parsed) { PubidNew::Csa.parse(subject) }

        it "parses as Package" do
          expect(parsed).to be_a(described_class)
        end

        it "parses base identifier" do
          expect(parsed.base_identifier.code.value).to eq("C22.1")
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end
      end
    end

    context "Training packages" do
      describe "CSA B149.1:25, CSA B149.2:25 & Training Package" do
        subject { "CSA B149.1:25, CSA B149.2:25 & Training Package" }
        let(:parsed) { PubidNew::Csa.parse(subject) }

        it "parses as Package" do
          expect(parsed).to be_a(described_class)
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end
      end
    end

    context "PACKAGE suffix (uppercase)" do
      describe "C22.1-15 PACKAGE" do
        subject { "C22.1-15 PACKAGE" }
        let(:parsed) { PubidNew::Csa.parse(subject) }

        it "parses as Package" do
          expect(parsed).to be_a(described_class)
        end

        it "parses base identifier" do
          expect(parsed.base_identifier.code.value).to eq("C22.1")
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end
      end

      describe "C22.1-18 PACKAGE" do
        subject { "C22.1-18 PACKAGE" }
        let(:parsed) { PubidNew::Csa.parse(subject) }

        it "parses as Package" do
          expect(parsed).to be_a(described_class)
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end
      end

      describe "C22.10-10 PACKAGE" do
        subject { "C22.10-10 PACKAGE" }
        let(:parsed) { PubidNew::Csa.parse(subject) }

        it "parses as Package" do
          expect(parsed).to be_a(described_class)
        end

        it "parses base identifier" do
          expect(parsed.base_identifier.code.value).to eq("C22.10")
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end
      end

      describe "CSA B108:23 PACKAGE" do
        subject { "CSA B108:23 PACKAGE" }
        let(:parsed) { PubidNew::Csa.parse(subject) }

        it "parses as Package" do
          expect(parsed).to be_a(described_class)
        end

        it "parses base identifier" do
          expect(parsed.base_identifier.code.value).to eq("B108")
        end

        it "round-trips" do
          expect(parsed.to_s).to eq(subject)
        end
      end
    end
  end
end
