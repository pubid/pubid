require "spec_helper"

RSpec.describe PubidNew::Nist::Parser do
  describe "parsing through module interface" do
    context "LCIRC series" do
      it "parses basic LCIRC" do
        expect { PubidNew::Nist.parse("NBS LCIRC 1000") }.not_to raise_error
        expect { PubidNew::Nist.parse("NBS LCIRC 525") }.not_to raise_error
      end

      it "parses LCIRC with revision year" do
        expect { PubidNew::Nist.parse("NBS LCIRC 1019r1963") }.not_to raise_error
        expect { PubidNew::Nist.parse("NBS LCIRC 1035r1985") }.not_to raise_error
      end
    end

    context "CSM volume-number format" do
      it "parses v#n# format" do
        expect { PubidNew::Nist.parse("NBS CSM v6n1") }.not_to raise_error
        expect { PubidNew::Nist.parse("NBS CSM v7n12") }.not_to raise_error
        expect { PubidNew::Nist.parse("NBS CSM v9n9") }.not_to raise_error
      end
    end

    context "supplement with revision" do
      it "parses supprev notation" do
        expect { PubidNew::Nist.parse("NBS CIRC 154supprev") }.not_to raise_error
      end

      it "parses supplement with date" do
        expect { PubidNew::Nist.parse("NBS CIRC 25suppJan1924") }.not_to raise_error
        expect { PubidNew::Nist.parse("NBS CIRC 25suppJune1924") }.not_to raise_error
      end

      it "parses supplement with edition" do
        expect { PubidNew::Nist.parse("NBS CIRC 24e4supp") }.not_to raise_error
      end
    end

    context "edition with revision and date" do
      it "parses edition with revision and month-year" do
        expect { PubidNew::Nist.parse("NBS CIRC 13e2revJune1908") }.not_to raise_error
        expect { PubidNew::Nist.parse("NBS CIRC 13e2revJuly1908") }.not_to raise_error
      end

      it "parses edition with revision year only" do
        expect { PubidNew::Nist.parse("NBS CIRC 13e2rev1908") }.not_to raise_error
      end

      it "parses edition with supplement" do
        expect { PubidNew::Nist.parse("NBS CIRC 24e4supp") }.not_to raise_error
      end
    end

    context "modern NIST identifiers" do
      it "parses NIST SP with parts" do
        expect { PubidNew::Nist.parse("NIST SP 800-53") }.not_to raise_error
        expect { PubidNew::Nist.parse("NIST SP 500-175") }.not_to raise_error
      end

      it "parses NIST SP with revision" do
        expect { PubidNew::Nist.parse("NIST SP 800-53r5") }.not_to raise_error
      end

      it "parses NIST FIPS" do
        expect { PubidNew::Nist.parse("NIST FIPS 140-3") }.not_to raise_error
      end
    end

    context "NBS historical identifiers" do
      it "parses NBS CIRC" do
        expect { PubidNew::Nist.parse("NBS CIRC 13") }.not_to raise_error
      end

      it "parses NBS BMS" do
        expect { PubidNew::Nist.parse("NBS BMS 131") }.not_to raise_error
      end
    end

    context "parse identifiers from fixtures" do
      let(:fixture_path) { "gems/pubid-nist/spec/fixtures/allrecords.txt" }

      it "parses majority of fixture identifiers" do
        total = 0
        parsed = 0

        File.readlines(fixture_path).each do |line|
          id = line.strip
          next if id.empty?

          total += 1
          begin
            PubidNew::Nist.parse(id)
            parsed += 1
          rescue Parslet::ParseFailed, StandardError
            # Expected for some edge cases
          end
        end

        # Should parse at least 98% of identifiers
        success_rate = (parsed.to_f / total * 100).round(2)
        expect(success_rate).to be >= 98.0
      end
    end
  end
end