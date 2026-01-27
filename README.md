# Stressanalyse - Diagnostisches Praktikum

Psychometrische Analysen für Stressskalen und Bewältigungsstrategien.

## Projektstruktur

```
.
├── run_all.R                 # Master-Skript (führt alle Analysen aus)
├── README.md                 # Diese Datei
├── renv.lock                 # R-Paket-Abhängigkeiten
│
├── src/                      # Alle Analyseskripte
│   ├── 00_clean_data.R       # Datenbereinigung
│   ├── 01_setup_and_scales.R # Skalen konstruieren
│   ├── 02_descriptive_plots.R
│   ├── 03_reliability.R
│   ├── 04_validity_main.R
│   ├── 05_validity_subgroups_stress.R
│   ├── 06_validity_subgroups_symptoms.R
│   ├── 07_validity_subgroups_coping.R
│   ├── 08_create_subgroup_plots.R
│   ├── 09_justification.R
│   ├── 10_final_comparison.R
│   ├── 11_normalization_and_tables.R
│   ├── 12_final_scale_metrics.R
│   └── 13_nomological_network.R
│
├── data/                     # Daten & Workspaces
│   ├── data_stressskala_*.csv  # Rohdaten (Input)
│   ├── data.csv              # Bereinigte Daten
│   ├── workspace.RData       # Workspace mit allen Skalen
│   └── codebook.xlsx         # Codebuch
│
├── manual/                   # Diagnostisches Praktikum - Manual
│   ├── main.typ              # Hauptdokument (Typst)
│   ├── main.pdf              # Manual als PDF
│   ├── zotero.bib            # Literaturverzeichnis
│   │
│   ├── plots/                # Visualisierungen (PNG, 51 Plots)
│   │   ├── 01-04_*.png       # Deskriptive Statistiken
│   │   ├── 05-12_*.png       # Reliabilität
│   │   ├── 13-19_*.png       # Validität
│   │   └── 20-*_*.png        # Subgruppenanalysen & weitere
│   │
│   └── output/               # Analyseergebnisse
│       ├── analysis_log_*.txt  # Vollständige Konsolenausgabe
│       ├── nomological_network_correlations.csv
│       └── normtabellen/     # Normtabellen als CSV
│           ├── normtabelle_stresssymptome.csv
│           ├── normtabelle_coping_*.csv
│           └── normtabelle_stressbelastung_*.csv
│
└── plots/                    # Leeres Verzeichnis (historisch)
```

## Schnellstart

### Vollständige Analyse ausführen

```r
source("run_all.R")
```

Dies führt alle Analyseschritte nacheinander aus. Die gesamte Konsolenausgabe wird automatisch in einer Log-Datei gespeichert:
- Speicherort: `manual/output/analysis_log_YYYYMMDD_HHMMSS.txt`
- Enthält: Alle Statistiken, Warnungen und Ergebnisse
- Format: Zeitgestempelt und vollständig durchsuchbar

### Einzelne Schritte ausführen

```r
# Setup laden
load("data/workspace.RData")

# Einzelne Analysen
source("src/03_reliability.R")
source("src/11_normalization_and_tables.R")
source("src/13_nomological_network.R")
```

### Bei neuen Daten

Ändern Sie in `run_all.R`:

```r
RAW_DATA_FILE <- "data/data_stressskala_2025-XX-XX_XX-XX.csv"
```

Dann `source("run_all.R")` ausführen.

## Daten anfordern

Die Rohdaten können aus Datenschutzgründen nicht öffentlich bereitgestellt werden. Anfragen können gestellt werden:

- Via GitHub Issue in diesem Repository
- Per E-Mail an: dipra [at] sehn.tech

## Reproduzierbarkeit

Alle Analysen sind vollständig reproduzierbar. Das Projekt verwendet `renv` für Paket-Versionskontrolle:

```r
# Abhängigkeiten installieren
renv::restore()
```
