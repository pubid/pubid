require "spec_helper"

RSpec.describe Pubid::Sae::Identifier do
  describe ".create" do
    context "default" do
      it "returns a Base (SAE has one identifier class)" do
        id = described_class.create(type: "J", number: "1234")
        expect(id).to be_a(Pubid::Sae::Identifiers::Base)
      end

      it "renders 'SAE <type> <number>'" do
        id = described_class.create(type: "J", number: "1234")
        expect(id.to_s).to eq("SAE J 1234")
      end
    end

    context ":type as instance data (not class dispatch)" do
      %w[J AS ARP AMS AIR MA].each do |type|
        it "preserves type: '#{type}'" do
          id = described_class.create(type: type, number: "1234")
          expect(id.type.abbr).to eq(type)
          expect(id.to_s).to start_with("SAE #{type}")
        end
      end
    end

    context "primitive coercion" do
      it "wraps :type into Sae::Components::Type" do
        id = described_class.create(type: "J", number: "1234")
        expect(id.type).to be_a(Pubid::Sae::Components::Type)
      end

      it "wraps :number into a base Code Component" do
        id = described_class.create(type: "J", number: "1234")
        expect(id.number).to be_a(Pubid::Components::Code)
        expect(id.number.value).to eq("1234")
      end

      it "defaults publisher to 'SAE'" do
        id = described_class.create(type: "J", number: "1234")
        expect(id.publisher).to eq("SAE")
      end
    end

    context "parse equivalence" do
      [
        ["SAE J1234",  { type: "J",  number: "1234" }],
        ["SAE AS9100", { type: "AS", number: "9100" }],
      ].each do |string, opts|
        it "round-trips #{string}" do
          created = described_class.create(**opts)
          parsed = Pubid::Sae.parse(string)
          expect(created.to_s).to eq(parsed.to_s)
        end
      end
    end
  end
end
