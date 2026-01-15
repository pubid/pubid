# ISO Documentation

## Overview

The ISO flavor handles identifiers for International Organization for Standardization (ISO) standards and related documents. It supports ISO's complete document lifecycle including 18 distinct document types (International Standards, Technical Reports, Technical Specifications, Guides, PAS, etc.) with full harmonized stage code support (00.00 through 95.99). The flavor also handles copublishers (IEC, IEEE, etc.), multi-level supplements (amendments, corrigenda), and joint identifiers with other organizations like IDF.

## Architecture

This flavor follows the PubID v2 three-layer architecture pattern:

1. **Parser** (`parser.rb`) - Parslet PEG grammar for syntax parsing
   - Converts input strings into structured hash trees
   - Handles syntax validation and lenient parsing
   - Returns parse tree with component keys including typed stage abbreviations
   - Supports legacy formats (ISO/R Recommendations, slash-separated parts)
   - Handles French/Russian style identifiers (Guide ISO/CEI)
   - Parses joint identifiers (ISO 5537|IDF 26)
   - Handles bundled identifiers with supplements (+ operator)

2. **Builder** (`builder.rb`) - Transforms parse trees to domain objects via Scheme registry
   - Casts parsed hash values to component objects using `cast()` method
   - Uses Scheme registry for type/stage lookups via `locate_typed_stage_by_abbr()`
   - Instantiates appropriate identifier class via `locate_identifier_klass_by_type_code()`
   - Handles special cases: ISO/R prefix conversion, DirectivesSupplement publisher renaming
   - Detects and preserves rendering style from parsed input (short/long stage format, language codes)
   - Merges copublishers into Publisher objects
   - Converts roman numeral parts to integers

3. **Identifier** (`identifiers/`) - Lutaml::Model domain classes with rendering logic
   - Base identifiers (SingleIdentifier) for standalone documents
   - Supplement identifiers (SupplementIdentifier) for amendments/corrigenda/addenda
   - Multi-format rendering support (:short, :long, :abbrev, :mr)
   - URN generation according to RFC 5141-bis
   - Automatic rendering style detection from parsed input

## Components

### Flavor-Specific Components

| Component | File | Purpose | Attributes |
|-----------|------|---------|------------|
| `Publisher` | `components/publisher.rb` | ISO publisher with copublisher support (ISO, ISO/IEC, ISO/IEC/IEEE) | `publisher`, `copublisher` (collection) |
| `Code` | `components/code.rb` | Generic string values with number and multi-level parts | `number`, `parts` (collection) |

### Shared Components Used

| Component | From | Purpose in this flavor |
|-----------|------|------------------------|
| `Publisher` | `lib/pubid_new/components/publisher.rb` | Not used - ISO has its own Publisher implementation |
| `Code` | `lib/pubid_new/components/code.rb` | Not used - ISO has its own Code implementation |
| `Date` | `lib/pubid_new/components/date.rb` | Year-based dates with optional month |
| `Type` | `lib/pubid_new/components/type.rb` | Document type (IS, TR, TS, Guide, PAS, etc.) |
| `Language` | `lib/pubid_new/components/language.rb` | Language codes with original_code preservation (E/F/R or en/fr/ru) |
| `Stage` | `lib/pubid_new/components/stage.rb` | Development stage (published, wd, cd, dis, etc.) |
| `TypedStage` | `lib/pubid_new/components/typed_stage.rb` | Combined stage+type with rendering format support (short_abbr, long_abbr) |
| `Edition` | `lib/pubid_new/components/edition.rb` | Edition information with original text preservation |
| `Locality` | `lib/pubid_new/components/locality.rb` | All parts reference |

## Identifier Classes

### Base Identifiers

#### InternationalStandard

- **File:** `lib/pubid_new/iso/identifiers/international_standard.rb`
- **Parent:** `SingleIdentifier`
- **Purpose:** The primary ISO document type representing International Standards. Supports the complete harmonized stage lifecycle from PWI (00.00) through published (60.00) to withdrawal (90.00+).
- **Components Used:** `publisher`, `type`, `number`, `part`, `subpart`, `stage_iteration`, `date`, `languages`, `edition`
- **Patterns Supported:**
  - `ISO 9001` → Published International Standard
  - `ISO/IEC 27001` → Joint ISO/IEC standard
  - `ISO 9001-1` → Standard with part
  - `ISO 9000:2015` → Standard with edition year
  - `ISO/CD 9001` → Committee Draft stage
  - `ISO/DIS 9001` → Draft International Standard
  - `ISO/FDIS 9001` → Final Draft International Standard
  - `ISO 9001:2015/Amd 1` → Standard with amendment (supplement recursion)
