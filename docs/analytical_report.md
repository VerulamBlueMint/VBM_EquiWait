# Analytical Report
## VBM EquiWait: Demographic Equity in NHS Waiting Lists
### NHS Waiting List Minimum Dataset (WLMDS) Demographic Analysis
*Verulam Blue - May 2026*
*Based on eight monthly snapshots of the WLMDS demographic publication, July 2025 to February 2026*

---

## Definitions and Terminology

The following terms are used consistently throughout this document.

**Waiting List Minimum Dataset (WLMDS):** A weekly data collection submitted by NHS providers to NHS England covering open pathways (patients currently waiting), clock starts (new referrals), and clock stops (treatment commencing or patient leaving the list). The demographic publication, adding breakdowns by age, sex, ethnicity and deprivation, was first released in July 2025 and is updated monthly.

**Breach rate:** The proportion of incomplete RTT pathways where the patient has been waiting 18 or more weeks.

**Severe breach rate:** The proportion of incomplete RTT pathways where the patient has been waiting 52 or more weeks.

**Representation index:** A measure of whether a demographic group is over- or under-represented in the long wait band (18 or more weeks) relative to their share of the total waiting list for a given specialty. A value above 1.0 indicates the group makes up a larger proportion of long waiters than their share of the overall list for that specialty. A value below 1.0 indicates the reverse. A value of 1.0 indicates proportionate representation. The index is computed from published WLMDS counts and is subject to the same data quality limitations as the underlying figures.

**Equity threshold:** The representation index value of 1.0, the point at which a group's share of long waiters equals their share of the total list. Values above this threshold indicate over-representation; values below indicate under-representation.

---

## Scope and Purpose

This report documents the analytical findings from the VBM EquiWait platform. The analysis covers eight monthly releases of the NHS England WLMDS demographic publication from July 2025 to February 2026, assembled into a longitudinal dataset covering 183 organisations, 24 specialties, and four demographic dimensions.

All findings are descriptive. They identify patterns in administrative data and note where those patterns are consistent or pronounced. They do not establish causes, assign responsibility, or support conclusions about why any particular pattern exists. Figures are management information, not official statistics.

---

## Patterns of Variation

The WLMDS data highlights distinct patterns of waiting time variation across three dimensions. These are described here because they shape how the findings below should be read.

**Specialty** is where variation is largest, with a 30 percentage point gap separating Ear Nose and Throat (approximately 48% breach rate) from Elderly Medicine (approximately 17%).

**Geography and trust** show the next greatest variation, with the East of England running around 5 percentage points above the national average in every month and the North East and Yorkshire running around 5 points below.

**Demographic characteristics** show the smallest variation across the three dimensions. Effect sizes are small at the individual level, but specific subgroup patterns are consistent and carry significance for equity monitoring.

Each dimension points to different levers and different parts of the system. The report tries to be explicit about which is which throughout.

---

## Statistical Framework

### Tests conducted

For each of the four demographic dimensions (Age, Sex, Ethnicity, IMD) and each of the eight monthly snapshots, a chi-square test of independence was conducted with the null hypothesis that there is no association between the demographic dimension and waiting band at England level. This produced 32 tests in total (4 dimensions multiplied by 8 months). P-values were adjusted using the Benjamini-Hochberg procedure to control the false discovery rate across the family of 32 tests.

### Results

| Dimension | Cramers V range | Degrees of freedom | All adjusted p-values |
|---|---|---|---|
| Age | 0.028 to 0.038 | 4 | less than 0.0001 |
| Ethnicity | 0.009 to 0.013 | 30 | less than 0.0001 |
| IMD | 0.005 to 0.009 | 18 | less than 0.0001 |
| Sex | 0.007 to 0.012 | 2 | less than 0.0001 |

### Interpretation

With N approximately 7 million patients, statistical significance is mathematically guaranteed even for trivially small associations. A Cramers V of 0.01 produces a chi-square in the thousands at this sample size. Cramers V values below 0.10 are generally considered small - all values are well below this threshold. The correct interpretation is that the patterns are confirmed non-random, but the individual-level association between demographic characteristics and waiting band is negligible. The significance of the demographic findings lies in their consistency and directionality across the full window.

### Representation index

The representation index measures whether a demographic group makes up a larger or smaller share of the long wait band (18 or more weeks) than their share of the total waiting list for a given specialty. A value above 1.0 indicates over-representation; below 1.0 indicates under-representation; 1.0 indicates proportionate representation.

---

## Finding 01 - Deprivation: A Consistent Gradient in Long Waits

In every monthly snapshot from July 2025 to February 2026, patients from IMD Decile 1 (most deprived) make up a larger share of the long wait band than their share of the total waiting list. Moving from Decile 1 to Decile 10, the degree of over-representation decreases at each step, in the same direction in every month.

