#!/usr/bin/env Rscript
# ==============================================================================
# MASTER SCRIPT: VOLLSTÄNDIGE STRESSANALYSE
# ==============================================================================
#
# Dieses Skript führt alle Analyseschritte in der richtigen Reihenfolge aus.
# Alle R-Skripte befinden sich im src/ Verzeichnis.
#
# PIPELINE:
# 00. Datenbereinigung (rohe CSV → bereinigte CSV)
# 01. Setup und Skalenkonstruktion (Laden + Skalen berechnen)
# 02. Deskriptive Plots
# 03. Reliabilitätsanalysen
# 04. Hauptvaliditätsanalysen
# 05. Subgruppenanalysen: Stressbelastung
# 06. Subgruppenanalysen: Stresssymptome
# 07. Subgruppenanalysen: Coping-Skalen
# 08. Subgruppen-Plots erstellen
# 09. Statistische Begründung der Itemauswahl
# 10. Finale Vergleichsanalysen der Kurzskalen
# 11. Normierungsanalyse & Normtabellen (zusammengeführt)
# 12. Finale Skalenmetriken für Publikation
#
# ==============================================================================

# ==============================================================================
# KONFIGURATION
# ==============================================================================

# Warnungen und Meldungen unterdrücken (nur kritische Fehler anzeigen)
options(warn = -1)

# ggplot2 Meldungen global unterdrücken
options(ggplot2.continuous.colour = "viridis")
options(ggplot2.continuous.fill = "viridis")

# Paket-Lade-Meldungen unterdrücken
suppressPackageStartupMessages({
  library(methods)
})

# Meldungen von ggplot2::geom_smooth() unterdrücken
suppressMessages({
  NULL # Platzhalter - Messages werden global unterdrückt
})

# Pfad zum Datenverzeichnis (zentrale Konfiguration)
# Diese Variablen werden an alle Skripte weitergegeben
DATA_DIR <- "data"
RAW_DATA_FILE <- file.path(DATA_DIR, "data_stressskala_2025-12-18_10-13.csv")
CLEAN_DATA_FILE <- file.path(DATA_DIR, "data.csv")
WORKSPACE_FILE <- file.path(DATA_DIR, "workspace.RData")
PLOTS_DIR <- "manual/plots"

# Output-Verzeichnis erstellen falls nicht vorhanden
dir.create("manual/output", showWarnings = FALSE)
dir.create("manual/plots", showWarnings = FALSE)

# Zeitstempel für Log
start_time <- Sys.time()
timestamp <- format(start_time, "%Y%m%d_%H%M%S")

# Log-Datei konfigurieren
log_file <- file.path("manual/output", paste0("analysis_log_", timestamp, ".txt"))

# Output an Konsole UND Log-Datei umleiten
sink(log_file, split = TRUE)

cat("\n")
cat("================================================================================\n")
cat("STRESSANALYSE - VOLLSTÄNDIGER ANALYSEDURCHLAUF\n")
cat("================================================================================\n")
cat("\nStart:", format(start_time, "%Y-%m-%d %H:%M:%S"), "\n")
cat("Log-Datei:", log_file, "\n\n")

cat("KONFIGURATION:\n")
cat(sprintf("  Rohdaten:         %s\n", RAW_DATA_FILE))
cat(sprintf("  Bereinigte Daten: %s\n", CLEAN_DATA_FILE))
cat(sprintf("  Workspace:        %s\n", WORKSPACE_FILE))
cat(sprintf("  Log-Datei:        %s\n\n", log_file))

# ==============================================================================
# SCHRITT 0: DATENBEREINIGUNG
# ==============================================================================

cat("--------------------------------------------------------------------------------\n")
cat("SCHRITT 0: Datenbereinigung\n")
cat("--------------------------------------------------------------------------------\n\n")

suppressMessages(source("src/00_clean_data.R"))

cat("\n✓ Schritt 0 abgeschlossen\n")
cat(sprintf("  → Bereinigte Daten: %s\n\n", CLEAN_DATA_FILE))

# ==============================================================================
# SCHRITT 1: SETUP UND SKALENKONSTRUKTION
# ==============================================================================

cat("--------------------------------------------------------------------------------\n")
cat("SCHRITT 1: Setup und Skalenkonstruktion\n")
cat("--------------------------------------------------------------------------------\n\n")

cat("Lade bereinigte Daten und konstruiere Skalen...\n")
suppressMessages(source("src/01_setup_and_scales.R"))

cat("\n✓ Schritt 1 abgeschlossen\n")
cat(sprintf("  → Workspace: %s\n", WORKSPACE_FILE))
cat("  → Alle nachfolgenden Skripte nutzen diesen Workspace\n\n")

