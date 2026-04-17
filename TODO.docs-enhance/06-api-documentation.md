# Task 06: API Documentation

## Status: DONE

## Goal

Create API documentation for the main public interfaces: parsing, rendering, identifier objects, and their methods. Target audience: developers integrating pubid into their applications.

## Key Interfaces to Document

### Top-Level Entry Points

```ruby
# Parse an identifier (auto-detects flavor)
Pubid.parse("ISO 9001:2015")

# Flavor-specific parsing
Pubid::Iso.parse("ISO 9001:2015")
Pubid::Iec.parse("IEC 62368-1:2023")
Pubid::Nist.parse("NIST SP 800-53 Rev. 5")
```

### Identifier Object Methods

```ruby
id = Pubid::Iso.parse("ISO/IEC 9001:2015")

id.to_s              # => "ISO/IEC 9001:2015"
id.to_urn            # => "urn:iso:std:iso-iec:9001"
id.publisher          # => "ISO"
id.copublishers       # => ["IEC"]
id.number             # => 9001
id.part               # => nil
id.year               # => 2015
id.stage              # => nil (or stage object)
id.edition            # => nil
id.type               # => :international_standard
id.annotated          # => HTML with <span> tags
```

### Stage Objects

```ruby
id.stage.abbr         # => "CD"
id.stage.name         # => "Committee Draft"
id.stage.harmonized_code # => "30.20"
```

### Error Handling

```ruby
begin
  Pubid.parse("invalid identifier")
rescue Pubid::Core::ParseError => e
  puts e.message
end
```

## Delivery Format

- YARD-compatible docstrings on all public methods
- `docs/API.md` as a readable guide
- Ensure `yard doc` generates clean output

## Files to Modify

- `lib/pubid/core/identifier.rb` — public API methods
- `lib/pubid/core/parser.rb` — parse entry points
- `lib/pubid/iso.rb` — flavor entry point
- `lib/pubid/iec.rb` — flavor entry point
- All flavor entry points — document `parse`, `create`, `resolve_identifier` methods
- `docs/API.md` — create

## Acceptance Criteria

- Every public method has YARD documentation
- `yard doc` runs without warnings
- `docs/API.md` covers all common use cases with runnable examples
- Error handling is documented