- **TYPED_STAGES:** 15 stages covering full lifecycle:
  - `DP` (isdp) - Draft Proposal
  - `PWI` (pwiis) - Proposed Work Item
  - `NP`, `NWIP` (isnp) - New Work Item Proposal
  - `AWI` (awiis) - Approved Work Item
  - `WD` (wdis) - Working Draft
  - `preCD`, `PreCD` (pcdis) - Pre-Committee Draft
  - `CD` (cdis) - Committee Draft
  - `FCD` (fcdis) - Final Committee Draft
  - `DIS`, `FPD` (dis) - Draft International Standard
  - `FDIS` (fdis) - Final Draft International Standard
  - `PRF`, `Fpr` (prfis) - Proof
  - `` (is) - Published International Standard (default, empty abbr)
  - `WDR` (wdr) - Proposed for Withdrawal
  - `WDA` (wda) - Withdrawal Approved
  - `WDAR` (wdar) - Withdrawal Archived
- **Rendering Formats:** All formats supported (:short, :long, :abbrev, :mr)

#### TechnicalReport

- **File:** `lib/pubid_new/iso/identifiers/technical_report.rb`
- **Parent:** `SingleIdentifier`
- **Purpose:** Technical Reports containing collected data or information. Used for informative documents that are not full standards.
- **Components Used:** `publisher`, `type`, `number`, `part`, `subpart`, `date`, `languages`, `edition`
- **Patterns Supported:**
  - `ISO TR 1234` → Published Technical Report
  - `ISO/TR 1234-1` → Technical Report with part
  - `ISO/WD TR 1234` → Working Draft Technical Report
  - `ISO/DTR 1234` → Draft Technical Report
  - `ISO/FDTR 1234` → Final Draft Technical Report
- **TYPED_STAGES:** 9 stages:
  - `PWI TR` (pwitr) - Proposed Work Item
  - `NP TR` (nptr) - New Work Item Proposal
  - `AWI TR` (awitr) - Approved Work Item
  - `WD TR` (wdtr) - Working Draft
  - `CD TR` (cdtr) - Committee Draft
  - `PDTR` (pdtr) - Proposed Draft (Legacy)
  - `DTR` (dtr) - Draft
  - `FDTR` (fdtr) - Final Draft
  - `PRF TR` (prftr) - Proof
  - `TR` (pubtr) - Published
- **Rendering Formats:** All formats supported

#### TechnicalSpecification

- **File:** `lib/pubid_new/iso/identifiers/technical_specification.rb`
- **Parent:** `SingleIdentifier`
- **Purpose:** Technical Specifications for documents still under development or with limited stability.
- **Components Used:** `publisher`, `type`, `number`, `part`, `subpart`, `date`, `languages`, `edition`
- **Patterns Supported:**
  - `ISO TS 1234` → Published Technical Specification
  - `ISO/TS 1234:2019` → Technical Specification with year
  - `ISO/DTS 1234` → Draft Technical Specification
  - `ISO/FDTS 1234` → Final Draft Technical Specification
- **TYPED_STAGES:** 9 stages:
  - `PWI TS` (pwits) - Proposed Work Item
  - `NP TS` (npts) - New Work Item Proposal
  - `AWI TS` (awits) - Approved Work Item
  - `WD TS` (wdts) - Working Draft
  - `CD TS` (cdts) - Committee Draft
  - `PDTS` (pdts) - Proposed Draft (Legacy)
  - `DTS` (dts) - Draft
  - `FDTS` (fdts) - Final Draft
  - `PRF TS` (prfts) - Proof
  - `TS` (pubts) - Published
- **Rendering Formats:** All formats supported

#### Guide

- **File:** `lib/pubid_new/iso/identifiers/guide.rb`
- **Parent:** `SingleIdentifier`
- **Purpose:** ISO and ISO/IEC Guides provide rules, guidelines, or recommendations for standards development. Uses space before "Guide" instead of slash.
- **Components Used:** `publisher`, `type`, `number`, `part`, `subpart`, `date`, `languages`, `edition`
- **Patterns Supported:**
  - `ISO Guide 51` → Published Guide (canonical form)
  - `ISO/IEC Guide 51:1999` → Joint Guide with year
  - `Guide ISO/CEI 51:1999` → French style (reverse order)
  - `ISO/WD Guide 51` → Working Draft Guide
  - `ISO/DGuide 51` → Draft Guide
  - `ISO/FDGuide 51` → Final Draft Guide
- **TYPED_STAGES:** 8 stages (includes legacy uppercase forms):
  - `PWI Guide`, `PWI GUIDE` (pwiis) - Proposed Work Item
  - `NP Guide`, `NP GUIDE` (npguide) - New Work Item Proposal
  - `AWI Guide`, `AWI GUIDE` (awiguide) - Approved Work Item
  - `WD Guide`, `WD GUIDE` (wdguide) - Working Draft
  - `CD Guide`, `CD GUIDE` (cdguide) - Committee Draft
  - `DGuide`, `DGUIDE` (dguide) - Draft
  - `FDGuide`, `FD Guide`, `FD GUIDE` (fdguide) - Final Draft
  - `PRF Guide`, `PRF GUIDE` (prfguide) - Proof
  - `Guide`, `GUIDE` (pubguide) - Published
- **Rendering Formats:** All formats supported. Special rendering: space before "Guide" not slash.

