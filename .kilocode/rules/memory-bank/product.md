## Purpose

PubID is a Ruby gem library that parses and generates unique public identifiers (PubIDs) for published objects such as standards, documents, datasets, and other digital content across multiple standards organizations.

The core problem PubID solves is **interoperability**: different organizations publish standards with different identifier formats, making it difficult to:
- Parse identifiers programmatically
- Convert between human-readable and machine-readable formats
- Maintain consistency across systems
- Exchange data between organizations

## Problems It Solves

1. **Format Complexity**: Standards organizations use complex, varied identifier formats (ISO/IEC 27001:2013/Amd 1:2015, NIST SP 800-53r5, IEEE Std C37.111-2013, etc.)

2. **Round-Trip Conversion**: Need to parse string identifiers into structured data AND render them back to strings identically

3. **Multi-Organization Support**: Each organization has unique patterns:
   - ISO: Copublishers (ISO/IEC/IEEE), supplements (amendments, corrigenda), document types
   - NIST: Multiple series (SP, FIPS, IR), revisions, historical NBS patterns
   - IEEE: Adopted standards, dual-published identifiers, complex draft patterns
   - IEC: VAP identifiers, consolidated amendments, fragment identifiers
   - And 6+ more organizations

4. **Historical Compatibility**: Must handle legacy formats (e.g., NBS identifiers from 1900s-1980s)

## How It Works

### User Experience Goals

Users should be able to:

```ruby
# Parse any standard identifier
id = PubidNew::Iso.parse("ISO/IEC 27001:2013/Amd 1:2015")

# Access structured components
id.publisher.to_s           # => "ISO/IEC"
id.number.value            # => "27001"
id.date.year               # => 2013
id.class                   # => PubidNew::Iso::Identifiers::Amendment
id.base_identifier.to_s    # => "ISO/IEC 27001:2013"

# Render back to string (round-trip)
id.to_s                    # => "ISO/IEC 27001:2013/Amd 1:2015"

# Works across all supported organizations
nist_id = PubidNew::Nist.parse("NIST SP 800-53r5")
ieee_id = PubidNew::Ieee.parse("IEEE Std C37.111-2013")
```

### Key Features

1. **Structured Parsing**: Convert strings to rich object models with proper types
2. **Round-Trip Fidelity**: Parse → Object → String maintains exact format
3. **Type Safety**: Each identifier is a proper class with validated attributes
4. **Component Reuse**: Shared components (Publisher, Code, Date) across flavors
5. **Extensibility**: Easy to add new organizations or identifier types
6. **Production Quality**: 98%+ parsing accuracy on real-world datasets

### Supported Organizations

- **ISO** (International Organization for Standardization)
- **IEC** (International Electrotechnical Commission)
- **IEEE** (Institute of Electrical and Electronics Engineers)
- **NIST** (National Institute of Standards and Technology)
- **ITU** (International Telecommunication Union)
- **JIS** (Japanese Industrial Standards)
- **ETSI** (European Telecommunications Standards Institute)
- **CCSDS** (Consultative Committee for Space Data Systems)
- **BSI** (British Standards Institution)
- **CEN** (European Committee for Standardization)
- **PLATEAU** (Japanese urban planning standards)

## Current Major Initiative

### V2 Migration (In Progress)

The project is undergoing a complete architectural rewrite from V1 to V2:

**V1 (Legacy)**: Located in `gems/pubid-{flavor}/`, uses Parslet but with anti-patterns
**V2 (New)**: Located in `lib/pubid_new/{flavor}/`, uses MODEL-DRIVEN architecture

**Status**: 6/10 flavors complete at 100% (58,822 tests passing), 4/10 partial

**Goal**: Replace V1 entirely with clean V2 architecture, then rename `pubid_new` → `pubid` and delete `gems/` folder