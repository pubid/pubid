module Pubid
  module Core
    RSpec.describe Configuration do
      before do
        config.types = [DummyInternationalStandardType,
                        DummyTechnicalReportType]
      end

      let(:config) { described_class.new }

      describe "#typed_stages" do
        it "returns all typed stages available" do
          expect(config.typed_stages).to eq(DummyInternationalStandardType::TYPED_STAGES.merge(DummyTechnicalReportType::TYPED_STAGES))
        end
      end
    end
  end
end
