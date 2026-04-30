# Data Dictionary
## VBM EquiWait: Demographic Equity in NHS Waiting Lists

---

## Part 1: Star Schema - Schema `marts` in `VBM_EquiWait_WH`

All mart tables are deployed to the `marts` schema. Surrogate keys are generated using `dbt_utils.generate_surrogate_key()` and stored as varchar. Natural keys are preserved alongside surrogates for full traceability.

The exception is `dim_waiting_band`, which is seeded from a CSV and sits in the `seeds` schema rather than `marts`. It is consumed directly from `seeds` in the semantic model.

---

### `dim_demographic`

**Grain:** One row per unique combination of demographic dimension and demographic value.

**Description:** Conformed demographic category dimension shared across all three fact tables. Covers all four demographic dimensions: age band, sex, ethnicity, and IMD deprivation decile. SCD Type-1. IMD version retained as an explicit attribute.

| Column | Data Type | Description |
|---|---|---|
| `demographic_sk` | varchar | Surrogate key. Primary key. Generated from `demographic_dimension` and `demographic_value`. |
| `demographic_dimension` | varchar | The demographic dimension this row belongs to. One of: `Age`, `Sex`, `Ethnicity`, `IMD`. |
| `demographic_value` | varchar | The specific category within the dimension. Examples: `0-17`, `Male`, `A: British`, `IMD Decile 1`. |
| `imd_version` | varchar | The version of the Index of Multiple Deprivation used for this row. Populated for IMD rows only; NULL for all other dimensions. |
| `is_unknown` | int | Flag. 1 if this row represents patients whose demographic information was not recorded; 0 otherwise. |
| `is_total` | int | Flag. 1 if this row is a pre-computed total across all categories within the dimension; 0 otherwise. Must be excluded when summing across categories to prevent double-counting. |

**Notes:**
- The sum of `patient_count` across all non-total demographic rows for a given dimension will not equal the overall waiting list total, because patients with unknown demographic information are excluded from the breakdown but retained in the total.
- For ethnicity, values reflect a combined source: WLMDS submission where available, augmented by SUS ethnicity records where the submission is missing.

---

### `dim_geography`

**Grain:** One row per provider per valid date range (SCD Type-2).

**Description:** Provider dimension covering all 183 organisations in the WLMDS Geography publication. SCD Type-2 tracking ensures organisational restructures do not silently rewrite historical relationships. Use `is_current = 1` to filter to the current version of each provider.

| Column | Data Type | Description |
|---|---|---|
| `geography_sk` | varchar | Surrogate key. Primary key for this SCD Type-2 record. Generated from `trust_code` and `valid_from_date`. |
| `trust_code` | varchar | ODS organisation code. Natural key. Stable across SCD versions for the same organisation. |
| `trust_name` | varchar | Canonical organisation name, standardised using the `trust_name_canonical` seed. |
| `valid_from_date` | date | The date from which this version of the provider record is valid. |
| `valid_to_date` | date | The date until which this version of the provider record is valid. NULL for the current version. |
| `is_current` | int | Flag. 1 if this is the current active version of the provider record; 0 for historical versions. |
| `submission_gap` | int | Number of monthly snapshots in which this provider submitted no data within the observation window. |
| `gap_reason` | varchar | Documented reason for submission gap where known. NULL where no reason is documented. |

**Special members:**
- Surrogate key `-1` is reserved as the Not Applicable member, used in `fact_waiting_list_specialty` and `fact_waiting_list_timeseries` where no organisation below England level applies.

**Notes:**
- Sheffield Teaching Hospitals (RHQ) is excluded from national and regional totals from October 2025 onwards due to EPR migration. This is reflected in `gap_reason` for the relevant record.
- Active semantic model relationship: `dim_geography.geography_sk` to `fact_waiting_list_geography.geography_sk` only (relationship 4). No relationship to the specialty or timeseries fact tables.

---

### `dim_specialty`

**Grain:** One row per treatment function per valid date range (SCD Type-2).

**Description:** RTT treatment function dimension covering 24 specialties. SCD Type-2 on name and grouping changes.

| Column | Data Type | Description |
|---|---|---|
| `specialty_sk` | varchar | Surrogate key. Primary key for this SCD Type-2 record. |
| `treatment_function_code` | varchar | Standard NHS treatment function code. Natural key. |
| `treatment_function_name` | varchar | Full name of the treatment function. Examples: `Ear Nose and Throat Service`, `Trauma and Orthopaedics Service`. |
| `grouping` | int | Specialty grouping code for analytical aggregation. |
| `valid_from_date` | date | The date from which this version of the specialty record is valid. |
| `valid_to_date` | date | The date until which this version of the specialty record is valid. NULL for the current version. |
| `is_current` | int | Flag. 1 if this is the current active version; 0 for historical versions. |

