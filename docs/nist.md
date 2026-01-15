# NIST Documentation

## Overview

The NIST flavor handles identifiers for National Institute of Standards and Technology (NIST) standards and related documents. It supports both current NIST publications and historical National Bureau of Standards (NBS) documents. The flavor manages 19+ distinct document series including Special Publications (SP), Federal Information Processing Standards (FIPS), Technical Notes (TN), Handbooks (HB), Interagency Reports (IR), and various specialized series. It supports complex edition/revision patterns, supplements, translations, updates, and multiple rendering formats (short, long, abbreviated, machine-readable).

## Architecture

This flavor follows the PubID v2 three-layer architecture pattern:

1. **Parser** (`parser.rb`) - Parslet PEG grammar for syntax parsing
   - Converts input strings into structured hash trees
   - Extensive preprocessing for format normalization (50+ normalization rules)
   - Handles both short format (NIST SP 800-53) and machine-readable format (NIST.SP.800-53)
   - Supports historical NBS patterns and modern NIST patterns
   - Parses complex edition/revision patterns (e2, r5, rev2013, etc.)
   - Handles supplement notations (supp, suppJan1924, date ranges)
   - Supports update notations (/Upd1-2015, -upd)
   - Parses CRPL range patterns (2_3-1A)
   - Handles volume and version notation (v2, ver1.0)
   - Extracts translation language codes

2. **Builder** (`builder.rb`) - Transforms parse trees to domain objects via Scheme registry
   - Casts parsed hash values to V2 component objects (Edition, Volume, Part, Version, Update, Translation)
   - Uses Scheme registry for series-to-class lookup via `locate_identifier_klass()`
   - Instantiates appropriate identifier class based on series code
   - Handles special cases: CS emergency patterns, CIRC supplements, compound numbers
   - Supports recursive base identifier parsing for CIRC supplements
   - Extracts revision patterns from number strings (r5, r1963, revJun1992)
   - Creates proper compound numbers from first_number and second_number

3. **Identifier** (`identifiers/`) - Lutaml::Model domain classes with rendering logic
   - Base identifier class for all NIST/NBS series
   - Specialized classes for major series (SP, FIPS, IR, HB, TN, CIRC, etc.)
   - Multi-format rendering support (:short, :long, :abbrev, :mr)
   - V2 component objects with proper serialization (Edition, Volume, Part, Version, Update, Translation)
   - Legacy attribute support for backward compatibility

## Components

### Flavor-Specific Components

| Component | File | Purpose | Attributes |
|-----------|------|---------|------------|
| `Publisher` | `components/publisher.rb` | NIST or NBS publisher | `publisher` |
| `Code` | `components/code.rb` | Generic string values (number, parts) | `number` |
| `Edition` | `components/edition.rb` | Edition with type and id (e2, r5, -3) | `type`, `id`, `additional_text`, `original_prefix` |
| `Volume` | `components/volume.rb` | Volume notation (v6) | `value` |
| `Part` | `components/part.rb` | Part notation (pt1, n1) | `type`, `value` |
| `Version` | `components/version.rb` | Version with dotted notation (ver1.0.2) | `value` |
| `Update` | `components/update.rb` | Update with number and year | `number`, `year`, `month`, `prefix` |
| `Translation` | `components/translation.rb` | Translation language code | `code` |
| `Stage` | `components/stage.rb` | Stage with id and type (ipd, wd, prd) | `id`, `type` |

### Shared Components Used

| Component | From | Purpose in this flavor |
|-----------|------|------------------------|
| `Type` | `lib/pubid_new/components/type.rb` | Not used - series determines type |
| `Date` | `lib/pubid_new/components/date.rb` | Date component for FIPS and historical dates |

## Identifier Classes

### Base Identifiers

#### Base

- **File:** `lib/pubid_new/nist/identifiers/base.rb`
- **Parent:** `Lutaml::Model::Serializable`
- **Purpose:** The base class for all NIST/NBS identifiers. Handles the complete NIST identifier format with publisher, series, number, edition, revision, parts, translations, updates, and various notations.
- **Components Used:** `publisher`, `series`, `number`, `parts`, `edition`, `edition_component`, `volume`, `part`, `stage`, `version_component`, `update_component`, `translation_component`, `parsed_format`, and legacy attributes
- **Patterns Supported:**
  - `NIST SP 800-53` → Special Publication
  - `NIST SP 800-53r5` → With revision
  - `NIST SP 800-57pt1r4` → With part and revision
  - `NIST SP 800-53 Rev.4` → With verbose revision
  - `NIST FIPS 201` → Federal Information Processing Standard
  - `NIST IR 84-2946` → Interagency Report with compound number
  - `NBS CIRC 101e2` → Historical Circular with edition
  - `NIST SP 800-53/Upd1-2015` → With update
  - `NIST SP 800-53 (es)` → With translation
