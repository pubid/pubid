# NIST V1 Features Documentation

**Created:** 2025-12-22 (Session 181, Phase 1)
**Purpose:** Complete documentation of V1 features for V2 migration

---

## Critical V1 Features to Preserve

### 1. Stage System

**V1 Implementation:** `lib/pubid/nist/stage.rb`

**Structure:**
- `id`: i, f, 1-9 (Initial, Final, numbered iterations)
- `type`: pd, wd, prd (Public Draft, Work-in-Progress Draft, Preliminary Draft)
- **Combined**: `#{id}#{type}` → "ipd", "fpd", "2pd", etc.

**Rendering:**
```ruby
# Short format
Stage.new(id: "i", type: "pd").to_s(:short) # => "ipd"
Stage.new(id: "f", type: "pd").to_s(:short) # => "fpd"
Stage.new(id: "2", type: "pd").to_s(:short) # => "2pd"

# Long format
Stage.new(id: "i", type: "pd").to_s(:long) # => "(Initial Public Draft)"
Stage.new(id: "f", type: "pd").to_s(:long) # => "(Final Public Draft)"
```

**YAML Config:** `stages.yaml`
```yaml
id:
  i: Initial
  f: Final
  "1": Initial
  "2": Second
  "3": Third
  # ... up to "9": Ninth
type:
  pd: Public Draft
  wd: Work-in-Progress Draft
  prd: Preliminary Draft
```

**Parser Patterns:**
- Old style (parenthetical): `(IPD)` → parsed at start
- New style (inline): ` ipd` or `.ipd` → parsed at end
- Case-insensitive: `IPD`, `ipd`, `Ipd` all valid

**Examples:**
- `NIST SP 800-53r5 ipd` → stage.id="i", stage.type="pd"
- `NIST SP(IPD) 800-53r5` → same (old style)
- `NIST.SP.800-66r2.ipd` → machine-readable format

---

### 2. Edition System

**V1 Implementation:** `lib/pubid/nist/edition.rb`

**Attributes:**
- `number`: Edition number (integer)
- `year`: Year (integer)
- `month`: Month (integer 1-12)
- `day`: Day (integer 1-31)

**Rendering Formats:**
```ruby
# Number only
Edition.new(number: 2).to_s(:short) # => "2"
Edition.new(number: 2).to_s(:long)  # => "Edition 2"

# Year only
Edition.new(year: 2019).to_s(:short) # => "2019"
Edition.new(year: 2019).to_s(:long)  # => "(2019)"

# Year + month
Edition.new(year: 1985, month: 3).to_s(:short) # => "198503"
Edition.new(year: 1985, month: 3).to_s(:long)  # => "(March 1985)"

# Year + month + day
Edition.new(year: 1977, month: 9, day: 30).to_s(:short) # => "19770930"
Edition.new(year: 1977, month: 9, day: 30).to_s(:long)  # => "(September 30, 1977)"

# Number + year
Edition.new(number: 2, year: 2020).to_s(:short) # => "2-2020"
Edition.new(number: 2, year: 2020).to_s(:long)  # => "Edition 2 (2020)"
```

**Parser Patterns:**
- Prefix "e": `e2019`, `e198503`, `e19770930`
- Dash-year: `-2019` (for SP series)
- Month-year: `Mar1985`, `Feb1985`, `Sep1977`
- Month-day/year: `Sep30/1977`
- Edition prefix: `(1)`, `(2)` for edition numbers

---

### 3. Version System

**V1 Implementation:** Attribute only (no separate class)

**Format:** Dotted notation with "ver" or "v" prefix

**Examples:**
```ruby
# "ver" prefix (verbose)
"NIST SP 800-60 Ver. 2.0" → version="2.0"
"NIST SP 800-63ver1.0.2"  → version="1.0.2"

# "v" prefix (short)
"NIST SP 1011v1ver2.0"    → volume="1", version="2.0"

# Rendering
version="2.0"      → "ver2.0" (short/mr), "Version 2.0" (long)
version="1.0.2"    → "ver1.0.2" (short/mr), "Version 1.0.2" (long)
```

**Parser:** `str("ver") | str("v")` followed by digits with dots

---

### 4. Update System

**V1 Implementation:** `lib/pubid/nist/update.rb`

**Attributes:**
- `number`: Update number (default 1)
- `year`: Year (handles 2-digit as 19XX)
- `month`: Month (optional)

**Rendering:**
```ruby
# Standard format
Update.new(number: 1, year: 2021, month: 2).to_s(:short) # => "/Upd1-202102"
Update.new(number: 1, year: 2021).to_s(:short)           # => "/Upd1-2021"

# Machine-readable
Update.new(number: 1, year: 2021, month: 2).to_s(:mr)   # => ".u1-202102"
```

**Parser Patterns:**
- `/Upd1-202102` → number=1, year=2021, month=2
- `/upd1-2021` → number=1, year=2021
- `-upd` → converted to `/Upd1-{timestamp}`
- `-upd1` → `/Upd1-{timestamp}`

**Update Codes:** `update_codes.yaml` has transformation rules

---

### 5. Translation System

