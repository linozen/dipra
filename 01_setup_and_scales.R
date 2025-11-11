#!/usr/bin/env Rscript
# ==============================================================================
# SETUP, STICHPROBENBESCHREIBUNG UND SKALENKONSTRUKTION
# ==============================================================================
#
# Dieses Skript:
# 1. Lädt erforderliche Pakete (tidyverse, lavaan, psych)
# 2. Definiert Hilfsfunktionen
# 3. Lädt bereinigte Daten aus data/data.csv
# 4. Führt Datenbereinigung durch (Faktoren, Alter, Aufmerksamkeitstest)
# 5. Erstellt Stichprobenbeschreibung
# 6. Konstruiert alle psychometrischen Skalen
# 7. Speichert Workspace für nachfolgende Skripte
#
# ==============================================================================

# ==============================================================================
# PAKETE LADEN
# ==============================================================================

cat("Lade Pakete...\n")
suppressPackageStartupMessages({
  library(tidyverse)
  library(lavaan)
  library(psych)
})

# ==============================================================================
# HILFSFUNKTIONEN
# ==============================================================================

# Hilfsfunktion für übersichtliche Ausgabe
print_section <- function(title, level = 1) {
  if (level == 1) {
    cat("\n")
    cat(paste(rep("=", 80), collapse = ""), "\n")
    cat(title, "\n")
    cat(paste(rep("=", 80), collapse = ""), "\n\n")
  } else if (level == 2) {
    cat("\n")
    cat(paste(rep("-", 80), collapse = ""), "\n")
    cat(title, "\n")
    cat(paste(rep("-", 80), collapse = ""), "\n\n")
  } else {
    cat("\n### ", title, "\n\n")
  }
}

# ==============================================================================
# DATEN EINLESEN
# ==============================================================================

print_section("DATEN EINLESEN")

# Daten einlesen
data <- read.csv("data/data.csv", header = TRUE, sep = ";", dec = ",")
cat("✓ Daten geladen:", nrow(data), "Zeilen\n")

# ==============================================================================
# DATENBEREINIGUNG
# ==============================================================================

print_section("DATENBEREINIGUNG", 2)

# Faktoren definieren
data$DE07_01 <- as.factor(data$DE07_01)
data$DE05 <- as.factor(data$DE05)
data$DE04 <- as.factor(data$DE04)

# Variablen umbenennen
data <- data %>%
  rename(
    Geschlecht = DE04,
    Bildung = DE05,
    Beschäftigung = DE07_01,
    Alter = DE08_01,
    VPN_Code = DE12_01,
    Zufriedenheit = L101_01
  )

# Alter bereinigen
data$Alter <- suppressWarnings(as.numeric(data$Alter))
data <- subset(data, Alter >= 18)

# Aufmerksamkeitstest: SO02_14 muss 4 sein
n_vor_ausschluss <- nrow(data)
data <- subset(data, SO02_14 == 4)
n_nach_ausschluss <- nrow(data)
n_ausgeschlossen <- n_vor_ausschluss - n_nach_ausschluss

cat("✓ Datenbereinigung abgeschlossen\n")
cat("  - Alter ≥18 Jahre\n")
cat("  - Aufmerksamkeitstest bestanden (SO02_14 == 4)\n\n")

# ==============================================================================
# STICHPROBENBESCHREIBUNG
# ==============================================================================

print_section("STICHPROBENBESCHREIBUNG")

cat("Anzahl Teilnehmer (≥18 Jahre, vor Aufmerksamkeitstest):", n_vor_ausschluss, "\n")
cat("Ausgeschlossen (Aufmerksamkeitstest nicht bestanden):", n_ausgeschlossen, "\n")
cat("Finale Stichprobe:", n_nach_ausschluss, "\n\n")
cat("Durchschnittsalter:", round(mean(data$Alter, na.rm = TRUE), 2), "Jahre\n")
cat("Standardabweichung Alter:", round(sd(data$Alter, na.rm = TRUE), 2), "Jahre\n\n")

cat("Geschlechterverteilung:\n")
print(table(data$Geschlecht))
cat("\nBeschäftigungsverteilung:\n")
print(table(data$Beschäftigung))

# ==============================================================================
# SKALENKONSTRUKTION
# ==============================================================================

print_section("SKALENKONSTRUKTION")

# ------------------------------------------------------------------------------
# Neurotizismus
# ------------------------------------------------------------------------------
data$Neurotizismus <- (data$BF01_02 + 6 - data$BF01_01) / 2
cat("✓ Neurotizismus konstruiert\n")

