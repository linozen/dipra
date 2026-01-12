# Stressanalyse - Diagnostisches Praktikum

Psychometrische Analysen für Stressskalen und Coping-Strategien.

## Projektstruktur (Neu Organisiert)

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
│   ├── 05-08_*.R             # Subgruppenanalysen
│   ├── 09_justification.R
│   ├── 10_final_comparison.R
│   ├── 11_normalization_and_tables.R  # ⭐ NEU: Zusammengeführt
│   └── 13_final_scale_metrics.R
│
├── data/                     # Daten & Workspaces
│   ├── data_stressskala_*.csv  # Rohdaten (Input)
│   ├── data.csv              # Bereinigte Daten
│   ├── 01_scales.RData       # Workspace mit allen Skalen
│   ├── 11_normierung.RData   # Normierungsanalysen
│   └── codebook.xlsx         # Codebuch
│
├── output/                   # Analyseergebnisse (CSV)
│   ├── normierung_*.csv      # Gruppenvergleiche
│   └── normtabellen/         # ⭐ NEU: Normtabellen als CSV
│       ├── normtabelle_stresssymptome.csv
│       ├── normtabelle_coping_*.csv
│       └── normtabelle_stressbelastung_*.csv
│
├── plots/                    # Visualisierungen (PNG)
│   ├── plot_01-04_*.png      # Deskriptive Statistiken
│   ├── plot_05-12_*.png      # Reliabilität
│   ├── plot_13-19_*.png      # Validität
│   └── plot_20-39_*.png      # Subgruppenanalysen
│
└── report/                   # Diagnostisches Praktikum - Report
    ├── main.typ              # Hauptdokument (Typst)
    └── main.pdf              # Report als PDF
```

## Schnellstart

### 1. Vollständige Analyse ausführen

```r
source("run_all.R")
```

Dies führt alle 13 Analyseschritte nacheinander aus (~5-10 Minuten).

**NEU:** Die gesamte Konsolenausgabe wird automatisch in einer Log-Datei gespeichert:
- Speicherort: `output/analysis_log_YYYYMMDD_HHMMSS.txt`
- Enthält: Alle Statistiken, Warnungen und Ergebnisse
- Format: Zeitgestempelt und vollständig durchsuchbar

### 2. Nur bestimmte Schritte ausführen

```r
# Zuerst: Setup laden
load("data/01_scales.RData")

# Dann: Einzelne Analysen
source("src/03_reliability.R")
source("src/11_normalization_and_tables.R")
```

### 3. Bei neuen Daten

Ändern Sie in `run_all.R`:

```r
RAW_DATA_FILE <- "data/data_stressskala_2025-XX-XX_XX-XX.csv"
```

Dann `source("run_all.R")` ausführen.

## Empfehlungen für weitere Verbesserungen

### 🎯 Hohe Priorität

1. **Funktionsbibliothek erstellen**
   ```r
   # src/utils/functions.R
   # Alle wiederverwendeten Funktionen (z.B. print_section, cohens_d)
   source("src/utils/functions.R")  # In jedem Skript
   ```

2. **Konfigurationsdatei einführen**
   ```r
   # config.R
   CONFIG <- list(
     data = list(
       raw = "data/data_stressskala_2025-12-18_10-13.csv",
       clean = "data/data.csv"
     ),
     output = list(
       plots = "manual/plots",
       tables = "manual/normtabellen"
     ),
     analysis = list(
       min_group_size = 20,
       alpha_level = 0.05,
       effect_size_threshold = 0.3
     )
   )
   ```

3. **Paket-Abhängigkeiten dokumentieren**
   ```r
   # src/00_packages.R
   required_packages <- c("tidyverse", "lavaan", "psych", "gridExtra")
   
   for (pkg in required_packages) {
     if (!require(pkg, character.only = TRUE)) {
       renv::install(pkg)
       library(pkg, character.only = TRUE)
     }
   }
   ```

4. **Logging verbessern**
   - Zeitstempel für jeden Schritt
   - Warnungen und Fehler in Log-Datei speichern
   - Zusammenfassung am Ende

### 💡 Mittlere Priorität

5. **Unit-Tests hinzufügen**
   ```r
   # tests/test_functions.R
   library(testthat)
   
   test_that("cohens_d berechnet korrekt", {
     x <- c(1, 2, 3, 4, 5)
     y <- c(2, 3, 4, 5, 6)
     d <- cohens_d(x, y)
     expect_equal(round(d, 2), -0.63)
   })
   ```

6. **Reproduzierbarkeit sichern**
   ```r
   # Am Anfang jedes Skripts
   set.seed(42)  # Für reproduzierbare Zufallszahlen
   
   # Session Info speichern
   writeLines(capture.output(sessionInfo()), 
              "output/session_info.txt")
   ```

7. **Datenvalidierung**
   ```r
   # src/utils/validate_data.R
   validate_data <- function(data) {
     # Prüfe:
     # - Pflichtfelder vorhanden
     # - Wertebereich korrekt (1-5 für Likert)
     # - Keine ungültigen Werte
     # - Mindeststichprobengröße
   }
   ```

8. **Parallelisierung für schnellere Ausführung**
   ```r
   library(parallel)
   cl <- makeCluster(detectCores() - 1)
   # Parallele Ausführung von unabhängigen Analysen
   # z.B. Subgruppenanalysen 05-07 gleichzeitig
   stopCluster(cl)
   ```

### 🔧 Niedrige Priorität (Nice-to-have)

9. **RMarkdown-Reports**
   - Automatische PDF/HTML-Berichte
   - Tabellen und Plots integriert
   - Für Seminararbeit oder Präsentation

10. **Interaktive Plots**
    ```r
    library(plotly)
    library(shiny)
    # Interaktive Normtabellen-Abfrage
    ```

11. **Code-Stil vereinheitlichen**
    - styler-Paket verwenden
    - lintr für Code-Qualität
    - Konsistente Namenskonventionen

12. **Git-Versionskontrolle**
    ```bash
    git init
    git add .
    git commit -m "Initial commit: Cleaned project structure"
    ```

## Code-Vereinfachungen

### Wiederholter Code eliminieren

**Vorher (in mehreren Skripten):**
```r
# Levene-Test Implementierung in 11_*.R
# print_section Funktion in vielen Skripten
# cohens_d Funktion mehrfach definiert
```

**Nachher:**
```r
# src/utils/functions.R
source("src/utils/functions.R")  # Einmal definieren
```

### Datenlade-Logik vereinfachen

**Vorher:**
```r
# In jedem Skript:
load("data/01_scales.RData")
```

**Besser:**
```r
# src/utils/load_data.R
load_project_data <- function(step = 1) {
  if (step == 1) {
    load("data/01_scales.RData", envir = .GlobalEnv)
  } else if (step == 11) {
    load("data/11_normierung.RData", envir = .GlobalEnv)
  }
  cat("✓ Daten geladen\n")
}
```

### Magic Numbers vermeiden

**Vorher:**
```r
if (abs(d) >= 0.3) {  # Was bedeutet 0.3?
  empfehlung <- "Getrennte Normen"
}
```

**Besser:**
```r
EFFECT_SIZE_THRESHOLD_SMALL <- 0.3
EFFECT_SIZE_THRESHOLD_MEDIUM <- 0.5

if (abs(d) >= EFFECT_SIZE_THRESHOLD_SMALL) {
  empfehlung <- "Getrennte Normen"
}
```
