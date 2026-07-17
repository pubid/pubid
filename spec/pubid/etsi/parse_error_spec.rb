require "spec_helper"

RSpec.describe "ETSI parse error class" do
  # An unrecognized reference must raise Parslet::ParseFailed (matching ISO and
  # what relaton-cli's fetch handler rescues) rather than a bare RuntimeError.
  it "raises Parslet::ParseFailed for an unrecognized reference" do
    expect { Pubid::Etsi.parse("this is not an etsi ref!!!") }
      .to raise_error(Parslet::ParseFailed)
  end

  it "raises Parslet::ParseFailed from the class-level parse too" do
    expect { Pubid::Etsi::Identifier.parse("garbage@@@") }
      .to raise_error(Parslet::ParseFailed)
  end

  it "still parses a valid full reference" do
    expect { Pubid::Etsi.parse("ETSI EN 300 175-1 V1.9.1 (2005-09)") }
      .not_to raise_error
  end

  it "still parses a valid partial reference" do
    expect { Pubid::Etsi.parse("ETSI EN 300 175") }.not_to raise_error
  end
end