# ------------------------------------------------------------------------------
# Resilienz (mit Reverse Coding)
# ------------------------------------------------------------------------------
data$RE01_02 <- 7 - data$RE01_02
data$RE01_04 <- 7 - data$RE01_04
data$RE01_06 <- 7 - data$RE01_06
data$Resilienz <- rowMeans(
  data[, c("RE01_01", "RE01_02", "RE01_03", "RE01_04", "RE01_05", "RE01_06")],
  na.rm = TRUE
)
cat("✓ Resilienz konstruiert\n")

# ------------------------------------------------------------------------------
# Stressbelastung
# ------------------------------------------------------------------------------
data$Stressbelastung_gesamt <- rowMeans(
  data[, c(
    "NI06_01", "NI06_02", "NI06_03", "NI06_04", "NI06_05",
    "SO01_01", "SO01_02", "SO01_03", "SO01_04", "SO01_05",
    "SO01_06", "SO01_07", "SO01_08", "SO01_09", "SO01_10", "SO01_11"
  )]
)
data$Stressbelastung_kurz <- rowMeans(
  data[, c("NI06_01", "NI06_02", "NI06_03", "NI06_04", "NI06_05")]
)
data$Stressbelastung_lang <- rowMeans(
  data[, c(
    "SO01_01", "SO01_02", "SO01_03", "SO01_04", "SO01_05",
    "SO01_06", "SO01_07", "SO01_09", "SO01_10", "SO01_11"
  )]
)
cat("✓ Stressbelastung (kurz, lang, gesamt) konstruiert\n")

# ------------------------------------------------------------------------------
# Stresssymptome
# ------------------------------------------------------------------------------
data$Stresssymptome_gesamt <- rowMeans(
  data[, c(
    "NI13_01", "NI13_02", "NI13_03", "NI13_04", "NI13_05",
    "SO02_01", "SO02_02", "SO02_03", "SO02_04", "SO02_05",
    "SO02_06", "SO02_07", "SO02_08", "SO02_09", "SO02_10",
    "SO02_11", "SO02_12", "SO02_13", "SO02_14"
  )]
)
data$Stresssymptome_lang <- rowMeans(
  data[, c(
    "SO02_01", "SO02_02", "SO02_03", "SO02_04", "SO02_05",
    "SO02_06", "SO02_07", "SO02_08", "SO02_09", "SO02_10",
    "SO02_11", "SO02_12", "SO02_13", "SO02_14"
  )]
)
data$Stresssymptome_kurz <- rowMeans(
  data[, c("NI13_01", "NI13_02", "NI13_03", "NI13_04", "NI13_05")]
)
cat("✓ Stresssymptome (kurz, lang, gesamt) konstruiert\n")

# ------------------------------------------------------------------------------
# Coping-Skalen (mit Reverse Coding für SO23_13)
# ------------------------------------------------------------------------------
data$SO23_13 <- 7 - data$SO23_13

data$Coping_aktiv <- rowMeans(
  data[, c("SO23_01", "SO23_20", "SO23_14", "NI07_05")]
)
data$Coping_Drogen <- rowMeans(
  data[, c("NI07_01", "SO23_02", "SO23_07", "SO23_13", "SO23_17")]
)
data$Coping_positiv <- rowMeans(
  data[, c("SO23_11", "SO23_10", "SO23_15", "NI07_04")]
)
data$Coping_sozial <- rowMeans(
  data[, c("NI07_03", "SO23_04", "SO23_05", "SO23_09", "SO23_18")]
)
data$Coping_rel <- rowMeans(
  data[, c("NI07_02", "SO23_06", "SO23_12", "SO23_16")]
)
cat("✓ Coping-Skalen (aktiv, Drogen, positiv, sozial, religiös) konstruiert\n")

cat("\n✓ Alle Skalen erfolgreich konstruiert\n")

# ==============================================================================
# WORKSPACE SPEICHERN
# ==============================================================================

print_section("WORKSPACE SPEICHERN")

# Speichere Workspace für nachfolgende Skripte
save(
  data,
  print_section, # Hilfsfunktion wird auch gespeichert
  file = "data/01_scales.RData"
)

cat("✓ Workspace gespeichert als: data/01_scales.RData\n")
cat("\nDieser Workspace wird von allen nachfolgenden Skripten geladen.\n")
cat("Führen Sie als nächstes aus:\n")
cat("  - 02_descriptive_plots.R\n")
cat("  - 03_reliability.R\n")
cat("  - 04_validity_main.R\n")
cat("  - 05_validity_subgroups.R\n\n")
