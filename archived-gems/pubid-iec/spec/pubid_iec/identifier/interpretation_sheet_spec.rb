module Pubid
  module Iec
    module Identifier
      RSpec.describe InterpretationSheet do
        describe "#initialize" do
          context "without base parameter" do
            subject { described_class.new(number: 60050) }

            it "creates instance with nil base" do
              expect(subject.base).to be_nil
            end

            it "passes options to parent class" do
              expect(subject.number).to eq("60050")
            end
          end

          context "with hash base parameter" do
            let(:base_params) { { number: 60050, part: 351, year: 2013 } }
            subject { described_class.new(base: base_params, number: 123) }

            it "creates Identifier from hash" do
              expect(subject.instance_variable_get(:@base)).to be_a(Base)
            end

            it "creates base with correct attributes" do
              base = subject.instance_variable_get(:@base)
              expect(base.number).to eq("60050")
              expect(base.part).to eq("351")
              expect(base.year).to eq(2013)
            end

            it "passes options to parent class" do
              expect(subject.number).to eq("123")
            end
          end

          context "with Identifier object as base parameter" do
            let(:base_identifier) do
              Identifier.create(number: 60050, part: 351, year: 2013)
            end
            subject { described_class.new(base: base_identifier, number: 456) }

            it "uses the provided Identifier directly" do
              expect(subject.instance_variable_get(:@base)).to eq(base_identifier)
            end

            it "passes options to parent class" do
              expect(subject.number).to eq("456")
            end
          end

          context "with various keyword arguments" do
            let(:base_identifier) { Identifier.create(number: 60050) }
            subject do
              described_class.new(
                base: base_identifier,
                number: 789,
                year: 2020,
                language: "en",
                edition: "1.0",
              )
            end

            it "passes all keyword arguments to parent initialize" do
              expect(subject.number).to eq("789")
              expect(subject.year).to eq(2020)
              expect(subject.language).to eq(["en"])
              expect(subject.edition).to eq("1.0")
            end

            it "sets base correctly" do
              expect(subject.instance_variable_get(:@base)).to eq(base_identifier)
            end
          end

          context "with base as hash containing nested attributes" do
            let(:base_params) do
              {
                number: 61010,
                part: "2-201",
                year: 2017,
                type: :tr,
                language: "fr",
              }
            end
            subject { described_class.new(base: base_params, number: 456) }

            it "creates base identifier with all attributes" do
              base = subject.instance_variable_get(:@base)
              expect(base.number).to eq("61010")
              expect(base.part).to eq("2-201")
              expect(base.year).to eq(2017)
              expect(base.language).to eq(["fr"])
            end
          end

          context "with Base subclass as base parameter" do
            let(:base_tr) { TechnicalReport.new(number: 60083, year: 2015) }
            subject { described_class.new(base: base_tr, number: 123) }

            it "accepts Base subclass instances" do
              expect(subject.instance_variable_get(:@base)).to eq(base_tr)
              expect(subject.instance_variable_get(:@base)).to be_a(TechnicalReport)
            end
          end
        end
      end
    end
  end
end
