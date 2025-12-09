# PubID Advanced Rendering Styles Guide

## Overview

ISO and IEC identifiers support short/long abbreviation forms for supplements to maintain round-trip fidelity with different official formats used by standards organizations.

This feature enables PubID to parse and render identifiers in multiple official formats while preserving the exact format that was parsed, ensuring perfect round-trip compatibility.

## ISO Rendering Forms

### Amendment Stages

ISO amendments support two abbreviation formats:

**SHORT forms (uppercase):**
- `AMD` - Published amendment
- `DAM` - Draft Amendment
- `FDAM` - Final Draft Amendment
- `PDAM` - Proposed Draft Amendment (legacy)

**LONG forms (mixed case):**
- `Amd` - Published amendment
- `DAmd` - Draft Amendment
- `FDAmd` - Final Draft Amendment
- `FPDAM` - Final Proposed Draft Amendment (legacy)

**No short form (long only):**
- `PWI Amd`, `NP Amd`, `AWI Amd`, `WD Amd`, `CD Amd`, `PRF Amd`

### Corrigendum Stages

ISO corrigenda also support two formats:

**SHORT forms (uppercase):**
- `COR` - Published corrigendum
- `DCOR` - Draft Corrigendum
- `FDCOR` - Final Draft Corrigendum

**LONG forms (mixed case):**
- `Cor` - Published corrigendum
- `DCor` - Draft Corrigendum
- `FDCor` - Final Draft Corrigendum

**No short form (long only):**
- `PWI Cor`, `NP Cor`, `AWI Cor`, `WD Cor`, `CD Cor`, `PRF Cor`

### Directives

ISO Directives have format variants:

**SHORT:** `DIR`
**LONG:** `Directives, Part`

## IEC Rendering Forms

### Amendment Stages

IEC amendments use different format indicators than ISO:

**SHORT forms (uppercase, no space with number):**
- `AMD1` - Published amendment with number
- `CDV` - Committee Draft Vote
- `DAM` - Draft Amendment
- `FDIS` - Final Draft International Standard

**LONG forms (title case, with space before number):**
- `Amd 1` - Published amendment with number
- `CD` - Committee Draft
- `DAm` - Draft Amendment (title case variant)
- `FDIS` - Final Draft International Standard (same)

**Examples:**
- Short: `IEC 60050-351:2013/AMD1:2016`
- Long: `IEC 60050-351:2013/Amd 1:2016`

### Corrigendum Stages

IEC corrigenda follow the same pattern:

**SHORT forms (uppercase, no space):**
- `COR1` - Published corrigendum with number
- `CDCor` - Committee Draft Corrigendum
- `DCOR` - Draft Corrigendum
- `FDCOR` - Final Draft Corrigendum

**LONG forms (title case, with space):**
- `Cor 1` - Published corrigendum with number
- `CD Cor` - Committee Draft Corrigendum (with space)
- `DCor` - Draft Corrigendum
- `FDCor` - Final Draft Corrigendum

**Examples:**
- Short: `IEC 60050-351:2013/COR1:2016`
- Long: `IEC 60050-351:2013/Cor 1:2016`

### Draft Stages

IEC draft stage abbreviations:
- **CDV** - Committee Draft Vote
- **FDIS** - Final Draft International Standard
- **DAM** - Draft Amendment
- **DCOR** - Draft Corrigendum

## Usage Examples

### ISO Examples

```ruby
require 'pubid_new/iso'

# Parse with long form - automatically preserves format
id = PubidNew::Iso.parse("ISO 8601:2019/DAmd 1")
id.to_s  # => "ISO 8601:2019/DAmd 1" (preserves long form)

# Parse with short form - automatically preserves format
id = PubidNew::Iso.parse("ISO 8601:2019/DAM 1")
id.to_s  # => "ISO 8601:2019/DAM 1" (preserves short form)

# Corrigendum with long form
id = PubidNew::Iso.parse("ISO 19115:2003/Cor 1:2006")
id.to_s  # => "ISO 19115:2003/Cor 1:2006"

# Corrigendum with short form
id = PubidNew::Iso.parse("ISO 19115:2003/COR 1:2006")
id.to_s  # => "ISO 19115:2003/COR 1:2006"

# Multi-level supplements preserve all formats
id = PubidNew::Iso.parse("ISO/IEC 13818-1:2015/DAmd 3:2016/Cor 1:2017")
id.to_s  # => "ISO/IEC 13818-1:2015/DAmd 3:2016/Cor 1:2017"
```

### IEC Examples

```ruby
require 'pubid_new/iec'

# Parse with long form (space before number)
id = PubidNew::Iec.parse("IEC 60050-351:2013/Amd 1:2016")
id.to_s  # => "IEC 60050-351:2013/Amd 1:2016"

# Parse with short form (no space)
id = PubidNew::Iec.parse("IEC 60050-351:2013/AMD1:2016")
id.to_s  # => "IEC 60050-351:2013/AMD1:2016"

# Corrigendum with long form
id = PubidNew::Iec.parse("IEC 60038:2009/Cor 1:2011")
id.to_s  # => "IEC 60038:2009/Cor 1:2011"

# Corrigendum with short form
id = PubidNew::Iec.parse("IEC 60038:2009/COR1:2011")
id.to_s  # => "IEC 60038:2009/COR1:2011"

# Draft stages
id = PubidNew::Iec.parse("IEC 62700:2021/CD:2022")
id.to_s  # => "IEC 62700:2021/CD:2022"
```

