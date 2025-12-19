#!/usr/bin/env Rscript
# ==============================================================================
# VALIDITÄTSANALYSEN (SUBGRUPPENANALYSEN)
# ==============================================================================
#
# Dieses Skript führt demographische Subgruppenanalysen durch:
#
# FÜR STRESS & SYMPTOME:
# - Nach Geschlecht (Plot 17)
# - Nach Bildung (Plot 18)
# - Nach Alter (Plot 19)
# - Nach Beschäftigung (Plot 20)
#
# FÜR COPING-SKALEN (NEU):
# - Nach Geschlecht (Plot 21)
# - Nach Bildung (Plot 22)
# - Nach Alter (Plot 23)
# - Nach Beschäftigung (Plot 24)
#
# Verwendet Fisher's Z-Tests für Gruppenvergleiche
#
# Voraussetzung: 01_setup_and_scales.R wurde ausgeführt
#
# ==============================================================================

# ==============================================================================
# KONFIGURATION - FILEPATHS VON run_all.R
# ==============================================================================

# Diese Variablen sollten von run_all.R gesetzt sein
if (!exists("WORKSPACE_FILE")) {
  WORKSPACE_FILE <- "data/workspace.RData"
}

# ==============================================================================
# WORKSPACE LADEN
# ==============================================================================

cat("Lade Workspace von 01_setup_and_scales.R...\n")
load(WORKSPACE_FILE)
cat("✓ Workspace geladen:", WORKSPACE_FILE, "\n\n")

# ==============================================================================
# HILFSFUNKTION: FISHER'S Z-TEST
# ==============================================================================

print_section("SUBGRUPPENANALYSEN VORBEREITUNG")

# Hilfsfunktion für Fisher's Z-Test
fisher_z_test <- function(r1, n1, r2, n2) {
  z <- (atanh(r1) - atanh(r2)) / sqrt(1 / (n1 - 3) + 1 / (n2 - 3))
  p <- 2 * (1 - pnorm(abs(z)))
  list(z = z, p = p)
}

cat("✓ Fisher's Z-Test Funktion geladen\n\n")
