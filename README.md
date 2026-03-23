# StatsView
**StatsView** is an interactive MATLAB desktop application for statistical analysis and visualization of experimental data. Built with MATLAB App Designer, it provides a comprehensive GUI for data management, statistical testing, and publication-quality figure generation — with a particular focus on psychophysiology and neuroscience research workflows.

## Features
### Data Management
- Load and integrate data from multiple sources:
  - Physiological signals (e.g., heart rate, skin conductance)
  - Sociodemographic data
  - Psychological questionnaires
  - Signal annotations and clustering results
- Edit variable types (within-subject, between-subject, response, covariate)
- Filter data by specific condition levels
### Statistical Testing
Four experimental design types are supported:
| Design | Description |
|---|---|
| **Within-subject** | Repeated-measures tests for single groups |
| **Between-subject** | Comparisons between independent groups |
| **Mixed** | Combined within- and between-subject designs |
| **Stratified** | Tests stratified by a selected variable |

Results are displayed in tabbed tables with p-values, with automatic filtering at α = 0.05.
### Visualization
- **Box plots** — quartiles, median, whiskers, and outliers
- **Violin plots** — distribution density overlaid with box plots
- **Trend lines** — mean and/or median markers connected across conditions
Customization options include font size, line weight, group color-coding, axis limit auto-calculation (IQR-based), and the ability to split plots by between-subject classes.
Statistical significance is annotated directly on plots with connecting lines and p-values in scientific notation.
### Export
- Export figures and statistics tables together
- Copy plots to clipboard
---
## Repository Structure
```
StatsView/
├── AppBase/
│   ├── StatsView.mlapp          # Main App Designer application
│   └── Functions/
│       ├── beta_index.m         # Emotional engagement index calculation
│       ├── boxchart_limits.m    # Automatic Y-axis limit computation
│       ├── boxplotting.m        # Core plotting function
│       └── pValueLines.m        # Statistical significance annotation
└── release/
    ├── StatsView.mltbx          # MATLAB toolbox package
    └── deploymentLog.html       # Deployment log
```

## Requirements
- MATLAB R2023a or later
- MATLAB App Designer (included with MATLAB)
- Statistics and Machine Learning Toolbox (recommended)
---
## Installation
### Option 1 — Toolbox (recommended)
1. Download `StatsView.mltbx` from the `release/` folder.
2. Double-click the file in MATLAB to install it as a toolbox.
3. Launch the app from the MATLAB **Apps** tab.
### Option 2 — Source
1. Clone or download this repository.
2. Open `AppBase/StatsView.mlapp` in MATLAB App Designer.
3. Click **Run** to launch the app.
---

## Input Data Format

StatsView expects a long-format table where each row is a single observation. The table must include:

- An **`ID` column** (categorical) identifying each subject
- One or more **categorical columns** representing experimental factors — automatically classified as:
  - *Between-subjects* if each subject belongs to a single category
  - *Within-subjects* if a subject appears across multiple categories
- One or more **numeric columns** treated as response variables

Optionally, columns can include custom properties (`IsWithin`, `IsBetween`, `IsCovariate`, `IsResponse`) to override the automatic classification.
To add custom properties: 

`Indexes = addprop(Indexes, {'IsWithin', 'IsBetween', 'IsCovariate', 'IsResponse'}, {'variable', 'variable', 'variable', 'variable'});`

Then, set `Indexes.CustomProperties.IsWithin` to 1 for variables that are Within variables, 0 for all the others (do the same for Between, Covariates, and Responses).

## Usage

1. **Set up your data** — Import the dataset with your data using the Load Dataset button. (physiological signals, sociodemographic info, questionnaires, annotations).
2. **Configure variables** — In the *Variable Editor* panel, classify each variable as within-subject, between-subject, response, or covariate.
3. **Select analysis** — Choose the response variable, grouping variables, comparison cases, and which statistical tests to run.
4. **Plot** — Select plot type (box, violin) and trend line options, then generate the figure.
5. **Export** — Save the figure and statistics together or copy the plot to the clipboard.
---
## License
See [LICENSE](LICENSE) for details.
---
## Author
Developed by **Chiara Maninetti**.
