module Pubid
  module Nist
    RSpec.describe Stage do
      let(:short_stage) { "NIST SP 800-18(IPD)" }
      let(:long_stage) { "(Initial Public Draft)" }

      it "returns long title for stage" do
        expect(described_class.new(id: "i", type: "pd").to_s(:long))
          .to eq(long_stage)
      end

      it "raises an error when id or type is nil" do
        expect do
          described_class.new(id: "i",
                              type: nil)
        end.to raise_error(ArgumentError, "type cannot be nil")
        expect do
          described_class.new(id: nil,
                              type: "pd")
        end.to raise_error(ArgumentError, "id cannot be nil")
      end

      it "raises an error when passed wrong id or type" do
        expect do
          described_class.new(id: "i",
                              type: "wrong")
        end.to raise_error(ArgumentError, "type cannot be \"wrong\"")
        expect do
          described_class.new(id: "wrong",
                              type: "pd")
        end.to raise_error(ArgumentError, "id cannot be \"wrong\"")
      end
    end
  end
end
