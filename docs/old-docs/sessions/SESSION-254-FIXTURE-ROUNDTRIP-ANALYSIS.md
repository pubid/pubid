# Session 254: ISO V2 Fixture Round-Trip Analysis

## Problem Statement

V2 ISO implementation fails to round-trip V1 fixture files exactly. These fixtures contain OFFICIAL identifier formats that must be preserved.

## Failure Categories

### Category 1: TypedStage Dot Preservation (15+ identifiers)

**Pattern**: `Amd.1`, `Cor.1`, `Add.1` - dot after abbreviation gets removed

**Example failures**:
- `ISO 1247:1974/Amd.1:1982(fr)` → renders as `ISO 1247:1974/Amd 1:1982(fr)`
- `ISO 14687-1:1999/Cor.1:2001(fr)` → renders as `ISO 14687-1:1999/Cor 1:2001(fr)`

**Root cause**: TypedStage.abbr array includes `"Amd."` but rendering uses `canonical_abbreviation` or `abbreviation()` which returns `"Amd"` without dot

**Fix needed**: TypedStage must preserve whether abbreviation had trailing dot in `original_abbr`

### Category 2: French Guide Word Order (6 identifiers)

**Pattern**: French Guide format puts "Guide" BEFORE publisher

**Example failures**:
- `GUIDE ISO/CEI 71:2001(F)` → renders as `ISO/CEI Guide 71:2001(F)`
- `Guide ISO 34:2009` → renders as `ISO/Guide 34:2009`

**Root cause**: V2 always uses English word order (publisher first, then type)

**Fix needed**: Language-dependent rendering in `publisher_portion()` method - check language, reorder accordingly

### Category 3: NSB Identifier Parsing (27 identifiers, 0% pass)

**Pattern**: `FprISO` prefix for draft standards

**Example failures**:
- `FprISO 10140-4` - ParseFailed
- `FprISO 105-A03` - ParseFailed

**Root cause**: Parser doesn't recognize `Fpr` prefix pattern

**Fix needed**: Add `Fpr` as stage prefix in parser

### Category 4: French/Russian Publisher Names (multiple)

**Pattern**: Language-dependent copublisher names

**Examples**:
- `ISO/CEI` (French for ISO/IEC)
- Uppercase `GUIDE` vs `Guide`

**Root cause**: Parser/renderer don't handle language-dependent publisher names

**Fix needed**: Detect and preserve language-dependent publisher names

### Category 5: Directives Format (3 identifiers)

**Pattern**: Short form`DIR` vs long form `Directives, Part`

**Example failures**:
- `ISO/IEC Directives Part 1` should render as `ISO/IEC DIR 1`

**Root cause**: Rendering always uses long form, not detecting short form preference

**Fix needed**: TypedStage should track original format (DIR vs Directives)

## V1 vs V2 Rendering Contract

**V1 Behavior** (from archived-gems/pubid-iso):
```ruby
# Default rendering (format: :ref_dated_long)
id.to_s  # Preserves original format (round-trip)

# Normalized rendering
id.to_s(format: :ref_num_long)  # Normalizes to 2-letter lang codes, long stage form
```

**V2 Current Behavior**:
```ruby
# Default rendering
id.to_s  # Should preserve original format (round-trip) ✅ mostly works

# Normalized rendering
id.to_s(format: :ref_num_long)  # Should normalize ✅ works

# Edition rendering  
id.to_s(with_edition: true)  # Should still round-trip, just include edition number
```

**CRITICAL**: The `with_edition` parameter is about **showing edition numbers**, NOT about normalization!

## Architectural Solutions Needed

### Solution 1: TypedStage Dot Tracking

Enhance TypedStage to track if abbreviation had trailing punctuation:

```ruby
class TypedStage
  attribute :original_abbr, :string  # "Amd." or "Amd" or "AMD"
  
  def abbreviation(format_long: false)
    # Return original_abbr if set (for round-trip fidelity)
    return original_abbr if original_abbr
    
    # Otherwise use format preference
    format_long && long_abbr ? long_abbr : short_abbr || abbr.first
  end
end
```

### Solution 2: Language-Dependent Publisher Ordering

Add language parameter to `publisher_portion()`:

```ruby
def publisher_portion(lang: :en, stage_format_long: true)
  case lang
  when :french, :fr
    # French: "Guide ISO/CEI 51:1999"
    [typed_stage_word, publisher_with_copubs].compact.join(' ')
  else
    # English: "ISO/IEC Guide 51:1999"
    [publisher_with_copubs, typed_stage_word].compact.join(' ')
  end
end
```

### Solution 3: NSB Pattern Support

Add to parser:

```ruby
rule(:fpr_prefix) { str("Fpr") }
rule(:nsb_identifier) do
  fpr_prefix >> publisher >> space? >> number >> ...
end
```

### Solution 4: Multilingual Publisher Names

Track and preserve language-dependent names:

```ruby
class Publisher
  attribute :body, :string  # "ISO"
  attribute :language_variant, :string  # "CEI" for IEC in French
  
  def to_s(lang: :en)
    lang == :french && language_variant ? language_variant : body
  end
end
```

## Recommended Approach

**DO NOT** attempt quick fixes. This requires proper architectural work:

1. Analyze V1 implementation for each issue
2. Design V2 architectural solution
3. Implement incrementally with tests
4. Verify no regressions

**Estimated effort**: 8-12 hours across multiple sessions

## Files to Analyze

- `archived-gems/pubid-iso/lib/pubid/iso/renderer/base.rb` - V1 rendering logic
- `archived-gems/pubid-iso/lib/pubid/iso/parser.rb` - V1 parser patterns
- `archived-gems/pubid-iso/lib/pubid/iso/identifier/base.rb` - V1 identifier structure

## Next Steps

Session 254 should:
1. Read V1 rendering logic in detail
2. Understand how V1 preserves dots, French ordering, NSB parsing
3. Create architectural design for V2 fixes
4. Implement ONE category at a time
5. Test after each change

**Status**: ANALYSIS COMPLETE - Ready for architectural design phase
