# Stressskala Analysis Pipeline

This repository contains a modular R analysis pipeline for the psychometric validation of (short version of) stress, symptom, and coping scales within the context of the course "Diagnostisches Praktikum" at the University of Mannheim

## Directory Structure

```
.
├── data/                            # Data directory
│   ├── data_stressskala_*.csv       # Raw input data (ISO-8859-1)
│   ├── data.csv                     # Cleaned data (UTF-8)
│   └── 01_scales.RData              # Shared workspace with all scales
├── plots/                           # Generated plots (35 total)
├── output/                          # Analysis output logs
├── renv/                            # renv library directory
├── renv.lock                        # Dependency lockfile
├── .Rprofile                        # renv activation script
├── 00_clean_data.R                  # Data cleaning and preparation
├── 01_setup_and_scales.R            # Setup, filtering, scale construction
├── 02_descriptive_plots.R           # Descriptive visualizations (plots 01-04)
├── 03_reliability.R                 # Reliability analyses (plots 06-12)
├── 04_validity_main.R               # Main validity analyses (plots 13-16)
├── 05_validity_subgroups_stress.R   # Stress subgroup analyses
├── 06_validity_subgroups_symptoms.R # Symptoms subgroup analyses
├── 07_validity_subgroups_coping.R   # Coping subgroup analyses
├── 08_create_subgroup_plots.R       # Subgroup visualizations (plots 17a-20e)
└── run_all.R                        # Master script to run entire pipeline
```

## Setup

### Install Dependencies

This project uses `renv` for reproducible dependency management. To set up the environment:

```r
# Install renv if not already installed
install.packages("renv")

# Restore project dependencies from lockfile
renv::restore()
```

This will install all required packages with the exact versions specified in `renv.lock`.

## Quick Start

### Primary CLI Entrypoint

To run the entire analysis pipeline from the command line with timestamped output:

```bash
Rscript run_all.R > output/analysis_output_$(date +%Y%m%d_%H%M%S).txt
```

This will:
- Execute all scripts in the correct sequence (00 → 08)
- Save all console output to a timestamped file in `output/`
- Generate all 35 plots in the `plots/` directory
- Provide timing information for each step

### Alternative (Interactive)

From within R:

```r
source("run_all.R")
```

## Script Descriptions

### 00_clean_data.R
- Converts raw CSV from ISO-8859-1 to UTF-8 encoding
- Cleans occupation field and categorizes into: Studenten, Angestellte, Andere
- **Input**: `data/data_stressskala_2025-11-09_17-36.csv`
- **Output**: `data/data.csv`

### 01_setup_and_scales.R
- Loads cleaned data
- Applies filters: age ≥ 18, attention check (SO02_14 == 4)
- Constructs all scales:
  - Neurotizismus, Resilienz, Zufriedenheit (validity criteria)
  - Stress scales (short, long, single-item versions)
  - Symptom scales (short, long, single-item versions)
  - Coping scales (active, drugs, positive, social, religious)
- **Output**: `data/01_scales.RData` (workspace for all subsequent scripts)

### 02_descriptive_plots.R
- Generates descriptive statistics and visualizations
- **Plots**: 01 (age), 02 (gender), 03 (occupation), 04 (education)

### 03_reliability.R
- Performs reliability analyses for all scales
- Cronbach's Alpha + Confirmatory Factor Analysis (CFA)
- **Plots**: 06-12 (factor loadings for stress, symptoms, 5 coping scales)

### 04_validity_main.R
- Tests convergent validity with Zufriedenheit, Neurotizismus, Resilienz
- Analyzes stress, symptoms, and all coping scales
- **Plots**: 13-16 (scatter plots, correlation heatmaps)

### 05_validity_subgroups_stress.R
- Subgroup validity analysis for stress scales
- Tests across: Gender, Education, Age, Occupation
- Uses Fisher's Z-test to compare correlation differences

### 06_validity_subgroups_symptoms.R
- Subgroup validity analysis for symptom scales
- Tests across: Gender, Education, Age, Occupation
- Uses Fisher's Z-test to compare correlation differences

### 07_validity_subgroups_coping.R
- Subgroup validity analysis for all 5 coping scales
- Tests across: Gender, Education, Age, Occupation
- Uses Fisher's Z-test to compare correlation differences

### 08_create_subgroup_plots.R
- Creates comprehensive scatter plot visualizations for all subgroup analyses
- Uses regression lines with 95% confidence intervals for each demographic subgroup
- Splits plots by scale type and validity criterion for clarity:
  - **a plots**: Stressbelastung × 3 validity criteria
  - **b plots**: Stresssymptome × 3 validity criteria
  - **c plots**: 5 Coping scales × Zufriedenheit
  - **d plots**: 5 Coping scales × Neurotizismus
  - **e plots**: 5 Coping scales × Resilienz
- **Plots**: 17a-e (gender), 18a-e (education), 19a-e (age), 20a-e (occupation)

### run_all.R
- Master orchestration script
- Runs all scripts in correct sequence (00 → 08)
- Tracks execution time and provides status updates
- Can redirect output to timestamped log files

## Key Features

### Modular Design
Each script is independent and can be run separately (after running prerequisites). All scripts 02-08 load the shared workspace from `data/01_scales.RData`.

### Workspace Sharing
Script 01 creates a shared workspace containing:
- Cleaned and filtered data
- All constructed scales
- Helper function `print_section()`

This avoids code duplication across scripts.

### Comprehensive Subgroup Analysis
All three scale types (stress, symptoms, coping) are analyzed across four demographic subgroups:
1. **Gender**: Männlich vs Weiblich
2. **Education**: Niedrig (≤ 3) vs Mittel (4) vs Hoch (5-7)
3. **Age**: Jung (<30) vs Mittel (30-45) vs Alt (>45)
4. **Occupation**: Multiple categories (with n ≥ 20)

