#!/usr/bin/env Rscript
# ==============================================================================
# MASTER SCRIPT: VOLLSTÄNDIGE STRESSANALYSE
# ==============================================================================
#
# Dieses Skript führt alle Analyseschritte in der richtigen Reihenfolge aus:
#
# 00. Datenbereinigung
# 01. Setup und Skalenkonstruktion
# 02. Deskriptive Plots
# 03. Reliabilitätsanalysen
# 04. Hauptvaliditätsanalysen
# 05. Subgruppenanalysen: Stressbelastung
# 06. Subgruppenanalysen: Stresssymptome
# 07. Subgruppenanalysen: Coping-Skalen (NEU!)
# 08. Subgruppen-Plots erstellen
#
# ==============================================================================

# ==============================================================================
# KONFIGURATION
# ==============================================================================

# Arbeitsverzeichnis setzen (falls nötig)
# Optional: setwd() to set working directory if needed

# Zeitstempel für Log
start_time <- Sys.time()

cat("\n")
cat("================================================================================\n")
cat("STRESSANALYSE - VOLLSTÄNDIGER ANALYSEDURCHLAUF\n")
cat("================================================================================\n")
cat("\nStart:", format(start_time, "%Y-%m-%d %H:%M:%S"), "\n\n")

# ==============================================================================
# SCHRITT 0: DATENBEREINIGUNG
# ==============================================================================

cat("--------------------------------------------------------------------------------\n")
cat("SCHRITT 0: Datenbereinigung\n")
cat("--------------------------------------------------------------------------------\n\n")

source("00_clean_data.R")

cat("\n✓ Schritt 0 abgeschlossen\n\n")

# ==============================================================================
# SCHRITT 1: SETUP UND SKALENKONSTRUKTION
# ==============================================================================

cat("--------------------------------------------------------------------------------\n")
cat("SCHRITT 1: Setup und Skalenkonstruktion\n")
cat("--------------------------------------------------------------------------------\n\n")

source("01_setup_and_scales.R")

cat("\n✓ Schritt 1 abgeschlossen\n\n")

# ==============================================================================
# SCHRITT 2: DESKRIPTIVE PLOTS
# ==============================================================================

cat("--------------------------------------------------------------------------------\n")
cat("SCHRITT 2: Deskriptive Plots\n")
cat("--------------------------------------------------------------------------------\n\n")

source("02_descriptive_plots.R")

cat("\n✓ Schritt 2 abgeschlossen (Plots 01-04)\n\n")

# ==============================================================================
# SCHRITT 3: RELIABILITÄTSANALYSEN
# ==============================================================================

cat("--------------------------------------------------------------------------------\n")
cat("SCHRITT 3: Reliabilitätsanalysen\n")
cat("--------------------------------------------------------------------------------\n\n")

source("03_reliability.R")

cat("\n✓ Schritt 3 abgeschlossen (Plots 06-12)\n\n")

# ==============================================================================
# SCHRITT 4: HAUPTVALIDITÄTSANALYSEN
# ==============================================================================

cat("--------------------------------------------------------------------------------\n")
cat("SCHRITT 4: Hauptvaliditätsanalysen\n")
cat("--------------------------------------------------------------------------------\n\n")

source("04_validity_main.R")

cat("\n✓ Schritt 4 abgeschlossen (Plots 13-16)\n\n")

# ==============================================================================
# SCHRITT 5: SUBGRUPPENANALYSEN - STRESSBELASTUNG
# ==============================================================================

cat("--------------------------------------------------------------------------------\n")
cat("SCHRITT 5: Subgruppenanalysen - Stressbelastung\n")
cat("--------------------------------------------------------------------------------\n\n")

source("05_validity_subgroups_stress.R")

cat("\n✓ Schritt 5 abgeschlossen\n\n")

# ==============================================================================
# SCHRITT 6: SUBGRUPPENANALYSEN - STRESSSYMPTOME
# ==============================================================================

cat("--------------------------------------------------------------------------------\n")
cat("SCHRITT 6: Subgruppenanalysen - Stresssymptome\n")
cat("--------------------------------------------------------------------------------\n\n")

source("06_validity_subgroups_symptoms.R")

cat("\n✓ Schritt 6 abgeschlossen\n\n")

# ==============================================================================
# SCHRITT 7: SUBGRUPPENANALYSEN - COPING (NEU!)
# ==============================================================================

cat("--------------------------------------------------------------------------------\n")
cat("SCHRITT 7: Subgruppenanalysen - Coping-Skalen (NEU!)\n")
cat("--------------------------------------------------------------------------------\n\n")

source("07_validity_subgroups_coping.R")

cat("\n✓ Schritt 7 abgeschlossen\n\n")

# ==============================================================================
# SCHRITT 8: SUBGRUPPEN-PLOTS ERSTELLEN
# ==============================================================================

cat("--------------------------------------------------------------------------------\n")
cat("SCHRITT 8: Subgruppen-Plots erstellen\n")
cat("--------------------------------------------------------------------------------\n\n")

source("08_create_subgroup_plots.R")

cat("\n✓ Schritt 8 abgeschlossen (Plots 17-20)\n\n")

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
cat("  ✓ Reliabilitätsanalysen abgeschlossen (Plots 06-12)\n")
cat("  ✓ Hauptvaliditätsanalysen abgeschlossen (Plots 13-16)\n")
cat("  ✓ Subgruppenanalysen abgeschlossen:\n")
cat("    - Stressbelastung\n")
cat("    - Stresssymptome\n")
cat("    - Coping-Skalen (NEU - 5 Skalen × 4 Subgruppen)\n")
cat("  ✓ Subgruppen-Visualisierungen erstellt (Plots 17-20)\n\n")

cat("ERGEBNIS:\n")
cat("  - Insgesamt 20 Plots erstellt\n")
cat("  - Alle Analysen dokumentiert\n")
cat("  - Workspace verfügbar: data/01_scales.RData\n\n")

cat("NÄCHSTE SCHRITTE:\n")
cat("  1. Überprüfen Sie alle Plots im Ordner plots/\n")
cat("  2. Interpretieren Sie die Subgruppenunterschiede\n")
cat("  3. Nutzen Sie den Workspace für weitere Analysen\n\n")

cat("================================================================================\n\n")
