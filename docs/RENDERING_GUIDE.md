# Advanced Rendering Styles Guide

PubID supports multiple rendering formats for identifiers. This guide covers `to_s` options, annotated output, format variants, and round-trip fidelity.

## Overview

All identifiers support `to_s` (human-readable string), `to_urn` (URN), `to_h` (hash), and `to_json` (JSON). ISO and IEC additionally support multiple rendering styles for supplements.

## Basic Rendering

```ruby
require 'pubid/iso'

id = Pubid::Iso.parse("ISO 9001:2015")
id.to_s     # => "ISO 9001:2015"
id.to_urn   # => "urn:iso:std:iso:9001"
id.to_h     # => { flavor: "iso", number: "9001", ... }
id.to_json  # => '{"flavor":"iso","number":"9001",...}'
```

## ISO Rendering Styles

ISO identifiers support `format` and individual parameters:

```ruby
id = Pubid::Iso.parse("ISO 9001:2015")

# RefDatedLong (default) - full format with date
id.to_s  # => "ISO 9001:2015"

# Undated - omit year
id.to_s(with_date: false)  # => "ISO 9001"

# With edition
id.to_s(with_edition: true)  # => "ISO 9001:2015 ED1"
```

### Stage Format Options

```ruby
id = Pubid::Iso.parse("ISO/DIS 9001")

# Long stage format (default)
id.to_s(stage_format_long: true)  # => "ISO/DIS 9001"

# Short stage format
id.to_s(stage_format_long: false)  # => "ISO/DIS 9001"
```

### Format Parameter

The `format` parameter selects a predefined rendering style:

```ruby
id = Pubid::Iso.parse("ISO 9001:2015/Amd 1:2020")

# Different format variants
id.to_s(format: :ref_dated_long)   # => "ISO 9001:2015/Amd 1:2020"
```

## IEC Rendering Styles

IEC identifiers render with space-separated components:

```ruby
require 'pubid/iec'

id = Pubid::Iec.parse("IEC 60050-351:2013")
id.to_s  # => "IEC 60050-351:2013"

# With edition
id.to_s(with_edition: true)  # => "IEC 60050-351:2013 ED1"
```

### Supplement Format Preservation

IEC preserves the exact supplement format (short vs long) that was parsed:

```ruby
# Long form (with space)
id = Pubid::Iec.parse("IEC 60050-351:2013/Amd 1:2016")
id.to_s  # => "IEC 60050-351:2013/Amd 1:2016"

# Short form (no space)
id = Pubid::Iec.parse("IEC 60050-351:2013/AMD1:2016")
id.to_s  # => "IEC 60050-351:2013/AMD1:2016"
```

### ISO Supplement Format Preservation

ISO preserves case-based supplement formats:

```ruby
# Mixed case (long form)
id = Pubid::Iso.parse("ISO 8601:2019/DAmd 1")
id.to_s  # => "ISO 8601:2019/DAmd 1"

# Uppercase (short form)
id = Pubid::Iso.parse("ISO 8601:2019/DAM 1")
id.to_s  # => "ISO 8601:2019/DAM 1"

# Corrigendum
id = Pubid::Iso.parse("ISO/IEC 19115:2003/Cor 1:2006")
id.to_s  # => "ISO/IEC 19115:2003/Cor 1:2006"
```

## Typed Stage Rendering

Different document types render their stages differently:

```ruby
# ISO - slash format for stages
Pubid::Iso.parse("ISO/WD 9001").to_s      # => "ISO/WD 9001"
Pubid::Iso.parse("ISO/CD 9001").to_s      # => "ISO/CD 9001"
Pubid::Iso.parse("ISO/DIS 9001").to_s     # => "ISO/DIS 9001"

# IEC IS - slash format
Pubid::Iec.parse("IEC/PWI 60038").to_s    # => "IEC/PWI 60038"
Pubid::Iec.parse("IEC/NP 60038").to_s     # => "IEC/NP 60038"
Pubid::Iec.parse("IEC/CD 60038").to_s     # => "IEC/CD 60038"
Pubid::Iec.parse("IEC/CDV 60038").to_s    # => "IEC/CDV 60038"

# IEC TS/TR/PAS/Guide - space format for compound abbreviations
Pubid::Iec.parse("IEC/NP TS 62600-3").to_s   # => "IEC NP TS 62600-3"
Pubid::Iec.parse("IEC/WD TR 62048").to_s     # => "IEC WD TR 62048"
Pubid::Iec.parse("IEC/CD Guide 104").to_s    # => "IEC CD Guide 104"
```

## Round-Trip Fidelity

All rendering methods preserve parsed information:

```ruby
# Parse and re-render produces identical output
original = "IEC 60050-351:2013/Amd 1:2016"
Pubid::Iec.parse(original).to_s == original  # => true

# Works across formats
original = "ISO 8601:2019/DAM 1"
Pubid::Iso.parse(original).to_s == original  # => true
```

## Machine-Readable Formats

### Hash Export

```ruby
id = Pubid::Iso.parse("ISO 9001:2015/Amd 1:2020")
id.to_h
# => {
#      flavor: "iso",
#      type: "amendment",
#      publisher: "ISO",
#      number: "9001",
#      year: "2015",
#      supplements: [{ type: "amendment", number: "1", year: "2020" }],
#      urn: "urn:iso:std:iso:9001:amd:2020:v1"
#    }
```

### JSON Export

```ruby
id.to_json  # => JSON string of the hash above
```

## Implementation

Rendering is implemented via the **Renderer pattern**:

- `lib/pubid/renderers/base.rb` — abstract base class with annotation helpers, shared by all flavor renderers
- `lib/pubid/renderers/human_readable.rb` — ISO's dedicated human-readable renderer
- `lib/pubid/renderers/mr_string.rb` — MR string renderer
- `lib/pubid/renderers/urn.rb` — URN renderer
- `lib/pubid/{flavor}/renderer.rb` — per-flavor human-readable renderer (19 flavors)
- `lib/pubid/{flavor}/urn_generator.rb` — URN generation
- `lib/pubid/format_registry.rb` — maps format symbols (`:human`, `:urn`, `:mr_string`) to renderer classes

Each flavor registers its `:human` renderer via a per-flavor `FormatRegistry` that inherits from the global `Pubid::Identifier.format_registry`. Adding a new output format (BibXML, JSON-LD, annotated HTML) requires only a new Renderer class and a single `register` call — no changes to identifier classes.

For flavors with type-specific rendering logic (BSI's 30+ identifier types, CEN/CENELEC's draft stages, NIST's 4 output formats), the per-flavor renderer dispatches internally based on the identifier's class or type.
