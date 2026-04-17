# PubID API Reference

Public API for the PubID gem. All methods below are stable and tested.

## Parsing

### Flavor-Specific Parsing

Each flavor provides a `parse` class method:

```ruby
require 'pubid/iso'
require 'pubid/iec'
require 'pubid/nist'
require 'pubid/ieee'

# Parse returns an identifier object
id = Pubid::Iso.parse("ISO 9001:2015")
id = Pubid::Iec.parse("IEC 62368-1:2023")
id = Pubid::Nist.parse("NIST SP 800-53r5")
id = Pubid::Ieee.parse("IEEE Std 802.3-2018")
```

### Parsing Failures

Parsing errors raise exceptions:

```ruby
begin
  Pubid::Iso.parse("not an identifier")
rescue Parslet::ParseFailed => e
  puts "Parse failed: #{e.message}"
end
```

## Identifier Object

All parsed identifiers share these core attributes and methods.

### Attributes

| Attribute | Type | Description |
|-----------|------|-------------|
| `number` | `Components::Code` | Document number (e.g., `"9001"`) |
| `part` | `Components::Code` | Part number (e.g., `"1"`) |
| `subpart` | `Components::Code` | Subpart number |
| `date` | `Components::Date` | Publication date (year) |
| `edition` | `Components::Edition` | Edition number |
| `publisher` | `Components::Publisher` | Main publisher |
| `copublishers` | `Array<Components::Publisher>` | Co-publishing organizations |
| `type` | `Components::Type` | Document type |
| `stage` | `Components::Stage` | Lifecycle stage |
| `languages` | `Array<Components::Language>` | Language codes |

### Rendering Methods

```ruby
id = Pubid::Iso.parse("ISO 9001:2015/Amd 1:2020")

# Human-readable string
id.to_s     # => "ISO 9001:2015/Amd 1:2020"

# URN (flavors with URN support)
id.to_urn   # => "urn:iso:std:iso:9001:amd:2020:v1"

# Hash export
id.to_h     # => { flavor: "iso", number: "9001", ... }

# JSON export
id.to_json  # => '{"flavor":"iso",...}'
```

### ISO Rendering Options

```ruby
id = Pubid::Iso.parse("ISO 9001:2015")

# Without date
id.to_s(with_date: false)    # => "ISO 9001"

# With edition
id.to_s(with_edition: true)  # => "ISO 9001:2015 ED1"

# Stage format
id.to_s(stage_format_long: true)   # Long stage abbreviations
id.to_s(stage_format_long: false)  # Short stage abbreviations
```

### IEC Rendering Options

```ruby
id = Pubid::Iec.parse("IEC 60050-351:2013")

# With edition
id.to_s(with_edition: true)  # => "IEC 60050-351:2013 ED1"
```

## Utility Methods

### `root`

Traverses supplement chains to return the base document.

```ruby
id = Pubid::Iso.parse("ISO 9001:2015/Amd 1:2020/Cor 1:2021")
id.root.to_s  # => "ISO 9001:2015"

# For base identifiers, returns self
base = Pubid::Iso.parse("ISO 9001:2015")
base.root.to_s         # => "ISO 9001:2015"
base.root.equal?(base) # => true
```

### `exclude`

Returns a new identifier without specified attributes.

```ruby
id = Pubid::Iso.parse("ISO 9001:2015")
id.exclude(:date).to_s  # => "ISO 9001"
```

### `new_edition_of?`

Checks if another identifier is an older edition of the same document.

```ruby
id1 = Pubid::Iso.parse("ISO 9001:2015")
id2 = Pubid::Iso.parse("ISO 9001:2019")

id2.new_edition_of?(id1) # => true
id1.new_edition_of?(id2) # => false

# Raises ArgumentError for different documents
id3 = Pubid::Iso.parse("ISO 9002:2019")
id3.new_edition_of?(id1) # => ArgumentError
```

## Supplement Identifiers

Amendments, corrigenda, and other supplements chain from a base identifier:

```ruby
amd = Pubid::Iso.parse("ISO 9001:2015/Amd 1:2020")

amd.base_identifier.to_s  # => "ISO 9001:2015"
amd.number.number         # => "1"
amd.date.year             # => "2020"
```

Multi-level supplements:

```ruby
id = Pubid::Iso.parse("ISO/IEC 13818-1:2015/Amd 3:2016/Cor 1:2017")

id.class                                # => Corrigendum
id.base_identifier.class                # => Amendment
id.base_identifier.base_identifier.class # => InternationalStandard
```

## Stage Objects

```ruby
id = Pubid::Iso.parse("ISO/DIS 9001")

id.stage.stage_code      # => "dis"
id.typed_stage.abbreviation # => "DIS"
```

## Typed Stages

Typed stages combine a lifecycle stage with a document type:

```ruby
id = Pubid::Iec.parse("IEC/CDV 60038")

id.typed_stage.abbreviation   # => "CDV"
id.typed_stage.stage_code     # => "cdv"
id.typed_stage.name           # => "Committee Draft for Vote"
id.typed_stage.type_code      # => "is"
id.typed_stage.harmonized_stages  # => ["40.00", ...]
```

## Components

### Publisher

```ruby
id = Pubid::Iso.parse("ISO/IEC 27001:2013")
id.publisher.body         # => "ISO"
id.copublishers.first.body # => "IEC"
```

### Code (Number/Part)

```ruby
id = Pubid::Iso.parse("ISO 9001:2015")
id.number.number  # => "9001"

id = Pubid::Iec.parse("IEC TS 62257-9-5:2018")
id.number.number  # => "62257"
id.part.number    # => "9"
id.subpart.number # => "5"
```

### Date

```ruby
id = Pubid::Iso.parse("ISO 9001:2015")
id.date.year  # => "2015"
```

### Edition

```ruby
id = Pubid::Iso.parse("ISO 9001:2015 ED2")
id.edition.number  # => "2"
```

### Language

```ruby
id = Pubid::Iso.parse("ISO/IEC Guide 51:1999(E/F/R)")
id.languages.first.code  # => "E/F/R"
```