#### Pas (Publicly Available Specification)

- **File:** `lib/pubid_new/iso/identifiers/pas.rb`
- **Parent:** `SingleIdentifier`
- **Purpose:** Publicly Available Specifications (PAS) are fast-track documents developed by external organizations and approved by ISO.
- **Components Used:** `publisher`, `type`, `number`, `part`, `subpart`, `date`, `languages`, `edition`
- **Patterns Supported:**
  - `ISO PAS 1234` → Published PAS
  - `ISO/PAS 22736:2021` → PAS with year
  - `ISO/SAE PAS 22736` → PAS with copublisher
  - `ISO/DPAS 1234` → Draft PAS
  - `ISO/FDPAS 1234` → Final Draft PAS
- **TYPED_STAGES:** 8 stages:
  - `PWI PAS` (pwipas) - Proposed Work Item
  - `NP PAS` (nppas) - New Work Item Proposal
  - `AWI PAS` (awipas) - Approved Work Item
  - `WD PAS` (wdpas) - Working Draft
  - `CD PAS` (cdpas) - Committee Draft
  - `DPAS` (dpas) - Draft
  - `FDPAS` (fdpas) - Final Draft
  - `PRF PAS` (prfpas) - Proof
  - `PAS` (pas) - Published
- **Rendering Formats:** All formats supported

#### Data

- **File:** `lib/pubid_new/iso/identifiers/data.rb`
- **Parent:** `SingleIdentifier`
- **Purpose:** Data documents containing reference data or datasets.
- **Components Used:** `publisher`, `type`, `number`, `part`, `subpart`, `date`, `languages`, `edition`
- **Patterns Supported:**
  - `ISO DATA 1234` → Published Data
  - `ISO/DATA 1234` → Draft Data
  - `ISO/WD DATA 1234` → Working Draft Data
  - `ISO/CD DATA 1234` → Committee Draft Data
- **TYPED_STAGES:** 6 stages:
  - `NP DATA` (npdata) - New Work Item Proposal
  - `AWI DATA` (awidata) - Approved Work Item
  - `WD DATA` (wddata) - Working Draft
  - `CD DATA` (cddata) - Committee Draft
  - `D DATA` (ddata) - Draft
  - `PRF DATA` (prfdata) - Proof
  - `DATA` (pubdata) - Published
- **Rendering Formats:** All formats supported

#### TechnologyTrendsAssessments

- **File:** `lib/pubid_new/iso/identifiers/technology_trends_assessments.rb`
- **Parent:** `SingleIdentifier`
- **Purpose:** Technology Trends Assessments (TTA) analyzing emerging technology trends.
- **Components Used:** `publisher`, `type`, `number`, `part`, `subpart`, `date`, `languages`, `edition`
- **Patterns Supported:**
  - `ISO TTA 1234` → Published TTA
  - `ISO/DTTA 1234` → Draft TTA
  - `ISO/FDTTA 1234` → Final Draft TTA
  - `ISO/WD TTA 1234` → Working Draft TTA
- **TYPED_STAGES:** 8 stages:
  - `PWI TTA` (pwitta) - Proposed Work Item
  - `NP TTA` (nptta) - New Work Item Proposal
  - `AWI TTA` (awitta) - Approved Work Item
  - `WD TTA` (wdtta) - Working Draft
  - `CD TTA` (cdtta) - Committee Draft
  - `DTTA` (dtta) - Draft
  - `FDTTA` (fdtta) - Final Draft
  - `PRF TTA` (prftta) - Proof
  - `TTA` (pubtta) - Published
- **Rendering Formats:** All formats supported

#### InternationalWorkshopAgreement

- **File:** `lib/pubid_new/iso/identifiers/international_workshop_agreement.rb`
- **Parent:** `SingleIdentifier`
- **Purpose:** International Workshop Agreements (IWA) are documents developed through workshops rather than the normal committee process. Rendered without "ISO" publisher prefix.
- **Components Used:** `type`, `number`, `part`, `subpart`, `date`, `languages`, `edition`
- **Patterns Supported:**
  - `IWA 8:2009` → Published IWA (no ISO prefix)
  - `IWA 14-1:2013` → IWA with part
  - `AWI IWA 36` → Approved Work Item IWA
  - `CD IWA 37-2` → Committee Draft IWA
  - `DIWA 36` → Draft IWA
- **TYPED_STAGES:** 7 stages:
  - `PWI IWA` (npiwa) - Proposed Work Item
  - `NP IWA` (npiwa) - New Work Item Proposal
  - `AWI IWA` (awiiwa) - Approved Work Item
  - `WD IWA` (wdiwa) - Working Draft
  - `CD IWA` (cdiwa) - Committee Draft
  - `DIWA` (diwa) - Draft
  - `PRF IWA` (prfiwa) - Proof
  - `IWA` (iwa) - Published
- **Rendering Formats:** All formats supported. Special rendering: no "ISO" prefix.

#### InternationalStandardizedProfile

