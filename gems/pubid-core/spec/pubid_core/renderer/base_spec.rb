module Pubid::Core
  RSpec.describe Renderer::Base do
    describe "#annotate_value" do
      subject { described_class.new({}).annotate_value(key, value) }

      context "when key has a semantic class mapping" do
        let(:key) { :publisher }
        let(:value) { "ISO" }

        it "wraps value in a span tag" do
          expect(subject).to eq('<span class="publisher">ISO</span>')
        end
      end

      context "when value has leading separator" do
        let(:key) { :part }
        let(:value) { "-1" }

        it "preserves leading separator outside span" do
          expect(subject).to eq('-<span class="part">1</span>')
        end
      end

      context "when value has leading colon separator" do
        let(:key) { :year }
        let(:value) { ":2013" }

        it "preserves leading separator outside span" do
          expect(subject).to eq(':<span class="year">2013</span>')
        end
      end

      context "when key has no semantic class mapping" do
        let(:key) { :copublisher }
        let(:value) { "IEC" }

        it "returns value unchanged" do
          expect(subject).to eq("IEC")
        end
      end

      context "when value is empty" do
        let(:key) { :publisher }
        let(:value) { "" }

        it "returns empty string" do
          expect(subject).to eq("")
        end
      end

      context "when value is only separators" do
        let(:key) { :publisher }
        let(:value) { "/ " }

        it "returns value unchanged" do
          expect(subject).to eq("/ ")
        end
      end
    end

    describe "#prerender_params with annotated" do
      let(:renderer) { described_class.new(params) }

      context "when annotated is true" do
        let(:params) { { publisher: "ISO", number: "1234" } }

        it "annotates rendered values" do
          result = renderer.prerender_params(params, { annotated: true })
          expect(result[:publisher]).to eq('<span class="publisher">ISO</span>')
          expect(result[:number]).to eq('<span class="docnumber">1234</span>')
        end
      end

      context "when annotated is false" do
        let(:params) { { publisher: "ISO", number: "1234" } }

        it "does not annotate rendered values" do
          result = renderer.prerender_params(params, { annotated: false })
          expect(result[:publisher]).to eq("ISO")
          expect(result[:number]).to eq("1234")
        end
      end
    end
  end
end
