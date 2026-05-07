module Pubid
  module Iso
    module Identifier
      RSpec.describe Corrigendum do
        context "when create corrigendum identifier" do
          let(:base) { Identifier.create(number: number, **params) }
          let(:params) { { year: 1999 } }
          let(:number) { 123 }

          subject do
            described_class.new(type: :cor, number: 1, base: base,
                                **corrigendum_params)
          end

          context "when corrigendum with stage" do
            let(:corrigendum_params) { { stage: stage } }

            context "with DCor stage" do
              let(:stage) { :dcor }

              it "renders long stage and corrigendum" do
                expect(subject.to_s).to eq("ISO #{number}:1999/DCOR 1")
              end

              it "renders short stage and corrigendum" do
                expect(subject.to_s(format: :ref_num_short)).to eq("ISO #{number}:1999/DCOR 1")
              end
            end
          end
        end
      end
    end
  end
end