# ==============================================================================
# SCHRITT 2: DESKRIPTIVE PLOTS
# ==============================================================================

cat("--------------------------------------------------------------------------------\n")
cat("SCHRITT 2: Deskriptive Plots\n")
cat("--------------------------------------------------------------------------------\n\n")

suppressMessages(source("src/02_descriptive_plots.R"))

cat("\n✓ Schritt 2 abgeschlossen (Plots 01-04: Deskriptive Statistiken)\n\n")

# ==============================================================================
# SCHRITT 3: RELIABILITÄTSANALYSEN
# ==============================================================================

cat("--------------------------------------------------------------------------------\n")
cat("SCHRITT 3: Reliabilitätsanalysen\n")
cat("--------------------------------------------------------------------------------\n\n")

suppressMessages(source("src/03_reliability.R"))

cat("\n✓ Schritt 3 abgeschlossen (Plots 05-12: Reliabilitätsanalysen)\n\n")

# ==============================================================================
# SCHRITT 4: HAUPTVALIDITÄTSANALYSEN
# ==============================================================================

cat("--------------------------------------------------------------------------------\n")
cat("SCHRITT 4: Hauptvaliditätsanalysen\n")
cat("--------------------------------------------------------------------------------\n\n")

suppressMessages(source("src/04_validity_main.R"))

cat("\n✓ Schritt 4 abgeschlossen (Plots 13-19: Validitätsanalysen)\n\n")

# ==============================================================================
# SCHRITT 5: SUBGRUPPENANALYSEN - STRESSBELASTUNG
# ==============================================================================

cat("--------------------------------------------------------------------------------\n")
cat("SCHRITT 5: Subgruppenanalysen - Stressbelastung\n")
cat("--------------------------------------------------------------------------------\n\n")

suppressMessages(source("src/05_validity_subgroups_stress.R"))

cat("\n✓ Schritt 5 abgeschlossen\n\n")

# ==============================================================================
# SCHRITT 6: SUBGRUPPENANALYSEN - STRESSSYMPTOME
# ==============================================================================

cat("--------------------------------------------------------------------------------\n")
cat("SCHRITT 6: Subgruppenanalysen - Stresssymptome\n")
cat("--------------------------------------------------------------------------------\n\n")

suppressMessages(source("src/06_validity_subgroups_symptoms.R"))

cat("\n✓ Schritt 6 abgeschlossen\n\n")

# ==============================================================================
# SCHRITT 7: SUBGRUPPENANALYSEN - COPING
# ==============================================================================

cat("--------------------------------------------------------------------------------\n")
cat("SCHRITT 7: Subgruppenanalysen - Coping-Skalen\n")
cat("--------------------------------------------------------------------------------\n\n")

suppressMessages(source("src/07_validity_subgroups_coping.R"))

cat("\n✓ Schritt 7 abgeschlossen\n\n")

# ==============================================================================
# SCHRITT 8: SUBGRUPPEN-PLOTS ERSTELLEN
# ==============================================================================

cat("--------------------------------------------------------------------------------\n")
cat("SCHRITT 8: Subgruppen-Plots erstellen\n")
cat("--------------------------------------------------------------------------------\n\n")

suppressMessages(source("src/08_create_subgroup_plots.R"))

cat("\n✓ Schritt 8 abgeschlossen (Plots 20-39: Subgruppen-Visualisierungen)\n\n")

# ==============================================================================
# SCHRITT 9: STATISTISCHE BEGRÜNDUNG DER ITEMAUSWAHL
# ==============================================================================

cat("--------------------------------------------------------------------------------\n")
cat("SCHRITT 9: Statistische Begründung der Itemauswahl\n")
cat("--------------------------------------------------------------------------------\n\n")

suppressMessages(source("src/09_justification.R"))

cat("\n✓ Schritt 9 abgeschlossen (Itemauswahl-Justifikation)\n\n")

# ==============================================================================
# SCHRITT 10: FINALE VERGLEICHSANALYSEN
# ==============================================================================

cat("--------------------------------------------------------------------------------\n")
cat("SCHRITT 10: Finale Vergleichsanalysen der Kurzskalen\n")
cat("--------------------------------------------------------------------------------\n\n")

suppressMessages(source("src/10_final_comparison.R"))

cat("\n✓ Schritt 10 abgeschlossen (Finale Kurzskalen-Bewertung)\n\n")

# ==============================================================================
# SCHRITT 11: NORMIERUNGSANALYSE & NORMTABELLEN
# ==============================================================================

cat("--------------------------------------------------------------------------------\n")
cat("SCHRITT 11: Normierungsanalyse & Normtabellen\n")
cat("--------------------------------------------------------------------------------\n\n")