**Special members:**
- Surrogate key `-1` is reserved as the Not Applicable member, used in `fact_waiting_list_geography` and `fact_waiting_list_timeseries` where no treatment function applies.

**Notes:**
- Active semantic model relationship: `dim_specialty.specialty_sk` to `fact_waiting_list_specialty.specialty_sk` only (relationship 5). No relationship to the geography or timeseries fact tables.

---

### `dim_waiting_band`

**Schema:** `seeds` (not `marts`)

**Grain:** One row per waiting band category.

**Description:** Waiting band reference dimension. Seeded from `dim_waiting_band.csv`. Sits in the `seeds` schema and is consumed directly from there in the semantic model.

| Column | Data Type | Description |
|---|---|---|
| `waiting_band_sk` | int | Surrogate key. Primary key. Integer for efficient joining. |
| `waiting_band` | varchar | Waiting band label. Values: `Up to 18 weeks`, `18 to 52 weeks`, `Over 52 weeks`, `Unknown Clock Start`, `Total`. |
| `breach_18_flag` | int | Flag. 1 if this band represents patients waiting 18 or more weeks (in breach of the RTT standard); 0 otherwise. |
| `breach_52_flag` | int | Flag. 1 if this band represents patients waiting more than 52 weeks; 0 otherwise. |
| `is_total` | int | Flag. 1 if this row is the pre-computed total across all bands; 0 otherwise. |
| `ordinal` | int | Integer sort order for consistent display in reports. |

**Notes:**
- `breach_18_flag` is 1 for both the `18 to 52 weeks` and `Over 52 weeks` bands. When computing breach rate, filter to rows where `breach_18_flag = 1` and `is_total = 0`.
- Active semantic model relationships: to all three fact tables (relationships 9, 10, 11).

---

## Part 2: Fact Tables - Schema `marts` in `VBM_EquiWait_WH`

---

### `fact_waiting_list_geography`

**Grain:** One row per organisation per geography level per metric per demographic category per waiting band per snapshot date.

**Description:** Primary fact table for trust-level and geographic equity analysis. Monthly snapshot counts of incomplete RTT pathways by provider, demographic group, and waiting band. Covers all 183 organisations. Snapshot fact - rows cannot be summed across snapshot dates.

| Column | Data Type | Description |
|---|---|---|
| `snapshot_date` | date | Week-ending date of the most recent week in the monthly publication. Foreign key to `dim_date.Date` (relationship 2). |
| `geography_sk` | varchar | Foreign key to `dim_geography.geography_sk` (relationship 4). |
| `geography_level` | varchar | Geography hierarchy level. One of: `ENGLAND`, `REGION`, `ICB`, `TRUST`. Filter to one level to avoid cross-level double-counting. |
| `specialty_sk` | varchar | Carries the Not Applicable surrogate key (-1). No active semantic model relationship to `dim_specialty`. |
| `metric` | varchar | The demographic dimension. One of: `Age`, `Sex`, `Ethnicity`, `IMD`. |
| `demographic_sk` | varchar | Foreign key to `dim_demographic.demographic_sk` (relationship 7). |
| `waiting_band_sk` | int | Foreign key to `dim_waiting_band.waiting_band_sk` (relationship 10). |
| `patient_count` | int | Count of incomplete RTT pathways. NULL where suppressed. Rounded to the nearest 5. |

**Notes:**
- Do not sum `patient_count` across `geography_level` values or across `snapshot_date` values.
- Rows where `is_total = 1` in `dim_demographic` or `dim_waiting_band` are pre-computed totals. Exclude when summing across categories or bands.

---

### `fact_waiting_list_specialty`

**Grain:** One row per specialty per metric per demographic category per waiting band per snapshot date, at England level only.

**Description:** Specialty-level fact table for analysis of breach burden by treatment function and demographic concentration within each specialty. England level only. Basis for the representation index calculation.

| Column | Data Type | Description |
|---|---|---|
| `snapshot_date` | date | Week-ending date of the most recent week in the monthly publication. Foreign key to `dim_date.Date` (relationship 3). |
| `geography_sk` | varchar | Carries the Not Applicable surrogate key (-1). No active semantic model relationship to `dim_geography`. |
| `specialty_sk` | varchar | Foreign key to `dim_specialty.specialty_sk` (relationship 5). |
| `demographic_sk` | varchar | Foreign key to `dim_demographic.demographic_sk` (relationship 8). |
| `waiting_band_sk` | int | Foreign key to `dim_waiting_band.waiting_band_sk` (relationship 11). |
| `patient_count` | int | Count of incomplete RTT pathways at England level for this specialty, demographic group, and waiting band. NULL where suppressed. Rounded to the nearest 5. |