Fisher's Z-test is used to test whether correlations differ significantly between groups.

### Clear Visualization Strategy
Subgroup plots use scatter plots with colored regression lines:
- Each demographic group gets a distinct color
- 95% confidence intervals shown as shaded bands
- Coping scales split by validity criterion to avoid crowding
- Larger, clearer panels for better interpretation

## Requirements

### R Version
- R >= 4.5.0

### Package Management
This project uses `renv` for dependency management. All required packages and their versions are specified in `renv.lock`. Simply run:

```r
renv::restore()
```

### Core Packages
The analysis pipeline requires:
- **psych** (2.5.6): Reliability analysis, correlation matrices
- **lavaan** (0.6-20): Confirmatory Factor Analysis (CFA)
- **ggplot2** (3.5.2): Data visualization
- **gridExtra** (2.3): Multi-panel plots
- **lintr** (3.1.3): Code quality checks
- **styler** (1.10.4): Code formatting

All dependencies are automatically installed via `renv::restore()`.

## Sample Characteristics

After filtering (age ≥ 18, attention check):
- N = 160 participants
- Age range: 18-63 years
- Demographics captured: gender, education, occupation

## Scales Analyzed

### Stress
- Short scale (5 items): NI06_01 to NI06_05
- Long scale (10 items): NI06_01 to NI06_10
- Single item: NI06_10

### Symptoms
- Short scale (5 items): NI03_01 to NI03_05
- Long scale (10 items): NI03_01 to NI03_10
- Single item: NI03_10

### Coping (5 types)
1. Active coping: SO23_01, SO23_20, SO23_14, NI07_05
2. Drug use: SO23_02, SO23_09, SO23_12
3. Positive thinking: SO23_03, SO23_05, SO23_13 (reversed)
4. Social support: SO23_06, SO23_19, SO23_21
5. Religious coping: SO23_07, SO23_22, SO23_18

### Validity Criteria
- Zufriedenheit (life satisfaction): NI01_01 to NI01_05
- Neurotizismus (neuroticism): SO02_04, SO02_09 (reversed)
- Resilienz (resilience): SO24_01 to SO24_06

## Output

### Plots (35 total)
- **01-04**: Descriptive statistics (age, gender, occupation, education)
- **06-12**: Factor loadings and reliability (stress, symptoms, 5 coping scales)
- **13-16**: Main validity analyses (scatter plots, correlation heatmaps)
- **17a-e**: Gender subgroups
  - 17a: Stressbelastung × 3 validity criteria
  - 17b: Stresssymptome × 3 validity criteria
  - 17c: 5 Coping scales × Zufriedenheit
  - 17d: 5 Coping scales × Neurotizismus
  - 17e: 5 Coping scales × Resilienz
- **18a-e**: Education subgroups (same structure as gender)
- **19a-e**: Age subgroups (same structure as gender)
- **20a-e**: Occupation subgroups (same structure as gender)

All subgroup plots feature:
- Scatter plots with individual data points (semi-transparent)
- Colored regression lines for each demographic group
- 95% confidence intervals as shaded bands
- Clear titles and axis labels

### Console Output
- Cronbach's Alpha values
- CFA fit indices (CFI, TLI, RMSEA, SRMR)
- Correlation coefficients with significance tests
- Subgroup comparison results (Fisher's Z-test)
- Execution timing for each step

### Log Files
When using the CLI entrypoint, all output is saved to `output/analysis_output_YYYYMMDD_HHMMSS.txt`

## Notes

- All scripts include section headers with `print_section()` for easy progress tracking
- Reverse coding is applied where needed (e.g., SO23_13, SO02_09)
- Missing data is handled via `rowMeans()` with `na.rm = TRUE`
- Main plots are saved as PNG files (1200×900, 150 DPI)
- Subgroup plots use larger dimensions (1800×600 for a/b, 1800×1200 for c/d/e)

## Troubleshooting

If you encounter encoding issues:
- Ensure raw data file is in ISO-8859-1 encoding
- Check that input file path in `00_clean_data.R` matches your data file

If workspace loading fails:
- Run `01_setup_and_scales.R` first to create `data/01_scales.RData`
- Ensure `data/` directory exists

If plots are not generated:
- Check that `plots/` directory exists
- Verify all required packages are installed
- For subgroup plots, ensure `gridExtra` package is installed

## Example Workflow

```bash
# Create output directory if it doesn't exist
mkdir -p output

# Run full analysis with timestamped output
Rscript run_all.R > output/analysis_output_$(date +%Y%m%d_%H%M%S).txt

# View plots
open plots/

# Review log file
cat output/analysis_output_*.txt | tail -100
```

## Dependency Management with renv

### For New Users
When you first clone this repository:

```r
# renv will be automatically activated by .Rprofile
# Install all dependencies from lockfile
renv::restore()
```

### For Developers
If you add new packages to the analysis:

```r
# Install new package
install.packages("newpackage")

# Update lockfile with new dependencies
renv::snapshot()
```

### Common renv Commands
```r
# Check project status
renv::status()

# Update a specific package
renv::update("ggplot2")

# View installed packages
renv::dependencies()

# Deactivate renv (if needed)
renv::deactivate()
```

### renv Files
- **renv.lock**: Lockfile with exact package versions (commit this)
- **renv/**: Library directory containing packages (don't commit)
- **.Rprofile**: Automatically activates renv (commit this)
- **renv/.gitignore**: Ensures library isn't committed

## Future Work

- Add additional validation analyses as needed
- Consider automation for different data collection timepoints
- Export results to LaTeX tables for publication
- Add sensitivity analyses for different cutoffs
- Implement parallel processing for faster execution
