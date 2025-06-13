
#       # ISO/TCWD 184/SC 4/WG 12 N11498
#       context "when TC type identifier" do
#         let(:base_params) do
#           { number: "11498", type: :tc, tctype: "TC", tcnumber: 184,
#             sctype: "SC", scnumber: "4", wgtype: "WG", wgnumber: 12 }
#         end
#         let(:params) { base_params }

#         it "render TC document" do
#           expect(subject.to_s).to eq("ISO/TC 184/SC 4/WG 12 N11498")
#         end

#         context "when supplied stage" do
#           let(:params) { base_params.merge({ stage: "WD" }) }

#           it "renders identifier without stage" do
#             expect(subject.to_s).to eq("ISO/TC 184/SC 4/WG 12 N11498")
#           end
#         end
#       end

#       context "when another publisher" do
#         let(:params) { { publisher: "IEC" } }

#         it "render with another publisher" do
#           expect(subject.to_s).to eq("IEC #{number}")
#         end
#       end

