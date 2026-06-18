require "spec_helper"

RSpec.describe Pubid::Components::Code do
  describe "#render" do
    let(:code) { described_class.new(value: "12345") }
    let(:human_ctx) { Pubid::Rendering::RenderingContext.new }
    let(:urn_ctx) { Pubid::Rendering::RenderingContext.urn }

    it "renders the value for human context" do
      expect(code.render(context: human_ctx)).to eq("12345")
    end

    it "renders the value for URN context" do
      expect(code.render(context: urn_ctx)).to eq("12345")
    end

    it "renders the value with no context" do
      expect(code.render).to eq("12345")
    end
  end
end

RSpec.describe Pubid::Components::Publisher do
  describe "#render" do
    let(:publisher) { described_class.new(body: "ISO") }
    let(:human_ctx) { Pubid::Rendering::RenderingContext.new }
    let(:urn_ctx) { Pubid::Rendering::RenderingContext.urn }

    it "renders the body as-is for human context" do
      expect(publisher.render(context: human_ctx)).to eq("ISO")
    end

    it "renders lowercase body for URN context" do
      expect(publisher.render(context: urn_ctx)).to eq("iso")
    end
  end
end

RSpec.describe Pubid::Components::Date do
  describe "#render" do
    let(:human_ctx) { Pubid::Rendering::RenderingContext.new }
    let(:urn_ctx) { Pubid::Rendering::RenderingContext.urn }

    it "renders year only when only year is set" do
      date = described_class.new(year: "2024")
      expect(date.render(context: human_ctx)).to eq("2024")
    end

    it "renders year-month-day for human context" do
      date = described_class.new(year: "2024", month: "03", day: "15")
      expect(date.render(context: human_ctx)).to eq("2024-03-15")
    end

    it "renders year only for URN context even with month/day set" do
      date = described_class.new(year: "2024", month: "03", day: "15")
      expect(date.render(context: urn_ctx)).to eq("2024")
    end
  end
end

RSpec.describe Pubid::Components::Edition do
  describe "#render" do
    let(:human_ctx) { Pubid::Rendering::RenderingContext.new }
    let(:urn_ctx) { Pubid::Rendering::RenderingContext.urn }

    it "renders EDN format for human context" do
      edition = described_class.new(number: "1")
      expect(edition.render(context: human_ctx)).to eq("ED1")
    end

    it "renders ed-N format for URN context" do
      edition = described_class.new(number: "1")
      expect(edition.render(context: urn_ctx)).to eq("ed-1")
    end

    it "returns nil when number is missing" do
      edition = described_class.new
      expect(edition.render(context: human_ctx)).to be_nil
    end
  end
end

RSpec.describe Pubid::Components::Language do
  describe "#render" do
    let(:human_ctx) { Pubid::Rendering::RenderingContext.new }
    let(:urn_ctx) { Pubid::Rendering::RenderingContext.urn }

    it "renders ISO 639-1 code for human context" do
      lang = described_class.new(code: "en")
      expect(lang.render(context: human_ctx)).to eq("en")
    end

    it "renders lowercase code for URN context" do
      lang = described_class.new(code: "EN")
      expect(lang.render(context: urn_ctx)).to eq("en")
    end
  end
end

RSpec.describe Pubid::Components::Locality do
  describe "#render" do
    let(:human_ctx) { Pubid::Rendering::RenderingContext.new }
    let(:urn_ctx) { Pubid::Rendering::RenderingContext.urn }

    it "renders '(all parts)' for human context" do
      locality = described_class.new
      expect(locality.render(context: human_ctx)).to eq("(all parts)")
    end

    it "renders 'all' for URN context" do
      locality = described_class.new
      expect(locality.render(context: urn_ctx)).to eq("all")
    end
  end
end

RSpec.describe Pubid::Rendering::RenderingContext do
  describe "#format" do
    it "defaults to :human" do
      expect(described_class.new.format).to eq(:human)
    end

    it "accepts :urn" do
      expect(described_class.new(format: :urn).format).to eq(:urn)
    end
  end

  describe ".urn" do
    it "returns a context with :urn format" do
      expect(described_class.urn.format).to eq(:urn)
    end

    it "memoizes the instance" do
      expect(described_class.urn).to be(described_class.urn)
    end
  end

  describe "#urn? / #human? / #mr?" do
    it "returns true for the matching format" do
      expect(described_class.new(format: :urn).urn?).to be true
      expect(described_class.new(format: :human).human?).to be true
      expect(described_class.new(format: :mr).mr?).to be true
    end

    it "returns false for non-matching formats" do
      expect(described_class.new(format: :human).urn?).to be false
      expect(described_class.new(format: :urn).human?).to be false
    end
  end
end