- **File:** `lib/pubid_new/iso/identifiers/international_standardized_profile.rb`
- **Parent:** `SingleIdentifier`
- **Purpose:** International Standardized Profiles (ISP) identify a set of standards required for a specific functionality.
- **Components Used:** `publisher`, `type`, `number`, `part`, `subpart`, `date`, `languages`, `edition`
- **Patterns Supported:**
  - `ISO ISP 1234` → Published ISP
  - `ISO/DISP 1234` → Draft ISP
  - `ISO/FDISP 1234` → Final Draft ISP
  - `ISO/WD ISP 1234` → Working Draft ISP
- **TYPED_STAGES:** 8 stages:
  - `PWI ISP` (pwiisp) - Proposed Work Item
  - `NP ISP` (npisp) - New Work Item Proposal
  - `AWI ISP` (awiisp) - Approved Work Item
  - `WD ISP` (wdisp) - Working Draft
  - `CD ISP` (cdisp) - Committee Draft
  - `DISP` (disp) - Draft
  - `FDISP` (fdisp) - Final Draft
  - `PRF ISP` (prfisp) - Proof
  - `ISP` (isp) - Published
- **Rendering Formats:** All formats supported

#### Recommendation

- **File:** `lib/pubid_new/iso/identifiers/recommendation.rb`
- **Parent:** `SingleIdentifier`
- **Purpose:** Recommendations (R) are legacy ISO documents predating the current standards system.
- **Components Used:** `publisher`, `type`, `number`, `part`, `subpart`, `date`, `languages`, `edition`
- **Patterns Supported:**
  - `ISO R 1234` → Published Recommendation (legacy format)
  - `ISO/DP 1234` → Draft Proposal (covers all draft stages)
- **TYPED_STAGES:** 2 stages:
  - `DP` (dp) - Draft Proposal (covers stages 00.00-40.99)
  - `R` (rec) - Published Recommendation
- **Rendering Formats:** All formats supported. URN type code is 'r' not 'rec'.

#### Directives

- **File:** `lib/pubid_new/iso/identifiers/directives.rb`
- **Parent:** `SingleIdentifier`
- **Purpose:** ISO/IEC Directives provide procedural rules for standards development. Supports JTC 1 subgroup and organization variants (ISO/IEC versions).
- **Components Used:** `publisher`, `type`, `number`, `part`, `subpart`, `subgroup`, `date`, `languages`, `edition`
- **Patterns Supported:**
  - `ISO/IEC DIR` → Directives without number
  - `ISO/IEC DIR 1` → Directives with number
  - `ISO/IEC DIR 1:2022` → Directives with year
  - `ISO/IEC JTC 1 DIR` → JTC 1 Directives
  - `ISO/IEC DIR 1 IEC` → Directives with IEC variant
- **TYPED_STAGES:** 1 stage:
  - `DIR`, `Directives Part`, `Directives, Part`, `Directives,`, `Directives` (pubguide) - Published
- **Rendering Formats:** All formats supported. URN uses `urn:iso:doc` scheme, not `urn:iso:std`.

### Supplement Identifiers

#### Amendment

- **File:** `lib/pubid_new/iso/identifiers/amendment.rb`
- **Parent:** `SupplementIdentifier`
- **Purpose:** Amendments (Amd) modify or add to an existing base standard.
- **Components Used:** `base_identifier`, `type`, `number`, `part`, `subpart`, `date`, `languages`, `edition`
- **Patterns Supported:**
  - `ISO 9001:2015/Amd 1:2017` → Standard with amendment
  - `ISO 9001:2015/DAM 1` → Draft amendment
  - `ISO 9001:2015/FDAM 1` → Final draft amendment
  - `ISO 9001:2015/PDAM 1` → Proposed draft amendment (legacy)
  - `ISO/IEC 27001:2022/Amd 1/Amd 2` → Amendment to amendment (multi-level recursion)
- **TYPED_STAGES:** 10 stages:
  - `PWI Amd` (pwi_amd) - Proposed Work Item
  - `NP Amd` (np_amd) - New Work Item Proposal
  - `AWI Amd` (awi_amd) - Approved Work Item
  - `WD Amd` (wd_amd) - Working Draft
  - `CD Amd` (committee_draft_amd) - Committee Draft
  - `PDAM` (pdam) - Proposed Draft (Legacy)
  - `DAM`, `DAmd` (damd) - Draft
  - `FDAM`, `FDAmd` (fdamd) - Final Draft
  - `FPDAM` (fpdam) - Final Proposed Draft (Legacy)
  - `PRF Amd` (prf_amd) - Proof
  - `Amd`, `AMD`, `Amd.` (published) - Published
- **Recursion:** Supports multi-level amendments (amendment to amendment)
- **Rendering Formats:** All formats supported with short/long stage format detection

#### Corrigendum