## Architecture

The rendering style system uses a MODEL-DRIVEN architecture with automatic format detection:

### Components

1. **TypedStage components** with `short_abbr` and `long_abbr` attributes
2. **Builder detection** from parsed `original_abbr`
3. **RenderingStyle objects** stored in identifiers
4. **Automatic format preservation** for round-trip fidelity

### No Manual Configuration Required

The system automatically detects and preserves the format from the parsed identifier. Users don't need to specify which format they want - it's determined by what they parse.

## Implementation Details

### TypedStage Enhancement

Each TypedStage now has multiple abbreviation attributes:

```ruby
class TypedStage
  attribute :abbr, :string, collection: true   # Array of recognized forms
  attribute :short_abbr, :string               # Short form (uppercase)
  attribute :long_abbr, :string                # Long form (mixed case)
  attribute :original_abbr, :string            # Preserves parsed form
  
  def abbreviation(format_long: true)
    # Return original if set (preserves parsed form)
    return original_abbr if original_abbr
    
    # Otherwise use format preference
    format_long && long_abbr ? long_abbr : short_abbr
  end
end
```

### Builder Detection Logic

The Builder automatically detects which format to use from the parsed abbreviation.

**ISO Detection:**

ISO uses **case** as the format indicator:

```ruby
# Detect long form if original_abbr starts with long_abbr
stage_format_long = if ts.long_abbr && ts.original_abbr
  ts.original_abbr.start_with?(ts.long_abbr)
else
  false
end

# Special case for Directives
if ts.original_abbr&.include?("Directives")
  stage_format_long = true
end
```

**IEC Detection:**

IEC uses **space** as the format indicator:

```ruby
# Detect long form if original_abbr contains space
stage_format_long = if ts.long_abbr && ts.original_abbr
  ts.original_abbr.include?(" ")
else
  false
end
```

### Round-Trip Fidelity

The system guarantees perfect round-trip fidelity:

```ruby
# ISO example - long form
original = "ISO 8601:2019/DAmd 1"
parsed = PubidNew::Iso.parse(original)
parsed.to_s == original  # => true ✓

# ISO example - short form
original = "ISO 8601:2019/DAM 1"
parsed = PubidNew::Iso.parse(original)
parsed.to_s == original  # => true ✓

# IEC example - long form (with space)
original = "IEC 60050-351:2013/Amd 1:2016"
parsed = PubidNew::Iec.parse(original)
parsed.to_s == original  # => true ✓

# IEC example - short form (no space)
original = "IEC 60050-351:2013/AMD1:2016"
parsed = PubidNew::Iec.parse(original)
parsed.to_s == original  # => true ✓
```

## Format Comparison

Summary of format differences between ISO and IEC:

| Format | ISO | IEC | Indicator |
|--------|-----|-----|-----------|
| **Amendment Short** | AMD, DAM, FDAM | AMD1 (no space) | ISO: case, IEC: space |
| **Amendment Long** | Amd, DAmd, FDAmd | Amd 1 (with space) | ISO: case, IEC: space |
| **Corrigendum Short** | COR, DCOR, FDCOR | COR1 (no space) | ISO: case, IEC: space |
| **Corrigendum Long** | Cor, DCor, FDCor | Cor 1 (with space) | ISO: case, IEC: space |
| **Detection Method** | Case (uppercase vs mixed) | Space (no space vs space) | Different strategies |

## Benefits

The advanced rendering styles system provides:

1. **Round-trip fidelity:** Preserves original format exactly - parse and render back to the same string
2. **Standards compliance:** Supports both official formats used by ISO and IEC
3. **Automatic detection:** No user configuration needed - format detected from parsed string
4. **Extensibility:** Easy to add new format variants for other document types
5. **Consistency:** Same architectural pattern across ISO and IEC flavors
6. **Backward compatibility:** Existing code continues to work unchanged

## Technical Notes

### Why Different Indicators?

- **ISO** uses **case** (uppercase vs title case) because both forms appear in official documents without spaces
- **IEC** uses **space** (no space vs space) as a clearer visual indicator in their formats

### Preservation Priority

The system preserves formats in this order:
1. `original_abbr` (what was actually parsed) - highest priority
2. Format preference (`format_long` parameter)
3. Canonical abbreviation (`abbr.first`) - fallback

### Adding New Formats

To add new format variants:

1. Add to TypedStage TYPED_STAGES array with `short_abbr` and `long_abbr`
2. Builder auto-detects based on existing rules (case for ISO, space for IEC)
3. No changes needed to rendering logic

## Related Documentation

- [V2 Architecture Guide](V2_ARCHITECTURE.adoc) - Overall architecture
- [URN Generation Guide](URN-GENERATION-GUIDE.adoc) - URN format specification
- [README](../README.adoc) - General usage and examples

---

**Last Updated:** 2025-12-09 (Session 101)  
**Applies to:** PubID V2 - ISO and IEC flavors only