**V1 Implementation:** Attribute string (no separate class)

**Format:** 3-letter language codes

**Examples:**
```ruby
# Parsing
"NIST SP 1262 spa"    → translation="spa" (Spanish)
"NIST SP 1262es"      → translation="spa" (transformed)
"NIST CSWP 01162020pt" → translation="por" (Portuguese)
"NIST CSWP 01162020id" → translation="ind" (Indonesian)
"NBS LC 1088sp"       → translation="spa"

# Rendering (always as 3-letter code after space)
translation="spa" → " spa" (short/mr)
translation="por" → " por" (short/mr)
```

**Parser Patterns:**
- Parenthetical: `(spa)`, `(por)`, `(ind)`
- Space-prefix: ` spa`, ` por`, ` ind`
- Dot-prefix: `.spa`, `.por` (MR format)
- Suffix transform: `es` → `(spa)`, `pt` → `(por)`, `id` → `(ind)`

**Transform Rules** (from `update_codes.yaml`):
```yaml
/(?<=\d)es/: (spa)
/(?<=\d)chi/: (zho)
/(?<=\d)viet/: (vie)
/(?<=\d)port/: (por)
/(?<=\d)(pt)(?!\d)/: (por)
/(?<=\d)id/: (ind)
```

---

### 6. Supplement System

**V1 Implementation:** String attribute (separate from edition)

**Critical:** Supplement is NOT part of edition!

**Examples:**
```ruby
# Parsing
"NIST SP 955 Suppl."  → supplement=""
"NIST SP 955sup"      → supplement=""
"NIST SP 305sup26"    → supplement="26"
"NBS CIRC 154r1sup"   → revision="1", supplement=""

# Rendering
supplement=""    → "sup" (short), "Supplement" (long)
supplement="26"  → "sup26" (short), "Supplement 26" (long)
```

**Parser:** `(str("supp") | str("sup")) >> match('[A-Z\d]').repeat.as(:supplement)`

---

### 7. Format Detection & Rendering

**V1 Implementation:** Multiple `to_s(format)` methods

**Formats:**
1. **`:short`** - Human-readable, space-separated (DEFAULT)
2. **`:long`** - Full names, verbose
3. **`:abbrev`** - Abbreviated names
4. **`:mr`** - Machine-readable, dot-separated

**Format Detection:**
- MR format: Contains dots (`NIST.SP.800-53r5`)
- Short format: Contains spaces (`NIST SP 800-53r5`)
- Auto-detected during parsing, stored as `parsed_format`

**Examples:**
```ruby
# Short format (default)
"NIST SP 800-53r5"
"NIST SP 800-53r5 ipd"
"NIST SP 1262 spa"

# Long format
"National Institute of Standards and Technology Special Publication 800-53, Revision 5"
"National Institute of Standards and Technology Special Publication 800-53 (Initial Public Draft), Revision 5"

# Abbreviated format
"Natl. Inst. Stand. Technol. Spec. Publ. 800-53, Rev. 5"

# Machine-readable format
"NIST.SP.800-53r5"
"NIST.SP.800-53r5.ipd"
"NIST.SP.1262.spa"
```

**Publisher Rendering:**
```ruby
# Short/MR
Publisher.new(publisher: "NIST").to_s(:short) # => "NIST"
Publisher.new(publisher: "NBS").to_s(:short)  # => "NBS"

# Long
Publisher.new(publisher: "NIST").to_s(:long)  # => "National Institute of Standards and Technology"
Publisher.new(publisher: "NBS").to_s(:long)   # => "National Bureau of Standards"

# Abbreviated
Publisher.new(publisher: "NIST").to_s(:abbrev) # => "Natl. Inst. Stand. Technol."
```

**Series Rendering:**
```ruby
# Short
Series.new(series: "SP").to_s(:short)   # => "SP"
Series.new(series: "FIPS").to_s(:short) # => "FIPS"

# Long
Series.new(series: "SP").to_s(:long)    # => "Special Publication"
Series.new(series: "FIPS").to_s(:long)  # => "Federal Information Processing Standards Publication"

# Abbreviated
Series.new(series: "SP").to_s(:abbrev)  # => "Spec. Publ."
Series.new(series: "FIPS").to_s(:abbrev) # => "Federal Inf. Process. Stds."

# Machine-readable (may differ)
Series.new(series: "MONO").to_s(:mr)    # => "MN"
```

---

### 8. Additional Attributes

**V1 Base Identifier Attributes:**
```ruby
attr_accessor :revision, :volume, :version, :supplement, :errata,
              :index, :insert, :section, :appendix, :translation
```

**Revision:**
- Format: `r` + number/letter
- Examples: `r1`, `r2`, `r2013`, `ra`, `r1a`

**Volume:**
- Format: `v` + number/letter(s)
- Examples: `v1`, `v2`, `v2a-l`, `v2m-z`, `v3B`

**Part:**
- Format: `pt` or `p` + number
- Examples: `pt1`, `pt2`, `p1-2`

**Addendum:**
- Separate identifier class: `Pubid::Nist::Identifier::Addendum`
- Format: `Add.` or `-add`
- Example: `NIST SP 800-38A Add.`