- **File:** `lib/pubid_new/iso/identifiers/corrigendum.rb`
- **Parent:** `SupplementIdentifier`
- **Purpose:** Corrigenda (Cor) correct errors in published standards.
- **Components Used:** `base_identifier`, `type`, `number`, `part`, `subpart`, `date`, `languages`, `edition`
- **Patterns Supported:**
  - `ISO 9001:2015/Cor 1:2017` → Standard with corrigendum
  - `ISO 9001:2015/DCor 1` → Draft corrigendum
  - `ISO 9001:2015/FDCor 1` → Final draft corrigendum
  - `ISO 9001:2015/Amd 1/Cor 1` → Corrigendum to amendment
- **TYPED_STAGES:** 9 stages:
  - `PWI Cor` (pwi_cor) - Proposed Work Item
  - `NP Cor` (npcor) - New Work Item Proposal
  - `AWI Cor` (awicor) - Approved Work Item
  - `WD Cor` (wdcor) - Working Draft
  - `CD Cor`, `pDCOR` (cdcor) - Committee Draft
  - `DCor`, `DCOR` (dcor) - Draft
  - `FDCor`, `FDCOR`, `FCOR` (fdcor) - Final Draft
  - `PRF Cor` (prfcor) - Proof
  - `Cor`, `COR`, `Cor.` (pubcor) - Published
- **Recursion:** Supports multi-level supplements (corrigendum to amendment, etc.)
- **Rendering Formats:** All formats supported

#### Supplement

- **File:** `lib/pubid_new/iso/identifiers/supplement.rb`
- **Parent:** `SupplementIdentifier`
- **Purpose:** Generic supplements (Suppl) for various supplement types not covered by Amd/Cor/Add.
- **Components Used:** `base_identifier`, `type`, `number`, `part`, `subpart`, `date`, `languages`, `edition`
- **Patterns Supported:**
  - `ISO 9001:2015/Suppl 1` → Standard with supplement
  - `ISO 9001:2015/DSuppl 1` → Draft supplement
  - `ISO 9001:2015/FDSuppl 1` → Final draft supplement
- **TYPED_STAGES:** 7 stages:
  - `NP Suppl` (npsuppl) - New Work Item Proposal
  - `AWI Suppl` (awisuppl) - Approved Work Item
  - `WD Suppl` (wdsuppl) - Working Draft
  - `CD Suppl` (cdsuppl) - Committee Draft
  - `DSuppl` (dsuppl) - Draft
  - `FDSuppl`, `FDIS Suppl` (fdsuppl) - Final Draft
  - `PRF Suppl` (prfsuppl) - Proof
  - `Suppl`, `Suppl.` (pubsuppl) - Published
- **Recursion:** Supports multi-level supplements
- **Rendering Formats:** All formats supported. URN supplement type is 'sup'.

#### Extract

- **File:** `lib/pubid_new/iso/identifiers/extract.rb`
- **Parent:** `SupplementIdentifier`
- **Purpose:** Extracts (Ext) are portions extracted from existing standards.
- **Components Used:** `base_identifier`, `type`, `number`, `date`, `languages`, `edition`
- **Patterns Supported:**
  - `ISO 9001:2015/Ext 1` → Standard with extract
- **TYPED_STAGES:** 1 stage:
  - `Ext` (pubext) - Published
- **Recursion:** Supports multi-level supplements
- **Rendering Formats:** All formats supported

#### Addendum

- **File:** `lib/pubid_new/iso/identifiers/addendum.rb`
- **Parent:** `SupplementIdentifier`
- **Purpose:** Addenda (Add) add new material to existing standards.
- **Components Used:** `base_identifier`, `type`, `number`, `part`, `subpart`, `date`, `languages`, `edition`
- **Patterns Supported:**
  - `ISO 9001:2015/Add 1` → Standard with addendum
  - `ISO 9001:2015/DAD 1` → Draft addendum
  - `ISO 9001:2015/FDAD 1` → Final draft addendum
- **TYPED_STAGES:** 3 stages:
  - `DAD` (dad) - Draft
  - `FDAD` (fdad) - Final Draft
  - `Add`, `ADD`, `Addendum`, `Add.` (pubadd) - Published
- **Recursion:** Supports multi-level supplements
- **Rendering Formats:** All formats supported. URN supplement type is 'sup'.

#### DirectivesSupplement

- **File:** `lib/pubid_new/iso/identifiers/directives_supplement.rb`
- **Parent:** `SupplementIdentifier`
- **Purpose:** Supplements to ISO/IEC Directives, specific to each organization (ISO, IEC, JTC 1).
- **Components Used:** `base_identifier`, `supplement_publisher`, `type`, `number`, `date`, `languages`, `edition`
- **Patterns Supported:**
  - `ISO/IEC DIR 1 ISO SUP:2022` → ISO supplement to DIR 1
  - `ISO/IEC DIR 2 IEC SUP:2016` → IEC supplement to DIR 2
  - `ISO/IEC JTC 1 DIR SUP:2021` → JTC 1 supplement
  - `ISO/IEC DIR 1 + IEC SUP:2016` → Bundled identifier (base + supplement)
- **TYPED_STAGES:** 1 stage:
  - `DIR SUP`, `SUP`, `Supplement` (pubdirsup) - Published
