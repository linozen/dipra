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
└── plots/                    # Visualisierungen (PNG)
    ├── plot_01-04_*.png      # Deskriptive Statistiken
    ├── plot_05-12_*.png      # Reliabilität
    ├── plot_13-19_*.png      # Validität
    └── plot_20-39_*.png      # Subgruppenanalysen
```

## Wichtige Änderungen (2025-12-19)

### ✅ Durchgeführte Verbesserungen

1. **Projektstruktur vereinfacht**
   - Alle R-Skripte in `src/` Verzeichnis verschoben
   - Bessere Trennung: Code (src/), Daten (data/), Output (output/, plots/)

2. **Normierungsskripte zusammengeführt**
   - `11_normalization_analysis.R` + `12_create_norm_tables.R` 
     → `11_normalization_and_tables.R`
   - README-Dokumentation als Kommentare ins Skript integriert
   - Reduziert Komplexität von 14 auf 13 Skripte

3. **CSV statt PNG für Normtabellen**
   - Einfachere Weiterverarbeitung (Excel, R, Word)
   - Bessere Integration in Test-Manual
   - Speicherort: `output/normtabellen/*.csv`

4. **Zentrale Datenpfad-Konfiguration**
   - Alle Pfade zu Rohdaten in `run_all.R` definiert
   - Bei neuen Daten: Nur eine Stelle ändern
   - Variablen: `RAW_DATA_FILE`, `CLEAN_DATA_FILE`, `WORKSPACE_FILE`

5. **Dokumentation verbessert**
   - README mit Projektstruktur und Verwendung
   - Umfassende Inline-Dokumentation in `11_normalization_and_tables.R`

6. **⭐ NEU: Automatisches Analyse-Logging**
   - Alle Konsolenausgaben werden in Log-Datei gespeichert
   - Speicherort: `output/analysis_log_YYYYMMDD_HHMMSS.txt`
   - Enthält vollständige Dokumentation aller Analyseschritte
   - Gleichzeitige Ausgabe an Konsole und Datei (split = TRUE)

7. **⭐ NEU: Automatische Datenqualitätsfilterung**
   - Konsistente Ausreisser werden automatisch entfernt (≥2 Methoden)
   - Dokumentation problematischer Items mit niedriger Varianz
   - Transparente Berichterstattung über alle Filterungsschritte
   - Finale Stichprobengröße klar dokumentiert

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

## Analysepipeline

| Schritt | Skript | Zweck | Output |
|---------|--------|-------|--------|
| 0 | `00_clean_data.R` | Daten bereinigen | `data/data.csv` |
| 1 | `01_setup_and_scales.R` | Skalen + Qualitätsfilterung | `data/01_scales.RData` |
| 2-4 | `02-04_*.R` | Deskriptiv, Reliabilität, Validität | Plots 01-19 |
| 5-8 | `05-08_*.R` | Subgruppenanalysen | Plots 20-39, CSV |
| 9-10 | `09-10_*.R` | Itemauswahl, Vergleiche | CSV-Reports |
| 11 | `11_normalization_and_tables.R` | Normierung | CSV-Normtabellen |
| 12 | `12_final_scale_metrics.R` | Finale Metriken | CSV-Reports |
| - | `run_all.R` (automatisch) | Alle Schritte | `output/analysis_log_*.txt` |

## Normtabellen verwenden

Die Normtabellen liegen als CSV-Dateien vor:

```r
# In R öffnen
norm <- read.csv("output/normtabellen/normtabelle_stresssymptome.csv", 
                 comment.char = "#")

# In Excel öffnen (Doppelklick oder Import)
```

### Struktur der Normtabellen

```
# Titel,Stresssymptome (Kurzskala),
# Untertitel,Gemeinsame Norm für gesamte Stichprobe,
# N,200,
# Mittelwert,2.45,
# SD,0.82,
# Min,1.0,
# Max,5.0,
,
Rohwert,Z_Wert,T_Wert
1.2,-1.52,35
1.3,-1.40,36
...
```

- **Zeilen 1-7**: Metadaten (beginnen mit #)
- **Zeile 8**: Leer
- **Zeile 9+**: Spaltenüberschriften und Normwerte

### Normwerte nachschlagen

1. Rohwert berechnen (z.B. Mittelwert der 5 Items)
2. Passende Tabelle wählen:
   - Stressbelastung → nach Alter (jung/mittel/alt)
   - Coping Aktiv → nach Geschlecht
   - Andere → gemeinsame Norm
3. Rohwert in Tabelle suchen
4. Z-Wert und T-Wert ablesen

**Beispiel:**
- Stresssymptome Rohwert = 3.2
- Tabelle: `normtabelle_stresssymptome.csv`
- Ergebnis: Z = +0.91, T = 59
- Interpretation: Überdurchschnittlich (knapp 1 SD über Mittelwert)

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
       plots = "plots",
       tables = "output/normtabellen"
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

## Datenqualität und Filterung

### Automatische Qualitätsprüfungen (Schritt 1)

Das Skript `01_setup_and_scales.R` führt umfassende Qualitätsprüfungen durch:

1. **Varianzanalyse**
   - Prüft alle Items auf ausreichende Streuung
   - Identifiziert Items mit SD < 0.5, Range < 3, oder Decken-/Bodeneffekten
   - Dokumentiert problematische Items (werden NICHT automatisch entfernt)

2. **Ausreisser-Detektion (3 Methoden)**
   - Z-Score-Methode: |z| > 3.29
   - IQR-Methode: Werte außerhalb Q1-1.5×IQR bis Q3+1.5×IQR
   - Mahalanobis-Distanz: Multivariate Ausreisser
   
3. **Automatische Filterung**
   - ✅ **Entfernt**: Konsistente Ausreisser (≥2 Methoden stimmen überein)
   - 📝 **Dokumentiert**: Items mit Varianzproblemen (für Itemauswahl in Schritt 9)
   - 📊 **Berichtet**: Alle Filterungsschritte im Analysis-Log

### Wo finde ich die Ergebnisse?

**Im Analysis-Log** (`output/analysis_log_*.txt`):
- Sektion "VARIANZANALYSE DER ITEMS": Detaillierte Item-Statistiken
- Sektion "AUSREISSER-ANALYSE": 3 Detektionsmethoden mit Ergebnissen
- Sektion "DATENFILTERUNG": Zusammenfassung der entfernten Fälle

**Finale Stichprobengröße**: Nach allen Filtern dokumentiert

## FAQ

**Q: Wie aktualisiere ich die Daten?**  
A: Neue CSV-Datei in `data/` legen, Pfad in `run_all.R` anpassen, `source("run_all.R")` ausführen.

**Q: Wie füge ich eine neue Analyse hinzu?**  
A: Neues Skript in `src/`, load("data/01_scales.RData") am Anfang, in `run_all.R` einbinden.

**Q: Warum CSV statt PNG für Normtabellen?**  
A: CSV-Dateien können direkt in Excel, Word-Tabellen oder andere Tools importiert werden. Einfacher für Test-Manuals.

**Q: Kann ich einzelne Schritte überspringen?**  
A: Ja, aber beachten Sie Abhängigkeiten. Alle Schritte 2-12 benötigen Schritt 1 (01_scales.RData).

**Q: Wie installiere ich fehlende Pakete?**  
A: `renv::restore()` installiert alle in renv.lock definierten Pakete.

**Q: Wo finde ich das vollständige Analysis-Log?**  
A: Nach jedem `run_all.R` Durchlauf in `output/analysis_log_YYYYMMDD_HHMMSS.txt`

**Q: Werden Ausreisser automatisch entfernt?**  
A: Ja, aber nur konsistente Ausreisser die von ≥2 unabhängigen Methoden identifiziert wurden. Dies wird transparent dokumentiert.

**Q: Was passiert mit Items mit niedriger Varianz?**  
A: Sie werden dokumentiert, aber NICHT automatisch entfernt. Die Itemauswahl für Kurzskalen erfolgt in Schritt 9 basierend auf psychometrischen Kriterien.

## Dokumentation & Literatur

- **Testtheorie**: Lienert & Raatz (1998) - Testaufbau und Testanalyse
- **Effektgrößen**: Cohen (1988) - Statistical Power Analysis
- **Normierung**: Lenhard & Lenhard (2014) - Berechnung der Normwerte

## Kontakt & Support

Bei Fragen zum Code oder den Analysen:
- Überprüfen Sie die Inline-Kommentare in den Skripten
- Konsultieren Sie die Output-CSV-Dateien
- Lesen Sie `src/11_normalization_and_tables.R` für Details zur Normierung

## Lizenz

Akademisches Projekt - Diagnostisches Praktikum 2025