**Errata:**
- Format: `err` or `errata`
- Example: `NIST SP 801err`

**Index, Insert, Section, Appendix:**
- Rarely used attributes
- Formats: `index`, `ins`, `sec`, `app`

---

### 9. Parser Architecture

**Two-Stage Parsing:**

**Stage 1:** Series detection (`lib/pubid/nist/parser.rb`)
```ruby
# Detect series and publisher
rule(:series) do
  array_to_str(SERIES["long"].keys) |
  array_to_str(SERIES["mr"].values) |
  ((str("NBS") | str("NIST")) >> (space | dot) >> series)
end
```

**Stage 2:** Series-specific parser with fallback
```ruby
def parse(code)
  # Parse series first
  parsed = super(code)
  series = parsed[:series]
  
  # Find series-specific parser (SP, FIPS, etc.)
  parser = find_parser(publisher, series)
  
  # Try series parser, fallback to Default
  begin
    parsed = parser.new.parse(remaining)
  rescue Parslet::ParseFailed
    parsed = Parsers::Default.new.parse(remaining)
  end
end
```

**Series-Specific Parsers:**
- `Parsers::Sp` - Special Publication (most complex)
- `Parsers::Fips` - FIPS series
- `Parsers::Hb` - Handbook
- `Parsers::Tn` - Technical Note
- `Parsers::Gcr` - Grant/Contract Report
- `Parsers::NistIr` - Internal Report
- Plus historical series (CIRC, CRPL, CSM, RPT, etc.)

**Default Parser:** `Parsers::Default` - Base patterns for all series

---

### 10. Rendering Architecture

**Renderer Classes:**
- `Renderer::Base` - Base rendering logic
- Format parameter: `:short`, `:long`, `:abbrev`, `:mr`

**Rendering Flow:**
```ruby
def to_s(format = :short, without_edition: false)
  self.class.get_renderer_class.new(to_h(deep: false))
    .render(format: format, without_edition: without_edition)
end
```

**JSON Output:**
```ruby
def to_json(*args)
  result = {
    styles: {
      short: to_s(:short),
      abbrev: to_s(:abbrev),
      long: to_s(:long),
      mr: to_s(:mr),
    }
  }
  # Plus all instance variables
end
```

---

### 11. Update Codes System

**File:** `update_codes.yaml` (93 transformation rules)

**Purpose:** Normalize legacy/variant identifiers

**Examples:**
```yaml
NIST SP 260-126 rev 2013: NIST SP 260-126r2013
NIST SP 955 Suppl.: NIST SP 955sup
/\-draft$/: " (Draft)"
/\-draft2$/: " 2pd"
/(?<=\d)es/: (spa)
```

**Application:** `Identifier::Base.update_old_code(code)`

---

### 12. Critical Test Examples

**From V1 Specs:**

**Stage rendering:**
```ruby
"NIST SP(IPD) 800-53r5" → "NIST SP 800-53r5 ipd" (short)
"NIST.SP.800-66r2.ipd" → "NIST SP 800-66r2 ipd" (short)
```

**Translation:**
```ruby
"NIST SP 1262es" → "NIST SP 1262 spa"
"NIST SP 800-189 IPD spa" → stage + translation both work
```

**Edition with month/day:**
```ruby
"NBS FIPS 107-Mar1985" → edition: year=1985, month=3
"NBS FIPS 11-1-Sep30/1977" → edition: year=1977, month=9, day=30
```

**Update:**
```ruby
"NIST SP 800-53r4/Upd3-2015"
"NIST AMS 300-8r1 (February 2021 update)" → "/Upd1-202102"
```

**Version:**
```ruby
"NIST SP 800-63v1.0.2"
"NIST SP 1011v1ver2.0" → volume + version
```

---

## V1 to V2 Migration Requirements

### Must Preserve:
1. ✅ Stage: id + type system with short/long rendering
2. ✅ Translation: 3-letter codes (slo, spa, por, ind, etc.)
3. ✅ Supplement: Separate from edition
4. ✅ Format tracking: Detect and render in 4 formats
5. ✅ Edition: year/month/day combinations
6. ✅ Version: Dotted notation (ver1.0.2)
7. ✅ Update: /Upd1-YYYYMM format
8. ✅ Multiple rendering: short, long, abbrev, mr
9. ✅ Round-trip fidelity: Parse → Object → String preserves original
10. ✅ Update codes: Legacy identifier normalization

### Architecture Patterns:
1. ✅ Two-stage parsing (series detection → series-specific)
2. ✅ Series-specific parsers with fallback
3. ✅ Format detection during parsing
4. ✅ Multi-format rendering via single to_s(format)
5. ✅ Component classes for Stage, Edition, Update, etc.
6. ✅ Publisher/Series from YAML configs
7. ✅ Transform/normalize via update_codes.yaml

---

**Documentation Complete:** 2025-12-22
**Total V1 Features:** 12 major categories, 100+ specific patterns
**Migration Complexity:** HIGH (comprehensive feature set)
**Next Phase:** V2 Component Architecture Design