- **Recursion:** Not applicable (DirectivesSupplement is terminal)
- **Rendering Formats:** Special rendering with supplement_publisher and "SUP" keyword. URN uses `urn:iso:doc` scheme.

## Scheme Registry

The `Scheme` class (`lib/pubid_new/iso/scheme.rb`) is the central registry for this flavor.

### Registry Methods

- **`identifiers`** - Array of all registered identifier classes
  ```ruby
  IDENTIFIERS = [
    Identifiers::InternationalStandard,
    Identifiers::TechnicalReport,
    Identifiers::TechnicalSpecification,
    Identifiers::Guide,
    Identifiers::Pas,
    Identifiers::Data,
    Identifiers::TechnologyTrendsAssessments,
    Identifiers::InternationalWorkshopAgreement,
    Identifiers::InternationalStandardizedProfile,
    Identifiers::Recommendation,
    Identifiers::Directives,
    Identifiers::Amendment,
    Identifiers::Corrigendum,
    Identifiers::Supplement,
    Identifiers::Extract,
    Identifiers::DirectivesSupplement,
    Identifiers::Addendum,
  ]
  ```

- **`typed_stages`** - Aggregate TYPED_STAGES from all identifier classes
  ```ruby
  def typed_stages
    identifiers.flat_map { |klass| klass::TYPED_STAGES }
  end
  ```

- **`supplement_typed_stages`** - TYPED_STAGES for supplement identifiers only
  ```ruby
  def supplement_typed_stages
    [Identifiers::Amendment, Identifiers::Corrigendum,
     Identifiers::Supplement, Identifiers::Extract,
     Identifiers::Addendum].flat_map { |klass| klass::TYPED_STAGES }
  end
  ```

- **`locate_typed_stage_by_abbr(abbr)`** - Find stage by abbreviation
  - Returns `TypedStage` object or raises `ArgumentError`
  - Searches through all registered TYPED_STAGES
  - Empty string (`""`) returns published International Standard (default)
  - Supports abbreviation arrays

- **`locate_identifier_klass_by_type_code(type_code)`** - Select class by type code
  - Returns identifier class based on type_code from parsed data
  - Used by Builder to determine which class to instantiate
  - Example: `:amd` → `Identifiers::Amendment`

### Parser Instance

```ruby
def parser
  @parser ||= Parser.new  # Memoized for performance
end
```

## Rendering Examples

### Short Format (`:short`)

| Identifier Pattern | Rendered Output |
|-------------------|-----------------|
| `ISO 9001:2015` | `ISO 9001:2015` |
| `ISO/IEC 27001:2022` | `ISO/IEC 27001:2022` |
| `ISO/TR 1234:2019` | `ISO/TR 1234:2019` |
| `ISO 9001:2015/Amd 1:2017` | `ISO 9001:2015/AMD 1:2017` |
| `ISO 9001:2015/Cor 1` | `ISO 9001:2015/COR 1` |
| `ISO/IEC DIR 1` | `ISO/IEC DIR 1` |
| `IWA 8:2009` | `IWA 8:2009` |

### MR Format (`:mr`)

| Identifier Pattern | Rendered Output |
|-------------------|-----------------|
| `ISO 9001:2015` | `ISO 9001:2015` |
| `ISO/IEC 27001:2022` | `ISO/IEC 27001:2022` |
| `ISO 9001:2015/Amd 1:2017` | `ISO 9001:2015/Amd 1:2017` |
| `ISO 9001:2015/Cor 1` | `ISO 9001:2015/Cor 1` |

### Long Format (`:long`)

| Identifier Pattern | Rendered Output |
|-------------------|-----------------|
| `ISO 9001:2015` | `ISO 9001:2015` |
| `ISO/IEC 27001:2022` | `ISO/IEC 27001:2022` |
| `ISO 9001:2015/Amd 1:2017` | `ISO 9001:2015/DAmd 1:2017` |
| `ISO 9001:2015/Cor 1` | `ISO 9001:2015/DCor 1` |

### Abbreviated Format (`:abbrev`)

| Identifier Pattern | Rendered Output |
|-------------------|-----------------|
| `ISO 9001:2015` | `IS 9001:2015` |
| `ISO/TR 1234:2019` | `TR 1234:2019` |
| `ISO/PAS 22736:2021` | `PAS 22736:2021` |

## Parser Rules

### Main Rule

```ruby
rule(:identifier) do
  directives_identifiers |
    iso_r_supplement_identifier |
    iso_r_identifier |
    supplement_supplement_identifier |
    supplement_identifier |
    joint_identifier |
    identifier_copublishers
end
```

### Component Rules