The individual-level association is small. Cramers V for IMD is 0.005 to 0.009. The significance of the finding lies in its directional consistency across the full window. Absolute differences between the most and least deprived groups are in the range of 0.3 to 1.2 percentage points.

All 8 monthly tests for the IMD dimension return adjusted p-values below 0.0001, confirming the pattern is not plausibly attributed to sampling variation. The data does not establish what is producing this pattern.

Trusts and regions serving more deprived populations also tend to show higher breach rates in this data. Whether and how these patterns are related is not something this analysis can determine. They are noted as features of the data that sit alongside each other.

The NHS public sector equality duty includes having due regard to advancing equality of opportunity. This is noted as context for why monitoring demographic patterns in waiting times is part of what NHS organisations are expected to consider. It is not offered as a basis for any compliance assessment.

---

## Finding 02 - Ethnicity: System-Wide Over-Representation for Specific Groups

In every monthly snapshot from July 2025 to February 2026, patients recorded as Indian, Pakistani or Bangladeshi make up a larger share of the 18 to 52 week wait band than their share of the total waiting list. The same groups appear in the same direction in all eight months. The aggregate Cramers V for ethnicity is 0.009 to 0.013. The finding is noted for its consistency across time and its concentration in specific groups, not for the size of the individual-level effect.

Eight months of data in the same direction for the same groups is harder to attribute to chance than any single month's result. The data does not suggest that any individual or organisation has acted inappropriately. It identifies where consistent patterns exist and notes that they are worth understanding.

---

## Finding 03 - Ethnicity: Specialty Mix Does Not Explain the Long-Wait Gap

One explanation for the pattern in Finding 02 requires no assumption of unequal treatment: these groups may simply be concentrated in specialties with the highest breach rates. If true, the over-representation would be a composition effect, a product of which services they are waiting for, not how they are treated within those services. Two tests assess this directly.

First, Bhattacharyya coefficients comparing each group's specialty distribution to the national average range from 0.987 to 0.998 across all eight months, indicating near-identical distributions. A necessary condition for the specialty mix explanation, that these groups are concentrated in higher-breach specialties, is not met.

Second, direct standardisation estimates the breach rate each group would experience if they faced national breach rates within each specialty, given their actual specialty mix. Across all eight months, actual breach rates exceed expected rates for all three groups. The gap is consistently positive: up to +2.0 percentage points for Pakistani patients, up to +1.8 percentage points for Bangladeshi patients, and smaller but consistently positive for Indian patients. If specialty mix were the explanation, expected and actual breach rates would align after adjustment. They do not.

These analyses do not identify the cause of the remaining gap. They establish that specialty mix is not the primary explanation for the observed over-representation.

---

## Finding 04 - Regional Geography: A Persistent East of England Gap

Regional breach rates show a consistent ordering across all eight months. No region switches position materially.

East of England has the highest breach rate and severe breach rate of any region in every month. Its waiting list of 757,000 to 859,000 is the fourth largest of seven regions, so list size alone does not account for the gap. Its breach rate runs approximately 4 to 5 percentage points above the national average in every month. As a descriptive illustration of scale: if East of England's breach rate were equal to the national average, approximately 32,000 to 40,000 fewer patients would be in breach at any given snapshot.

North East and Yorkshire has the lowest breach rate of any region in every month, with a list of 870,000 to 994,000 - comparable in size to East of England. The observation that two regions of similar size sit at opposite ends of the observed distribution, consistently across eight months, is recorded as a descriptive fact. The data does not establish what accounts for this difference.

September 2025 is the only month where every region shows above-average severe breach rates simultaneously - a feature of that month's data rather than a pattern specific to any one region. The regional ordering is maintained within it.

London carries the largest regional list (consistently 1.2 to 1.3 million) and sits near the national average on breach rate throughout, with below-average severe breach rates in most months from December onwards. North West and South East are persistently above the national average on severe breach rate. South West is below average on both metrics in every month with the smallest regional list.

Mid and South Essex sits within East of England and contributes materially to the regional picture, but the region's breach rate exceeds the national average across its full set of constituent trusts, not only those appearing in the national top ten.

---

## Finding 05 - Trust-Level Variation: Scale and Persistence

Mid and South Essex NHS Foundation Trust has the largest and most persistent gap to the national average in the trust-level data. It is presented here as the clearest illustration of a wider pattern of stable trust-level variation, not as an isolated case.

| Month | Waiting List | Breach Rate | vs National (pp) | Severe Breach Rate |
|---|---|---|---|---|
| Jul 2025 | 171,965 | 50.39% | +10.51 | 7.75% |
| Aug 2025 | 174,720 | 49.95% | +9.99 | 8.15% |
| Sep 2025 | 176,715 | 50.02% | +10.01 | 8.53% |
| Oct 2025 | 179,405 | 50.29% | +11.00 | 8.75% |
| Nov 2025 | 178,750 | 51.18% | +12.05 | 8.27% |
| Dec 2025 | 177,565 | 52.49% | +12.66 | 8.19% |
| Jan 2026 | 175,290 | 52.56% | +12.67 | 8.57% |
| Feb 2026 | 175,275 | 51.75% | +12.64 | 7.98% |