cat("Hinweis: Skripte 11 und 12 wurden zusammengeführt für bessere Übersicht.\n")
cat("Ausgabe: CSV-Dateien statt PNG-Bilder für einfachere Weiterverarbeitung.\n\n")

suppressMessages(source("src/11_normalization_and_tables.R"))

cat("\n✓ Schritt 11 abgeschlossen\n")
cat("  → Normtabellen: output/normtabellen/*.csv\n\n")

# ==============================================================================
# SCHRITT 12: FINALE SKALENMETRIKEN
# ==============================================================================

cat("--------------------------------------------------------------------------------\n")
cat("SCHRITT 12: Finale Skalenmetriken für Publikation\n")
cat("--------------------------------------------------------------------------------\n\n")

suppressMessages(source("src/12_final_scale_metrics.R"))

cat("\n✓ Schritt 12 abgeschlossen (Finale Metriken berechnet)\n\n")

# ==============================================================================
# AUFRÄUMEN
# ==============================================================================

cat("--------------------------------------------------------------------------------\n")
cat("Workspace bereinigen...\n")
cat("--------------------------------------------------------------------------------\n\n")

# Liste temporärer Workspaces die aufgeräumt werden können
temp_workspaces <- c(
  "data/subgroups_stress.RData",
  "data/subgroups_symptoms.RData",
  "data/subgroups_coping.RData"
)

# Entferne temporäre Workspaces falls vorhanden
for (ws in temp_workspaces) {
  if (file.exists(ws)) {
    file.remove(ws)
    cat(sprintf("  ✓ Entfernt: %s\n", ws))
  }
}

# Behalte wichtige Workspaces
cat("\nBehalten:\n")
cat(sprintf("  ✓ %s (Hauptdaten mit allen Skalen)\n", WORKSPACE_FILE))

# ==============================================================================
# ABSCHLUSS
# ==============================================================================

end_time <- Sys.time()
duration <- difftime(end_time, start_time, units = "mins")

cat("================================================================================\n")
cat("ANALYSE ABGESCHLOSSEN\n")
cat("================================================================================\n\n")
cat("Ende:", format(end_time, "%Y-%m-%d %H:%M:%S"), "\n")
cat("Dauer:", round(as.numeric(duration), 2), "Minuten\n\n")

cat("ZUSAMMENFASSUNG:\n")
cat("  ✓ Datenbereinigung durchgeführt\n")
cat("  ✓ Alle Skalen konstruiert\n")
cat("  ✓ Deskriptive Statistiken erstellt (Plots 01-04)\n")
cat("  ✓ Reliabilitätsanalysen abgeschlossen (Plots 05-12)\n")
cat("  ✓ Hauptvaliditätsanalysen abgeschlossen (Plots 13-19)\n")
cat("  ✓ Subgruppenanalysen abgeschlossen\n")
cat("  ✓ Subgruppen-Visualisierungen erstellt (Plots 20-39)\n")
cat("  ✓ Statistische Itemauswahl-Begründung\n")
cat("  ✓ Finale Kurzskalen-Vergleichsanalysen\n")
cat("  ✓ Normierungsanalyse & Normtabellen (CSV-Format)\n")
cat("  ✓ Finale Skalenmetriken\n")
cat("  ✓ Temporäre Dateien bereinigt\n\n")

cat("DATEIEN & VERZEICHNISSE:\n")
cat("  Skripte:      src/*.R\n")
cat("  Daten:        data/\n")
cat("  Plots:        plots/\n")
cat("  Analysen:     output/\n")
cat("  Normtabellen: output/normtabellen/*.csv\n\n")

cat("WICHTIGE ÄNDERUNGEN:\n")
cat("  • Alle R-Skripte in src/ Verzeichnis verschoben\n")
cat("  • Skripte 11 & 12 zu einem zusammengeführt\n")
cat("  • Normtabellen als CSV statt PNG (einfacher zu verwenden)\n")
cat("  • Zentrale Datenpfad-Konfiguration in run_all.R\n")
cat("  • Warnungen unterdrückt für saubereren Output\n\n")

cat("NÄCHSTE SCHRITTE:\n")
cat("  1. Überprüfen Sie alle Plots im Ordner plots/\n")
cat("  2. Normtabellen für Ihr Manual: output/normtabellen/*.csv\n")
cat("  3. Öffnen Sie CSV-Dateien in Excel/R für Verwendung im Manual\n")
cat("  4. Dokumentieren Sie die Normierungsstrategie in Ihrer Arbeit\n\n")

cat("================================================================================\n\n")

# Log-Umleitung beenden
sink()

# Warnungen wieder aktivieren
options(warn = 0)

# Abschlussmeldung an Konsole
cat(sprintf("\n✓ Vollständiges Analyse-Log gespeichert: %s\n\n", log_file))