```ruby
# Publisher with optional copublishers
rule(:prefix_with_copublishers) do
  (str("ISO/R").as(:iso_r_prefix) >> space) |
    (prefix_sole_publisher >> space? >> copublishers.maybe)
end

# Copublishers (IEC, IEEE, SAE, etc.)
rule(:copublishers) do
  (str("/") >> space? >> array_to_str(ORGANIZATIONS).as(:copublisher)).repeat.as(:copublishers)
end

# Number with optional part and subpart
rule(:number_with_part) do
  (number >> part_and_subpart.maybe).as(:number_with_part)
end

# Type with stage (WD, CD, DIS, FDIS, etc.)
rule(:type_with_stage) do
  array_to_str(TYPED_STAGES).as(:type_with_stage) >>
    (match('\d').as(:stage_iteration) >> space).maybe
end

# Supplement type with stage (Amd, Cor, DAM, FDCor, etc.)
rule(:supplement_type_with_stage) do
  array_to_str(TYPED_STAGES_SUPPLEMENTS).as(:type_with_stage)
end

# Language codes (E/F/R or en/fr/ru)
rule(:language) do
  str("(") >>
    ((match["a-z"].repeat(1) >> str(",").maybe) |
     (match["EFARDS"] >> str("/").maybe)).repeat.as(:languages) >>
    str(")")
end

# Edition (Ed.2, Ed 2, Edition 13)
rule(:edition) do
  (array_to_str(EDITION_STRINGS) >> space? >> digits.maybe).as(:edition)
end
```

### Special Patterns

```ruby
# Joint identifier with IDF
rule(:joint_identifier) do
  identifier_copublishers_no_third.as(:base_identifier) >>
    space? >> str("|") >> space? >>
    scope { idf_identifier }.as(:joint_identifier)
end

# Directives identifier
rule(:directives_identifier) do
  directives_identifier_no_third >> third_part.maybe >> space? >> date.maybe
end

# Bundled identifier (base + supplements)
rule(:directives_bundled_identifier) do
  (directives_identifier_no_third >>
    (third_part >> space?).maybe >>
    (date >> space?).maybe
  ).as(:base_document) >>
    (str("+ ") >> directives_supplement_part_no_third.as(:supplement)).repeat(1).as(:supplements)
end
```

## Builder Logic

### Identifier Class Selection

The Builder determines which identifier class to instantiate based on:

1. **Joint identifier presence** - If `:joint_identifier` exists → `CombinedIdentifier`
2. **Supplements presence** - If `:supplements` exists → `BundledIdentifier`
3. **Type code from TypedStage** - `locate_identifier_klass_by_type_code()` called with type_code

### Type Code Mappings

| Type Code | Identifier Class |
|-----------|------------------|
| `:is` | `InternationalStandard` |
| `:tr` | `TechnicalReport` |
| `:ts` | `TechnicalSpecification` |
| `:guide` | `Guide` |
| `:pas` | `Pas` |
| `:data` | `Data` |
| `:tta` | `TechnologyTrendsAssessments` |
| `:iwa` | `InternationalWorkshopAgreement` |
| `:isp` | `InternationalStandardizedProfile` |
| `:rec` | `Recommendation` |
| `:dir` | `Directives` |
| `:amd` | `Amendment` |
| `:cor` | `Corrigendum` |
| `:suppl` | `Supplement` |
| `:ext` | `Extract` |
| `:"dir-sup"` | `DirectivesSupplement` |
| `:add` | `Addendum` |

### Component Casting

Special casting logic in Builder's `cast()` method:

```ruby
# Number with part (handles multi-level parts and legacy formats)
when :number_with_part
  # "1234-1-2" → number="1234", part="1", subpart="2"
  # "ISO 4037-1979" → legacy format, year moved to date

# Type with stage (preserves original abbreviation)
when :type_with_stage
  # "WD" → TypedStage with original_abbr="WD"
  # "DAM" → TypedStage with short_abbr="DAM"

# Languages (supports both single-char and ISO codes)
when :languages
  # "E/F/R" → original_code preserved
  # "en,fr,ru" → converted to 2-char codes

# Publisher (merges copublishers)
when :publisher
  # Hash: {publisher: "ISO", copublisher: ["IEC", "IEEE"]}
  # → Publisher object with copublisher array
```

### Rendering Style Detection

The Builder automatically detects rendering style from parsed input:

```ruby
# Stage format detection (long vs short)
stage_format_long = if ts.long_abbr && ts.original_abbr&.start_with?(ts.long_abbr)
                      true  # "DAmd", "FDAmd", "DCor", "FDCor"
                    else
                      false # "DAM", "FDAM", "DCOR", "FDCOR"
                    end

# Language code format detection
with_language_code = if first_lang.original_code&.length == 1
                       :single  # "E", "F", "R"
                     else
                       :iso    # "en", "fr", "ru"
                     end
```

## Preprocessing

This flavor uses preprocessing to normalize input before parsing:

| Pattern | Input | Output | Purpose |
|---------|-------|--------|---------|
| Dash normalization | `ISO 9001‑1` (en-dash) | `ISO 9001-1` | Normalize Unicode dashes to ASCII hyphen |
| ISO/R conversion | `ISO/R 947:1969` | `publisher=ISO, type=R` | Legacy Recommendation format |
| French Guide | `Guide ISO/CEI 51` | `type_with_stage_fr=Guide` | French-style identifier |
| DirectivesSupplement | `ISO/IEC DIR 1 ISO` | `supplement_publisher=ISO` | Directives supplement without SUP keyword |

