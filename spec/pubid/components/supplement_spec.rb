# frozen_string true

require "spec_helper"

RSpec.describe Pubid::Components::Supplement do
  let(:date) { ->(year:, month: nil) { Pubid::Components::Date.new(year:, month:) } }

  describe "#present?" do
    it "returns false for an empty supplement" do
      expect(described_class.new).not_to be_present
    end

    it "returns true when number is set" do
      expect(described_class.new(number: "1")).to be_present
    end

    it "returns true when date is set" do
      expect(described_class.new(date: date.call(year: "1925"))).to be_present
    end

    it "returns true when has_revision is true" do
      expect(described_class.new(has_revision: true)).to be_present
    end

    it "returns false when has_revision is false" do
      expect(described_class.new(has_revision: false)).not_to be_present
    end

    it "returns true when suffix is a non-empty string" do
      expect(described_class.new(suffix: "A")).to be_present
    end

    it "returns false when suffix is empty" do
      expect(described_class.new(suffix: "")).not_to be_present
    end

    it "does not consider the default type as content" do
      expect(described_class.new.type).to eq("sup")
      expect(described_class.new).not_to be_present
    end
  end

  describe "#range?" do
    it "returns false when only date is set" do
      supplement = described_class.new(date: date.call(year: "1925"))
      expect(supplement).not_to be_range
    end

    it "returns true when date and range_end_date are both set" do
      supplement = described_class.new(
        date: date.call(year: "1925", month: "Jun"),
        range_end_date: date.call(year: "1926", month: "Jun"),
      )
      expect(supplement).to be_range
    end
  end

  describe "#render" do
    it "renders bare number" do
      expect(described_class.new(number: "2").render).to eq("2")
    end

    it "renders year only" do
      supplement = described_class.new(date: date.call(year: "1925"))
      expect(supplement.render).to eq("1925")
    end

    it "renders month abbreviation + year" do
      supplement = described_class.new(date: date.call(year: "1924", 
                                                       month: "Jan"))
      expect(supplement.render).to eq("Jan1924")
    end

    it "renders numeric month + year as YYYY-MM" do
      supplement = described_class.new(date: date.call(year: "2025", 
                                                       month: "3"))
      expect(supplement.render).to eq("2025-03")
    end

    it "renders number + year as N/Y" do
      supplement = described_class.new(number: "3", 
                                       date: date.call(year: "1926"))
      expect(supplement.render).to eq("3/1926")
    end

    it "renders 'rev' for has_revision" do
      expect(described_class.new(has_revision: true).render).to eq("rev")
    end

    it "renders suffix verbatim" do
      expect(described_class.new(suffix: "A").render).to eq("A")
    end

    it "renders date ranges with dash" do
      supplement = described_class.new(
        date: date.call(year: "1925", month: "Jun"),
        range_end_date: date.call(year: "1926", month: "Jun"),
      )
      expect(supplement.render).to eq("Jun1925-Jun1926")
    end
  end

  describe "#render with urn context" do
    let(:urn_ctx) { Pubid::Rendering::RenderingContext.urn }

    it "renders number:year" do
      supplement = described_class.new(number: "3", 
                                       date: date.call(year: "1926"))
      expect(supplement.render(context: urn_ctx)).to eq("3:1926")
    end

    it "renders empty when no content" do
      expect(described_class.new.render(context: urn_ctx)).to eq("")
    end
  end

  describe "#eql?" do
    it "matches another supplement with same fields" do
      a = described_class.new(number: "1", date: date.call(year: "1925"))
      b = described_class.new(number: "1", date: date.call(year: "1925"))
      expect(a).to eq(b)
    end

    it "does not match when number differs" do
      a = described_class.new(number: "1")
      b = described_class.new(number: "2")
      expect(a).not_to eq(b)
    end

    it "does not match when type differs" do
      a = described_class.new(number: "1", type: "amd")
      b = described_class.new(number: "1", type: "cor")
      expect(a).not_to eq(b)
    end
  end

  describe "#hash" do
    it "is stable across equal instances" do
      a = described_class.new(number: "1", date: date.call(year: "1925"))
      b = described_class.new(number: "1", date: date.call(year: "1925"))
      expect(a.hash).to eq(b.hash)
    end
  end
end
