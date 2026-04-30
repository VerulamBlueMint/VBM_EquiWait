# Data Retrieval
## VBM EquiWait: Demographic Equity in NHS Waiting Lists

---

## Background

NHS England publishes the WLMDS demographic publication monthly as three CSV files. The publication page does not maintain a public archive of previous releases - only the most recent month is linked from the main page at any given time.

The complete published history from July 2025 to February 2026 was retrieved by reconstructing the URL pattern used for each monthly release on the NHS England server. The full backrun is accessible at the original URLs even though it is not linked from the publication page.

---

## URL Pattern

Each monthly release follows a consistent URL structure:

```
https://www.england.nhs.uk/statistics/wp-content/uploads/sites/2/YYYY/MM/WLMDS-Demographics-[FileType]-to-[DD]-[Month]-[YYYY]-v[N].csv
```

Where:

| Placeholder | Description | Example |
|---|---|---|
| `YYYY/MM` | Year and month of the publication directory | `2025/07` |
| `[FileType]` | One of `Geography`, `Specialty`, `Timeseries`, `Summary` | `Geography` |
| `[DD]` | Day of the week-ending date in the filename | `27` |
| `[Month]` | Full month name of the week-ending date | `July` |
| `[YYYY]` | Year of the week-ending date | `2025` |
| `[N]` | Version number, usually `1`. November 2025 was `v2`. | `1` |

---

## Complete URL List

### July 2025

```
https://www.england.nhs.uk/statistics/wp-content/uploads/sites/2/2025/07/WLMDS-Demographics-Geography-to-27-July-2025-v1.csv
https://www.england.nhs.uk/statistics/wp-content/uploads/sites/2/2025/07/WLMDS-Demographics-Specialty-to-27-July-2025-v1.csv
https://www.england.nhs.uk/statistics/wp-content/uploads/sites/2/2025/07/WLMDS-Demographics-Timeseries-to-27-July-2025-v1.csv
```

### August 2025

```
https://www.england.nhs.uk/statistics/wp-content/uploads/sites/2/2025/08/WLMDS-Demographics-Geography-to-31-August-2025-v1.csv
https://www.england.nhs.uk/statistics/wp-content/uploads/sites/2/2025/08/WLMDS-Demographics-Specialty-to-31-August-2025-v1.csv
https://www.england.nhs.uk/statistics/wp-content/uploads/sites/2/2025/08/WLMDS-Demographics-Timeseries-to-31-August-2025-v1.csv
```

### September 2025

```
https://www.england.nhs.uk/statistics/wp-content/uploads/sites/2/2025/09/WLMDS-Demographics-Geography-to-28-September-2025-v1.csv
https://www.england.nhs.uk/statistics/wp-content/uploads/sites/2/2025/09/WLMDS-Demographics-Specialty-to-28-September-2025-v1.csv
https://www.england.nhs.uk/statistics/wp-content/uploads/sites/2/2025/09/WLMDS-Demographics-Timeseries-to-28-September-2025-v1.csv
```

### October 2025

```
https://www.england.nhs.uk/statistics/wp-content/uploads/sites/2/2025/10/WLMDS-Demographics-Geography-to-26-October-2025-v1.csv
https://www.england.nhs.uk/statistics/wp-content/uploads/sites/2/2025/10/WLMDS-Demographics-Specialty-to-26-October-2025-v1.csv
https://www.england.nhs.uk/statistics/wp-content/uploads/sites/2/2025/10/WLMDS-Demographics-Timeseries-to-26-October-2025-v1.csv
```

### November 2025

```
https://www.england.nhs.uk/statistics/wp-content/uploads/sites/2/2025/11/WLMDS-Demographics-Geography-to-30-November-2025-v2.csv
https://www.england.nhs.uk/statistics/wp-content/uploads/sites/2/2025/11/WLMDS-Demographics-Specialty-to-30-November-2025-v2.csv
https://www.england.nhs.uk/statistics/wp-content/uploads/sites/2/2025/11/WLMDS-Demographics-Timeseries-to-30-November-2025-v2.csv
```

> Note: November 2025 was published as v2. The v1 files for November should not be used.

### December 2025

```
https://www.england.nhs.uk/statistics/wp-content/uploads/sites/2/2025/12/WLMDS-Demographics-Geography-to-28-December-2025-v1.csv
https://www.england.nhs.uk/statistics/wp-content/uploads/sites/2/2025/12/WLMDS-Demographics-Specialty-to-28-December-2025-v1.csv
https://www.england.nhs.uk/statistics/wp-content/uploads/sites/2/2025/12/WLMDS-Demographics-Timeseries-to-28-December-2025-v1.csv
```

### January 2026

```
https://www.england.nhs.uk/statistics/wp-content/uploads/sites/2/2026/01/WLMDS-Demographics-Geography-to-25-January-2026-v1.csv
https://www.england.nhs.uk/statistics/wp-content/uploads/sites/2/2026/01/WLMDS-Demographics-Specialty-to-25-January-2026-v1.csv
https://www.england.nhs.uk/statistics/wp-content/uploads/sites/2/2026/01/WLMDS-Demographics-Timeseries-to-25-January-2026-v1.csv
```

### February 2026

```
https://www.england.nhs.uk/statistics/wp-content/uploads/sites/2/2026/02/WLMDS-Demographics-Geography-to-22-February-2026-v1.csv
https://www.england.nhs.uk/statistics/wp-content/uploads/sites/2/2026/02/WLMDS-Demographics-Specialty-to-22-February-2026-v1.csv
https://www.england.nhs.uk/statistics/wp-content/uploads/sites/2/2026/02/WLMDS-Demographics-Timeseries-to-22-February-2026-v1.csv
```

---

## Loading into the Warehouse

Files are loaded into the `landing` schema of `VBM_EquiWait_WH` via Fabric Get Data rather than dbt seed. This is required because the CSV files contain Unicode content, Arabic script field names appear in some source files, which causes failures when loaded via dbt seed due to a known incompatibility between dbt-fabric and the Fabric Warehouse UTF-8 collation (`Latin1_General_100_BIN2_UTF8`). Fabric Get Data handles Unicode natively.

Each monthly release should be appended to the existing landing tables:

| File type | Landing table |
|---|---|
| Geography | `landing.wlmds_geography_landing` |
| Specialty | `landing.wlmds_specialty_landing` |
| Timeseries | `landing.wlmds_timeseries_landing` |

After loading, run `dbt build` to propagate the new data through staging, intermediate, and mart layers.

---

## Adding Future Releases

When a new monthly release is published:

1. Identify the week-ending date from the NHS England publication page.
2. Construct the three CSV URLs following the pattern above.
3. Download the Geography, Specialty, and Timeseries files.
4. Load into the three landing tables via Fabric Get Data, appending to existing data.
5. Run `dbt build` to refresh the mart layer.
6. Validate using `analyses/geography_timeseries_reconciliation.sql`.

The Summary file (`.xlsx`) is not loaded into the pipeline. It is retained in `source_data/` for reference only.

---

*VBM EquiWait - Data Retrieval Documentation - May 2026*