Preprocessing is **explicit** and **format-preserving** - the original format is stored for exact reproduction during rendering.

## Testing

### Test Coverage

- **Unit tests:** `spec/pubid_new/iso/components/`
- **Parser tests:** `spec/pubid_new/iso/parser_spec.rb`
- **Builder tests:** `spec/pubid_new/iso/builder_spec.rb`
- **Identifier tests:** `spec/pubid_new/iso/identifiers/`
- **Integration tests:** `spec/integration/iso_`
- **Rendering tests:** `spec/pubid_new/iso/rendering_*.rb`

### Fixtures

Located in: `spec/fixtures/iso/identifiers/`

- **Pass tests:** `pass/` - Valid patterns that should parse successfully
  - `base.txt` - Base identifier patterns
  - `amendment.txt` - Amendment patterns
  - `corrigendum.txt` - Corrigendum patterns
  - `supplement.txt` - Supplement patterns
  - `directives.txt` - Directives patterns
- **Fail tests:** `fail/` - Invalid patterns that should raise errors

### Coverage Status

The ISO flavor has comprehensive test coverage with ~95%+ coverage for all identifier classes and rendering patterns.

## Migration Notes

### V1 to V2 Changes

**Major architectural changes:**
1. **Three-layer separation** - Parser, Builder, and Identifier are completely separate
2. **Registry-based architecture** - Scheme class manages all type/stage lookups
3. **TYPED_STAGES array** - Replaces hash-based TYPE_MAP pattern
4. **Rendering styles** - Explicit rendering style objects instead of format parameters
5. **URN generation** - Separate UrnGenerator class following RFC 5141-bis

**Breaking changes:**
- `Pubid::Iso::Identifier` → `PubidNew::Iso::Identifiers::*` (specific classes)
- `type` and `stage` attributes replaced by `typed_stage` (combined object)
- `render()` method replaced by `to_s(format: ...)` or `rendering_style` object

**Migration guide:**
1. Replace `Pubid::Iso.parse()` with `PubidNew::Iso.parse()`
2. Use specific identifier classes instead of generic `Identifier`
3. Access type/stage via `identifier.typed_stage`
4. Use `format: :short|:long|:abbrev` parameter for different renderings
5. Use `identifier.to_urn()` for URN generation

## References

- **Specification:** ISO/IEC Directives, Part 2 - Rules for the structure and drafting of International Standards
- **Examples:** ISO Online Browse Platform (https://www.iso.org/standards-catalogue.html)
- **Related implementations:**
  - IEC flavor (similar structure, shared TYPED_STAGES pattern)
  - CEN/BSI flavors (similar harmonized stage codes)

---

## Appendix: Design Decisions

### Registry-based TYPED_STAGES

**Context:** ISO has 18 identifier classes with multiple stages each, totaling over 100 distinct typed stages.

**Decision:** All TYPED_STAGES are defined in each identifier class and aggregated by the Scheme class.

**Rationale:**
- Each identifier class owns its stage definitions
- Scheme can aggregate all stages for global lookups
- Builder never makes business logic decisions - only consults registry

**Alternatives considered:**
- Central TYPED_STAGES hash in Scheme - Rejected because classes should own their definitions
- Hardcoded type/stage logic in Builder - Rejected (anti-pattern, violates MECE)

### Rendering Style Detection

**Context:** ISO identifiers have multiple valid formats for the same semantic content (AMD vs Amd, short vs long stage format).

**Decision:** Builder detects and preserves rendering style from parsed input using `original_abbr` attribute.

**Rationale:**
- Round-trip preservation: parsed identifiers render identically
- No format information lost during parsing
- Explicit rendering style objects for programmatic control

**Alternatives considered:**
- Always render canonical form - Rejected (loses format information)
- Store format as separate parameter - Rejected (less elegant)

### Directives Special Case

**Context:** Directives have unique rendering (space before DIR, optional number, JTC subgroup) and URN scheme (`urn:iso:doc`).

**Decision:** Directives is a separate identifier class with custom `publisher_portion()` and `to_urn()` methods.

**Rationale:**
- Directives are structurally different from other ISO documents
- Custom rendering logic is contained within Directives class
- URN scheme difference requires special handling

**Alternatives considered:**
- Use base InternationalStandard with flags - Rejected (less clear, more flags)
- Create separate DirectivesScheme - Rejected (over-complication)

### Joint Identifiers

**Context:** Some ISO standards have joint identifiers with other organizations like IDF (e.g., ISO 5537|IDF 26).

**Decision:** CombinedIdentifier class holds base_identifier and additional_identifiers.

**Rationale:**
- Clean separation of each organization's identifier
- Each identifier can be parsed/validated independently
- Extensible to other joint identifier patterns

**Alternatives considered:**
- Parse as single identifier with publisher variants - Rejected (mixes organizations)
- Store as string literal - Rejected (loses structure)