**Notes:**
- Cannot be joined to trust-level data to produce trust-by-specialty-by-demographic breakdowns. That intersection is not published in the WLMDS data.

---

### `fact_waiting_list_timeseries`

**Grain:** One row per week per metric per demographic category per waiting band, at England level only, for age and sex dimensions only.

**Description:** Historical weekly England-level fact table from September 2021. Age and sex only - ethnicity and IMD are not available in the Timeseries file. Used for longitudinal trend analysis.

| Column | Data Type | Description |
|---|---|---|
| `week_ending_date` | date | Sunday week-ending date. Foreign key to `dim_date.Date` (relationship 1). |
| `metric` | varchar | The demographic dimension. `Age` or `Sex` only. |
| `geography_sk` | varchar | Carries the Not Applicable surrogate key (-1). No active semantic model relationship to `dim_geography`. |
| `specialty_sk` | varchar | Carries the Not Applicable surrogate key (-1). No active semantic model relationship to `dim_specialty`. |
| `demographic_sk` | varchar | Foreign key to `dim_demographic.demographic_sk` (relationship 6). |
| `waiting_band_sk` | int | Foreign key to `dim_waiting_band.waiting_band_sk` (relationship 9). |
| `patient_count` | int | Count of incomplete RTT pathways at England level. NULL where suppressed. Rounded to the nearest 5. |

**Notes:**
- A structural break occurs in February 2024 when RTT reporting guidance was updated to remove community service pathways. Trend analysis spanning this date should be treated with caution.
- `geography_timeseries_reconciliation.sql` validates consistency between this table and the England-level rows in `fact_waiting_list_geography` for age and sex, for each snapshot month.

---

## Part 3: Semantic Model Analytical Tables

These tables exist in the Power BI semantic model but are not part of the star schema and are not deployed via dbt. They are derived analytical tables supporting specific dashboard pages.

---

### `stat_funnel_results`

**Source:** Derived analytical table in the Power BI semantic model. Not a warehouse table.

**Description:** Supports the funnel plot and outlier detection visualisation on the Statistical Tests page. Takes trust-level breach rate data from `fact_waiting_list_geography` and applies statistical control limit calculations to identify trusts that are outliers relative to the national rate. Connected to `fact_waiting_list_geography` via an active relationship.

| Column | Data Type | Description |
|---|---|---|
| `breach_rate` | decimal | Breach rate for the trust at the selected snapshot. Proportion of patients waiting 18 or more weeks. |
| `breached_pathways` | integer | Count of pathways in breach for the trust at the selected snapshot. |
| `ci_lower_2sd` | decimal | Lower control limit at 2 standard deviations. Trusts below this threshold are flagged as potential positive outliers. |
| `ci_lower_3sd` | decimal | Lower control limit at 3 standard deviations. |
| `ci_upper_2sd` | decimal | Upper control limit at 2 standard deviations. Trusts above this threshold are flagged as potential negative outliers. |
| `ci_upper_3sd` | decimal | Upper control limit at 3 standard deviations. |
| `is_outlier_alert` | boolean | Flag. True if the trust breach rate falls outside the 3 standard deviation control limits. |
| `is_outlier_warning` | boolean | Flag. True if the trust breach rate falls outside the 2 standard deviation control limits but within the 3 standard deviation limits. |
| `national_rate` | decimal | The national average breach rate used as the funnel plot centre line. |

**Notes:**
- Funnel plot control limits are calculated using the Wilson score interval method, which is standard practice for NHS statistical process control charts. Limits widen for trusts with smaller waiting lists, reflecting the greater statistical uncertainty in rates based on smaller denominators.
- `is_outlier_alert` (3SD) corresponds to the red alert threshold in NHS statistical process control convention. `is_outlier_warning` (2SD) corresponds to the amber warning threshold.
- This table is not part of the star schema and has no surrogate key or grain in the dimensional modelling sense. It is a reporting layer output.

---

## Part 4: Seeds

### `dim_waiting_band.csv`

Schema: `seeds`. Provides the stable `dim_waiting_band` reference table. Loaded via `dbt seed`. Columns as documented above.

### `trust_name_canonical.csv`

Schema: `seeds`. Canonical trust name mapping used to standardise organisation names across monthly releases. Used in `dim_geography` model to populate `trust_name`.

---

*VBM EquiWait - Data Dictionary - May 2026*
*All figures are management information. Not official statistics.*