- **Typed Stages:** Not applicable (NIST doesn't use typed stages like ISO)
- **Rendering Formats:** :short, :long, :abbrev, :mr

#### SpecialPublication

- **File:** `lib/pubid_new/ist/identifiers/special_publication.rb`
- **Parent:** `Base`
- **Purpose:** NIST Special Publications (SP) are the primary current NIST document series covering a wide range of technical topics including cybersecurity, information technology, and metrology.
- **Components Used:** Same as Base
- **Patterns Supported:**
  - `NIST SP 800-53` → Basic SP
  - `NIST SP 800-53r5` → With revision
  - `NIST SP 800-57pt1` → With part
  - `NIST SP 800-53-A` → With letter suffix part
  - `NIST SP 800-53 Rev.4` → With verbose revision
  - `NIST SP 800-53 ver1.0` → With version
  - `NIST.SP.800-53` → Machine-readable format
  - `NIST SP 800-53 (es)` → With translation
- **Typed Stages:** Single published stage
  - `SP`, `NIST SP` (published) - Published

#### FederalInformationProcessingStandards

- **File:** `lib/pubid_new/nist/identifiers/federal_information_processing_standards.rb`
- **Parent:** `Base`
-**Purpose:** Federal Information Processing Standards (FIPS) are government-wide standards for information technology.
- **Components Used:** Same as Base
- **Patterns Supported:**
  - `FIPS 201` → Basic FIPS
  - `FIPS 201-2` → With part
  - `FIPS 201A` → With letter suffix
  - `FIPS 201r1` → With revision
- **Typed Stages:** Single published stage
  - `FIPS` (published) - Published

#### InteragencyReport

- **File:** `lib/pubid_new/nist/identifiers/interagency_report.rb`
- **Parent:** `Base`
- **Purpose:** Interagency Reports (IR) document research and technical work conducted by NIST for other agencies.
- **Components Used:** Same as Base
- **Patterns Supported:**
  - `NIST IR 84-2946` → With compound number
  - `NIST IR 84-2946pt1` → With part (pt notation)
  - `NBS IR 80-2073 v2` → With volume
- **Typed Stages:** Single published stage
  - `IR` (published) - Published

#### Handbook

- **File:** `lib/pubid_new/nist/identifiers/handbook.rb`
- **Parent:** `Base`
- **Purpose:** Handbooks (HB) provide practical guidance and technical information.
- **Components Used:** Same as Base
- **Patterns Supported:**
  -`NIST HB 44` → Basic Handbook
- **Typed Stages:** Single published stage
  - `HB` (published) - Published

#### TechnicalNote

- **File:** `lib/pubid_new/nist/identifiers/technical_note.rb`
- **Parent:** `Base`
- **Purpose:** Technical Notes (TN) document technical research and methodologies.
- **Components Used:** Same as Base
- **Patterns Supported:**
  - `NIST TN 1297` → Basic TN
  - `NBS TN 101e2-1915` → Historical TN with edition and year
- **Typed Stages:** Single published stage
  - `TN` (published) - Published

#### Circular

- **File:** `lib/pubid_new/nist/identifiers/circular.rb`
- **Parent:** `Base`
- **Purpose:** Circulars (CIRC) are historical NBS publications for disseminating information.
- **Components Used:** Same as Base
- **Patterns Supported:**
  - `NBS CIRC 101e2` → With edition
  - `NBS CIRC 101e2.1915` → With edition and year (dot separator)
  - `NBS CIRC 101e2rev1908` → With revision year (dot separator)
  - `NBS CIRC 101e2-June1908` → With month+year (dot separator)
  - `NBS CIRC v2` → With volume
  - `NBS CIRC 2_3-1` → CRPL range pattern
- **Typed Stages:** Single published stage
  - `CIRC`, `NBS CIRC` (published) - Published

#### CircularSupplement

- **File:** `lib/pubid_new/nist/identifiers/circular_supplement.rb`
- **Parent:** `Identifier` (with base_identifier)
- **Purpose:** Supplements to NBS Circulars with date range or year notation.
- **Components Used:** `base_identifier`, `edition`, `supplement_date_range_start`, `supplement_date_range_end`
- **Patterns Supported:**
  - `NBS CIRC 101e2supp` → Supplement to edition
  - `NBS CIRC 25supp-1924` → Supplement with year
  - `NBS CIRC 24suppJan1924` → Supplement with month+year
  - `NBS CIRC suppJun1925-Jun1926` → Date range supplement (no base)
- **Rendering Formats:** Renders supplement notation after base

#### CrplReport

- **File:** `lib/pubid_new/nist/identifiers/crpl_report.rb`
- **Parent:** `Base`
- **Purpose:** CRPL (Central Radio Propagation Laboratory) Reports from historical NBS work.
- **Components Used:** Same as Base
- **Patterns Supported:**
  - `NBS CRPL 2-3-1` → CRPL range pattern
  - `NBS CRPL 2-3-1A` → CRPL with supplement letter
- **Typed Stages:** Single published stage
  - `CRPL`, `NBS CRPL` (published) - Published

#### CommercialStandard

- **File:** `lib/pubid_new/identifiers/commercial_standard.rb`
- **Parent:** `Base`
- **Purpose:** Commercial Standards (CS) were specifications for commercial products.
- **Components Used:** Same as Base
- **Patterns Supported:**
  - `NBS CS 100-1` → Basic CS
  - `NBS CS 100e1` → CS with edition
  - `NBS CS 104e3` → CS with edition
- **Typed Stages:** Single published stage
  - `CS`, `NBS CS` (published) - Published

#### CommercialStandardEmergency

- **File:** `lib/pubid_new/identifiers/commercial_standard_emergency.rb`
- **Parent:** `Base`
- **Purpose:** Emergency Commercial Standards (CS-E) for urgent wartime product specifications.
- **Components Used:** Same as Base
- **Patterns Supported:**
  - `NBS CS-E 104-43` → Emergency CS (e104-43 → 104 from 1943)
- **Typed Stages:** Single published stage
  - `CS-E`, `NBS CS-E` (published) - Published

#### CommercialStandardsMonthly

- **File:** `lib/pubid_new/identifiers/commercial_standards_monthly.rb`
- **Parent:** `Base`
- **Purpose:** Commercial Standards Monthly (CSM) periodical with v#n# notation.
- **Components Used:** Same as Base, plus `volume` and `issue_number` as Part component
- **Patterns Supported:**
  - `NBS CSM v6n12` → Volume 6, Number 12
- **Typed Stages:** Single published stage
  - `CSM`, `NBS CSM` (published) - Published

#### Report

- **File:** `lib/pubid_new/identifiers/report.rb`
- **Parent:** `Base`
- **Purpose:** Reports (RPT) document various technical studies and findings.
- **Components Used:** Same as Base
- **Patterns Supported:**
  - `NIST RPT 1011` → Basic Report
- **Typed Stages:** Single published stage
  - `RPT` (published) - Published

#### Monograph

- **File:** `lib/pubid_new/identifiers/monograph.rb`
- **Parent:** `Base`
- **Purpose:** Monographs (MONO) are comprehensive treatments of single topics.
- **Components Used:** Same as Base
- **Patterns Supported:**
  - `NIST MONO 1` → Basic Monograph
  - `NBS MONO 1` → Historical Monograph
- **Typed Stages:** Single published stage
  - `MONO`, `NBS MONO` (published) - Published

#### MiscellaneousPublication

- **File:** `lib/pubid_new/identifiers/miscellaneous_publication.rb`
- **Parent:** `Base`
- **Purpose:** Miscellaneous Publications (MP) for documents not fitting other categories.
- **Components Used:** Same as Base
- **Patterns Supported:**
  - `NIST MP 1` → Basic MP
- **Typed Stages:** Single published stage
  - `MP` (published) - Published

#### GrantContractorReport

- **File:** `lib/pubid_new/ist/identifiers/grant_contractor_report.rb`
- **Parent:** `Base`
- **Purpose:** Grant/Contractor Reports (GCR) document work done under grants or contracts.
- **Components Used:** Same as Base
- **Patterns Supported:**
  - `NIST GCR 85-3273-37` → Multi-dash pattern
- **Typed Stages:** Single published stage
  - `GCR` (published) - Published

#### Ncstar

- **File:** `lib/pubid_new/nist/identifiers/ncstar.rb`
- **Parent:** `Base`
- **Purpose:** NCSTAR reports from the National Construction Safety Team.
- **Components Used:** Same as Base
- **Patterns Supported:**
  - `NIST NCSTAR 1` → Basic NCSTAR
  - `NIST NCSTAR 1-2` → With part
- **Typed Stages:** Single published stage
  - `NCSTAR` (published) - Published

#### Owmwp

- **File:** `lib/pubid_new/nist/identifiers/owmwp.rb`
- **Parent:** `Base`
- **Purpose:** Office of Weights and Measures Water Margin Publications.
- **Components Used:** Same as Base
- **Patterns Supported:**
  - `NIST OWMWP 1` → Basic OWMWP
- **Typed Stages:** Single published stage
  - `OWMWP` (published) - Published

#### Nsrds

- **File:** `lib/pubid_new/nist/identifiers/nsrds.rb`
- **Parent:** `Base`
- **Purpose:** National Standard Reference Data Series (NSRDS) from historical NBS work.
- **Components Used:** Same as Base
- **Patterns Supported:**
  - `NBS NSRDS-NBS 1` → Compound series
- **Typed Stages:** Single published stage
  - `NSRDS`, `NSRDS-NBS` (published) - Published

#### LetterCircular

- **File:** `lib/pubid_new/nist/identifiers/letter_circular.rb`
- **Parent:** `Base`
- **Purpose:** Letter Circulars (LCIRC or LC) were informal circular communications.
- **Components Used:** Same as Base
- **Patterns Supported:**
  - `NBS LCIRC 145r6` → With revision
  - `NBS LC 1128r1995` → With 4-digit revision year
  - `NIST LC 500` → Modern Letter Circular
- **Typed Stages:** Single published stage
  - `LCIRC`, `NBS LCIRC`, `LC`, `NIST LC` (published) - Published

## Scheme Registry

The `Scheme` class (`lib/pubid_new/nist/scheme.rb`) is the central registry for this flavor.

### Registry Methods

- **`identifiers`** - Array of all registered identifier classes
  ```ruby
  IDENTIFIERS = [
    Identifiers::SpecialPublication,
    Identifiers::FederalInformationProcessingStandards,
    Identifiers::InteragencyReport,
    Identifiers::Handbook,
    Identifiers::TechnicalNote,
    Identifiers::Circular,
    Identifiers::CircularSupplement,
    Identifiers::CrplReport,
    Identifiers::Report,
    Identifiers::Monograph,
    Identifiers::MiscellaneousPublication,
    Identifiers::GrantContractorReport,
    Identifiers::Ncstar,
    Identifiers::Owmwp,
    Identifiers::Nsrds,
    Identifiers::LetterCircular,
    Identifiers::CommercialStandard,
    Identifiers::CommercialStandardEmergency,
    Identifiers::CommercialStandardsMonthly,
    Identifiers::Base, # Fallback for unmapped series
  ].freeze
  ```

- **`typed_stages`** - Aggregate TYPED_STAGES from all identifier classes
  ```ruby
  def typed_stages
    identifiers.flat_map { |klass| klass.typed_stages }
  end
  ```

- **`locate_typed_stage_by_abbr(abbr)`** - Find stage by abbreviation
  - Returns `TypedStage` object or raises `ArgumentError`
  - Searches through all registered TYPED_STAGES
  - Case-insensitive matching

- **`locate_identifier_klass(parsed_hash)`** - Select class by series and pattern
  - Returns identifier class based on series code and parsed data
  - Handles special cases: CIRC supplements, CS emergency, CSM patterns
  - Falls back to `Identifiers::Base` for unmapped series

- **`has_supplement?(parsed_hash)`** - Check for supplement indicators
  - Returns true if any supplement notation is present
  - Used to determine if `CircularSupplement` should be used

### Parser Instance

```ruby
# Parser is NOT memoized in NIST
# Parser.parse() is called directly in Identifier.parse()
```

## Rendering Examples

### Short Format (`:short`)

| Identifier Pattern | Rendered Output |
|-------------------|-----------------|
| `NIST SP 800-53` | `NIST SP 800-53` |
| `NIST SP 800-53r5` | `NIST SP 800-53r5` |
| `NIST SP 800-57pt1` | `NIST SP 800-57pt1` |
| `NIST SP 800-53-A` | `NIST SP 800-53A` |
| `NIST SP 800-53 ver1.0` | `NIST SP 800-53 ver1.0` |
| `NIST FIPS 201` | `FIPS 201` |
| `NBS CIRC 101e2` | `NBS CIRC 101e2` |

### MR Format (`:mr`)

| Identifier Pattern | Rendered Output |
|-------------------|-----------------|
| `NIST.SP.800-53` | `NIST.SP.800-53` |
| `NIST.SP.800-53r5` | `NIST.SP.800-53r5` |
| `NIST.FIPS.201` | `NIST.FIPS.201` |
| `NBS.CIRC.101e2` | `NBS.CIRC.101e2` |

### Long Format (`:long`)

| Identifier Pattern | Rendered Output |
|-------------------|-----------------|
| `NIST SP 800-53` | `NIST Special Publication 800-53` |
| `NIST SP 800-53r5` | `NIST Special Publication 800-53 Rev. 5` |
| `NBS CIRC 101e2` | `National Bureau of Standards Circular 101e2` |

### Abbreviated Format (`:abbrev`)

| Identifier Pattern | Rendered Output |
|-------------------|-----------------|
| `NIST SP 800-53` | `Natl. Inst. Stand. Technol. Spec. Publ. 800-53` |
| `NIST FIPS 201` | `Fed. Inf. Proc. Stand. 201` |

## Parser Rules

### Main Rule

```ruby
rule(:identifier) do
  circ_supplement_identifier |
    mr_identifier |
    (compound_series | publisher >> series) >> report_number >> parts
end
```

### Component Rules

```ruby
# Publisher (NIST or NBS)
rule(:publisher) do
  (str("NBS") | str("NIST")).as(:publisher)
end

# Series (compound and simple)
rule(:compound_series) do
  # Must check longest patterns first
  str("NBS CIRC") | str("NBS CRPL") | str("NBS CS") |
  str("NIST LCIRC") | str("NIST LC") | etc.
end

rule(:simple_series) do
  str("SP") | str("FIPS") | str("IR") | str("HB") |
  str("TN") | str("CIRC") | str("CS") | etc.
end

# First number with edition/supplement patterns
rule(:first_number) do
  # Edition with year: "101e2-1915"
  (digits >> str("e") >> digits >> str("rev") >> digits) |
  # Edition with supplement: "101e2supp"
  (digits >> str("e") >> digits >> str("supp")) |
  # Edition only: "800-53"
  digits |
  # Emergency CS: "e104"
  (str("e") >> digits)
end

# Second number (after dash)
rule(:second_number) do
  # CRPL range: "2_3-1A"
  (digits >> str("_") >> digits >> dash >> digits >> upper_letter.maybe) |
  # Number with pt suffix: "57pt1"
  (digits >> str("pt") >> digits) |
  # Letter suffix: "56A"
  (digits >> upper_letter)
end

# Edition component
rule(:edition) do
  # Edition: "e2"
  (str("e") >> digits).as(:edition_e) |
  # Revision: "r5"
  (str("r") >> digits).as(:edition_r) |
  # Verbose revision: "rev2013"
  (str("rev") >> digits).as(:edition_rev) |
  # Historical: "-3"
  (dash >> match("[1-9]")).as(:edition_historical)
end

# Volume
rule(:volume) do
  (str("v") | str(" Vol.")) >> digits >> upper_letter.maybe
end

# Part
rule(:part) do
  (str("pt") | str("p") | str("P")) >> digits >>
    (str("r") >> digits).maybe >>
    (str("add") >> digits).maybe
end

# Version
rule(:version) do
  # Verbose: "ver1.0.2"
  ((space | dot).maybe >> str("ver") >> digits >> (dot >> digits).repeat) |
  # Short: "v1.0"
  ((dash | space).maybe >> str("v") >> digits >> (dot >> digits).repeat)
end

# Update
rule(:update) do
  (str("/Upd") | str("/upd") | str("-upd")) >>
    digits.maybe >>
    (dash >> digits >> (dash >> digits).maybe).maybe
end

# Supplement
rule(:supplement) do
  str("supp") >>
    (str("rev") | # supprev
     month_abbrev >> digits | # Jan1924
     digits >> str("/") >> digits | # 3/1926
     digits).maybe
end
```

### Special Patterns

```ruby
# Machine-readable format
rule(:mr_identifier) do
  hash_prefix.maybe >>
    publisher >> dot >>
    simple_series >> dot >>
    report_number >>
    (str("_") >> digits).maybe >> # Edition: 1648_2009
    (dot >> digits).repeat(0, 3) >>
    upper_letter.maybe >>
    edition.maybe >>
    update.maybe >>
    parts.repeat
end

# CIRC supplement identifier
rule(:circ_supplement_identifier) do
  (str("NBS CIRC") | str("NBS LCIRC")) >> space >>
    (
      # Date range supplement (no base)
      (str("supp") >> month_abbrev >> digits >> dash >> month_abbrev >> digits) |
      # With base + supplement
      (digits >> str("e") >> digits | digits).as(:base_portion) >>
      str("supp") >>
      (month_abbrev >> digits | dash >> digits | str("")).as(:supplement_edition)
    )
end
```

## Builder Logic

### Identifier Class Selection

The Builder determines which identifier class to instantiate based on:

1. **CIRC supplement check** - If `:supplement_date_range` or `:base_portion` → `CircularSupplement`
2. **Series code lookup** - Use `locate_identifier_klass()` with series from parsed data
3. **Special pattern handling** - CS emergency, CSM patterns handled before series lookup
4. **Fallback** - `Identifiers::Base` for unmapped series

### Component Casting

Special casting logic in Builder's `cast()` method:

```ruby
# Series (compound vs simple)
when :series
  # "NBS CIRC" → {publisher: "NBS", series: "CIRC"}
  # "SP" → {series: "SP"}

  if str_value.start_with?("NBS ")
    publisher_extracted = "NBS"
    str_value = str_value.sub("NBS ", "")
    return {
      publisher: Components::Publisher.new(publisher: publisher_extracted),
      series: Components::Code.new(number: str_value),
    }
  end

# First number (edition/supplement patterns)
when :first_number
  # "101e2-1915" → {number: "101", edition: Edition(type: "e", id: "2", additional_text: "1915")}
  # "e104-43" (CS emergency) → {number: "104", edition: Edition(type: "e", id: "1943")}
  # "154supprev" → {number: "154", supplement: "", supplement_has_revision: true}
  # "13e2rev1908" → {number: "13", edition: Edition(type: "e", id: "2", additional_text: "1908")}
  # "25suppJan1924" → {number: "25", supplement: "Jan1924"}
  # "100e1" → {number: "100", edition: Edition(type: "e", id: "1")}
  # "e2" (bare edition) → {edition: Edition(type: "e", id: "2")}

# Second number (part and revision patterns)
when :second_number
  # "pt3r1" → {part: Part(type: "pt", value: "3"), edition: Edition(type: "r", id: "1")}
  # "56A" (for IR, FIPS, etc.) → preserved as letter suffix in MR format
  # "22r1A" → kept as-is for pattern matching

# CRPL range
when :crpl_range
  # "2_3-1A" → {second_number: "2", part: Part(type: "pt", value: "3-1"), supplement: "A"}

# Edition component (V2)
when :edition_e
  # "e2" → Edition(type: "e", id: "2")
  { edition: Components::Edition.new(type: "e", id: edition_id),
    edition_component: Components::Edition.new(type: "e", id: edition_id) }

when :edition_r
  # "r5" → Edition(type: "r", id: "5")
  { edition: Components::Edition.new(type: "r", id: revision_id),
    revision: "r#{revision_id}" }

when :edition_rev
  # "rev2013" → Edition(type: "r", id: "2013")
  { edition: Components::Edition.new(type: "r", id: edition_id),
    revision: "r#{edition_id}" }

# Update component (V2)
when :update
  # "/Upd1-2015" → Update(number: "1", year: "2015", month: nil, prefix: "slash")
  # "-upd" → Update(number: "1", year: nil, month: nil, prefix: "dash")

# Translation component (V2)
when :translation
  # "(es)" or " es" → Translation(code: "spa") [normalized]
  code = value.to_s.strip.downcase
  normalized_code = TRANSLATION_MAP[code] || code
  { translation_component: Components::Translation.new(code: normalized_code) }
```

### Compound Number Construction

The Builder constructs compound numbers from first_number and second_number:

```ruby
# Special patterns:
if first_num && second_num
  # CS Emergency: "e104-43" → number="104", edition_year="1943"
  if first_num.value =~ /^e(\d{3})$/ && second_num.value =~ /^\d{2}$/
    identifier.number = Components::Code.new(number: number_part)
    identifier.edition = Components::Edition.new(type: "e", id: edition_year)

  # Edition+year: "11e2-1915" → number="11", Edition(e2.1915)
  elsif first_num.value =~ /^(\d+)e(\d+)$/ && second_num.value =~ /^\d{4}$/
    identifier.number = Components::Code.new(number: number_part)
    identifier.edition = Components::Edition.new(type: "e", id: edition_id, additional_text: year_part)

  # Supplement: "25supp-1924" → number="25", supplement="1924"
  elsif first_num.value =~ /^(\d+)supp$/ && second_num.value =~ /^\d{4}$/
    identifier.number = Components::Code.new(number: number_part)
    identifier.supplement = year_part

  # Normal compound: "800-57" → number="800-57"
  else
    compound_value = "#{first_num.value}-#{second_num.value}"
    identifier.number = Components::Code.new(number: compound_value)
  end
end
```

### IR Special Handling

IR identifiers need special handling for year patterns:

```ruby
# For IR, "84-2946" should NOT become "84e2946" (year is part of compound number, not edition)
# The preprocessing converts "84-2946" to "84e2946", so we need to convert it back

is_ir = parsed_hash[:series].to_s.include?("IR")

if is_ir && identifier.number.value.to_s =~ /^(\d+)e(\d{4})$/
  # Convert back to compound number format
  number_part = match_data[1]  # "84"
  year_part = match_data[2]     # "2946"

  identifier.number = Components::Code.new(number: "#{number_part}-#{year_part}")
  identifier.edition = nil  # Clear incorrectly set edition
end
```

## Preprocessing

This flavor uses extensive preprocessing to normalize input before parsing:

| Pattern | Input | Output | Purpose |
|---------|-------|--------|---------|
| Lowercase publisher | `nist sp 800-53` | `NIST SP 800-53` | Normalize publisher case |
| Lowercase series | `NIST sp 800-53` | `NIST SP 800-53` | Normalize series case |
| Edition year normalization | `NIST SP 330-2019` | `NIST SP 330e2019` | Convert -YYYY to eYYYY |
| Roman numeral conversion | `1011-I-2.0` | `1011 v1 ver2.0` | Convert Roman numerals to Arabic |
| Edition-year normalization (compound) | `1019r1963` | `1019 r1963` | Separate revision from number |
| Revision with space | `4743rJun1992` | `4743 rJun1992` | Add space before revision |
| Letter suffix normalization | `800-56a` | `800-56A` | Uppercase letter suffixes |
| Volume separation | `80-2073 2` | `80-2073 v2` | Convert to volume notation |
| Draft normalization | `8270draft2` | `8270 -draft 2` | Add space before draft |
| Update normalization | `8115r1-upd` | `8115 r1-upd` | Add space before update |
| Part normalization | `800-57p1` | `800-57 pt1` | Normalize part notation |
| Version normalization | `-v1.0` | `.ver1.0` | Convert to verbose notation |
| Supplement normalization | `154suprev` | `154supprev` | Fix supplement typo |
| Translation normalization | `(es)` | normalized | Normalize language codes |

Preprocessing is **explicit** and **format-preserving** - the original format is detected and stored for exact reproduction during rendering.

## Testing

### Test Coverage

- **Unit tests:** `spec/pubid_new/nist/components/`
- **Parser tests:** `spec/pubid_new/nist/parser_spec.rb`
- **Builder tests:** `spec/pubid_new/nist/builder_spec.rb`
- **Identifier tests:** `spec/pubid_new/nist/identifiers/`
- **Integration tests:** `spec/integration/nist_`

### Fixtures

Located in: `spec/fixtures/nist/identifiers/`

- **Pass tests:** `pass/` - Valid patterns that should parse successfully
  - `base.txt` - Base identifier patterns
  - `special_publication.txt` - SP patterns
  - `federal_information_processing_standards.txt` - FIPS patterns
  - `circular.txt` - CIRC patterns
- **Fail tests:** `fail/` - Invalid patterns that should raise errors

### Coverage Status

The NIST flavor has comprehensive test coverage with ~90%+ coverage for all identifier classes and rendering patterns.

## Migration Notes

### V1 to V2 Changes

**Major architectural changes:**
1. **Three-layer separation** - Parser, Builder, and Identifier are completely separate
2. **Registry-based architecture** - Scheme class manages series-to-class lookups
3. **V2 component objects** - Edition, Volume, Part, Version, Update, Translation are proper Lutaml::Model objects
4. **TYPED_STAGES array** - Minimal usage (unlike ISO/IEC), mainly for published stages
5. **Enhanced preprocessing** - 50+ normalization rules for format consistency
6. **Compound number construction** - First + second number logic in Builder

**Breaking changes:**
- `Pubid::Nist::Identifier` → `PubidNew::Nist::Identifiers::*` (specific classes)
- `edition_year`/`edition_month` replaced by `Edition` component object
- `revision` replaced by `Edition` component with type="r"
- `version` replaced by `Version` component object
- `update` replaced by `Update` component object
- `translation` replaced by `Translation` component object

**Migration guide:**
1. Replace `Pubid::Nist.parse()` with `PubidNew::Nist.parse()`
2. Use specific identifier classes instead of generic `Identifier`
3. Access edition via `identifier.edition` (returns Edition component)
4. Use `identifier.edition_component` for V2 component access
5. Access revision via `identifier.edition` (Edition with type="r")
6. Use `identifier.update_component` for V2 component access
7. Use `identifier.translation_component` for V2 component access

## References

- **Specification:** NIST Special Publications 800-XX series
- **Examples:** NIST Publications Catalog (https://nvl.pubidnist.gov/nistpubs/)
- **Related implementations:**
  - ISO flavor (similar three-layer architecture)
  - IEEE flavor (similar component objects)

---

## Appendix: Design Decisions

### Registry-Based Series Mapping

**Context:** NIST has 19+ document series with complex pattern variations. Some series have special handling (CS emergency, CSM v#n#, CIRC supplements).

**Decision:** Use Scheme registry with `locate_identifier_klass()` method that checks series code and special patterns.

**Rationale:**
- Single source of truth for series-to-class mapping
- Easy to add new series without modifying Builder
- Special patterns handled in Scheme before registry lookup
- Fallback to Base class for unmapped series (graceful degradation)

**Alternatives considered:**
- Hardcoded series-to-class map in Builder - Rejected (violates registry principle)
- Separate validation before parsing - Rejected (adds complexity)

### Extensive Preprocessing

**Context:** NIST identifiers have many format variations from historical documents (50+ years of NBS + NIST). Input can be messy (lowercase, missing spaces, wrong separators).

**Decision:** Apply 50+ preprocessing rules before parsing to normalize input.

**Rationale:**
- Simplifies parser grammar (fewer special cases)
- Consistent internal representation
- Format detection (MR vs short format)
- Preserves original format for rendering

**Alternatives considered:**
- Handle all variations in parser - Rejected (grammar would be unmaintainable)
- Require strict input format - Rejected (breaks real identifiers)

### Edition Component Model

**Context:** NIST has complex edition patterns (e2, r5, rev2013, -3, e2-1915) that combine type, id, and additional information.

**Decision:** Create unified Edition component with type, id, additional_text, and original_prefix attributes.

**Rationale:**
- Single component handles all edition patterns
- Type distinguishes editions (e), revisions (r), historical (-)
- Additional text captures year/month information
- Original prefix preserves exact format for rendering

**Alternatives considered:**
- Separate components for each pattern type - Rejected (too many components)
- String-based edition attribute - Rejected (loses structure)

### CircularSupplement Wrapper

**Context:** CIRC supplements can be date ranges (no base) or supplements to base identifiers with edition.

**Decision:** Create CircularSupplement wrapper class with base_identifier attribute.

**Rationale:**
- Clean separation between base and supplement
- Recursive parsing for base identifier
- Handles both date range supplements and edition supplements
- Extensible for other CIRC supplement patterns

**Alternatives considered:**
- Flatten into single identifier - Rejected (loses base/supplement relationship)
- Store supplement as attribute on base - Rejected (mixes concerns)

### Compound Number Logic

**Context:** NIST uses compound numbers (first_number-second_number) for various purposes: parts, revisions, CRPL ranges, CS emergency years.

**Decision:** Implement pattern-matching logic in Builder to determine semantics based on series and pattern format.

**Rationale:**
- Different patterns have different semantics depending on series
- IR preserves compound number (84-2946) while SP creates edition (800-53r5)
- CRPL range uses underscore notation (2_3-1A)
- CS emergency uses e-prefix with year (e104-43)

**Alternatives considered:**
- Always create edition from compound - Rejected (breaks IR semantics)
- Always preserve compound number - Rejected (breaks SP revision patterns)