The data does not explain what is producing this gap. It shows the scale and consistency of the difference across the window.

The wider trust-level pattern involves a stable group of organisations that appear in the highest-breach positions across most months. United Lincolnshire Teaching Hospitals and University Hospitals Sussex appear in the top ten in seven of eight months each. James Paget University Hospitals appears in all eight months with a list of approximately 32,000 to 35,000 patients - a trust where the challenge is specific to that organisation rather than a volume problem.

Liverpool Women's records a severe breach rate of 10.65% in October and 12.02% in December despite ranking only 8th or 9th on overall breach rate in those months. At approximately 8,000 patients this represents around 960 people waiting more than a year. This illustrates a limitation of using a single headline metric: the overall breach rate does not always surface the most acute concentrations of very long waiters.

---

## Finding 06 - Specialty: The Largest Source of Variation

Ear Nose and Throat has the highest breach rate of any specialty in every month across the window, at approximately 47 to 50%, running 7 to 10 percentage points above the national average consistently. Oral Surgery is second or joint-first in every month. Plastic Surgery is third at approximately 42 to 48%. The ranking does not change across the eight-month window and the rates do not move materially.

At the other end, Elderly Medicine sits at approximately 17% throughout. Other Mental Health and unspecified Other services are similarly far below the national average in every month.

The gap between the highest and lowest specialty breach rates is approximately 30 percentage points. This is larger than regional variation and larger than any demographic effect. The specialty a patient enters is the largest single observable factor associated with how long they wait in this data.

The ordering of specialties does not change materially across the eight-month window. No specialty moves from high-breach to low-breach or vice versa.

The specialty finding is directly relevant to the ethnicity finding in Finding 02: the ethnic group over-representation is absent from the three highest-breach specialties, confirming it is not explained by these groups entering structurally pressured pathways.

---

## Finding 07 - National Position: Stable Access, Falling Extreme Waits

The national 18-week breach rate opens at 39.87% in July 2025 and closes at 39.11% in February 2026, moving within a band consistent with normal variation rather than any directional trend. Approximately 2.8 million patients are in breach at every snapshot. This is consistent with published RTT statistics over this period.

The severe breach rate - the proportion of patients waiting 52 or more weeks - shows a clearer change, falling from 2.79% in July to 1.92% in February. At approximately 7 million patients, this corresponds to approximately 61,000 fewer patients waiting more than a year by February compared to July. The data records this change but does not indicate what produced it.

---

## What This Analysis Can and Cannot Support

**The analysis supports:** describing the scale and consistency of waiting time variation across specialties, trusts and regions; reporting demographic patterns confirmed as non-random and consistent over time; noting where specific subgroups show directional over-representation in long wait bands; providing a baseline against which subsequent monthly releases can be compared.

**The analysis does not support:** explaining why any trust, region or specialty shows the pattern it does; establishing causation for any observed pattern; assessing performance in a way that accounts for the different circumstances facing different organisations; determining whether any organisation has met or not met any legal obligation.

---

## Limitations

| Limitation | Detail |
|---|---|
| Management information status | WLMDS is subject to less central validation than monthly RTT official statistics. Trust-level figures should be interpreted with appropriate caution. |
| Demographic exclusion gap | Patients with unknown demographic information are excluded from the relevant breakdown but retained in the total. Percentages are calculated on a sub-population whose completeness varies by trust and dimension. |
| Ethnicity augmentation | SUS records are used where WLMDS submission is missing. Degree of augmentation varies by trust and is not published. |
| No trust-level specialty intersection | Specialty-demographic breakdowns are available at England level only. |
| Snapshot non-additivity | Geography and Specialty files cannot be summed across time periods. |
| Suppression and rounding | Values below the disclosure threshold are shown as * in source files and set to NULL in the mart. All counts are rounded to the nearest 5. |
| Timeseries ethnicity and IMD | Longitudinal ethnicity and deprivation analysis is limited to the eight Geography snapshots. |
| Sheffield Teaching Hospitals | Excluded from national and regional totals from October 2025 onwards due to EPR migration. |
| February 2024 structural break | Community service pathways were removed from the Timeseries data in February 2024. Trend analysis spanning this date should be treated with caution. |

---

*VBM EquiWait - Analytical Report - May 2026*
*All figures are management information. Not official statistics.*
*This report is an independent analytical case study produced by Matthew Barr of Verulam Blue.*
*It does not represent the views of NHS England, any NHS trust, any Integrated Care Board, or any government body.*
