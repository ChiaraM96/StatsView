# StatsView

**StatsView** is an interactive MATLAB desktop application for statistical analysis and visualization of experimental data. Built with MATLAB App Designer, it provides a comprehensive GUI for data management, statistical testing, and publication-quality figure generation — with a particular focus on psychophysiology and neuroscience research workflows.

---

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

### Key Functions

**`beta_index.m`**  
Calculates an emotional engagement index (EI) from z-scored skin conductance level (SCL) and heart rate (HR) using a 4-quadrant arctangent transformation. Returns values in [−1, 1].

**`boxchart_limits.m`**  
Computes optimal Y-axis limits for box charts using the 1.5×IQR outlier rule, grouped by category, with 10% visual padding.

**`boxplotting.m`**  
Main plotting engine. Generates publication-quality box and violin plots for simple and complex experimental designs, supporting multiple grouping variables, group statistics, and integrated significance annotations.

**`pValueLines.m`**  
Draws significance lines between compared conditions on a plot, with automatic vertical positioning to avoid overlap and color-coding by group.

---

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

## Usage

1. **Set up your data** — Use the *Data Setup* panel to point the app at your data files (physiological signals, sociodemographic info, questionnaires, annotations).
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
