#!/usr/bin/env Rscript
# ==============================================================================
# RELIABILITÄTSANALYSEN
# ==============================================================================
#
# Dieses Skript führt alle Reliabilitätsanalysen durch:
# - Cronbachs Alpha (interne Konsistenz)
# - Konfirmatorische Faktorenanalyse (CFA, Faktorstruktur)
#
# Für folgende Skalen:
# 1. Stressbelastung (kurz, gesamt)
# 2. Stresssymptome (kurz, gesamt)
# 3. Coping-Skalen (5 Skalen)
#
# Plots: 05-12
#
# Voraussetzung: 01_setup_and_scales.R wurde ausgeführt
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
cat("✓ Pakete geladen\n\n")

# ==============================================================================
# WORKSPACE LADEN
# ==============================================================================

cat("Lade Workspace von 01_setup_and_scales.R...\n")
load("data/01_scales.RData")
cat("✓ Workspace geladen\n\n")

# ##############################################################################
# TEIL I: RELIABILITÄT
# ##############################################################################

print_section("TEIL I: RELIABILITÄTSANALYSEN")

cat("In diesem Abschnitt wird die Reliabilität (Messgenauigkeit) der Skalen geprüft.\n")
cat("Verwendet werden:\n")
cat("  - Cronbachs Alpha (interne Konsistenz)\n")
cat("  - Konfirmatorische Faktorenanalyse (CFA, Faktorstruktur)\n\n")


# ==============================================================================
# 1. RELIABILITÄT: STRESSBELASTUNG
# ==============================================================================

print_section("1. RELIABILITÄT: STRESSBELASTUNG", 2)

cat("### 1.1 Cronbachs Alpha: Stressbelastung Kurzskala (5 Items)\n\n")
alpha_stress_kurz <- psych::alpha(
  data[, c("NI06_01", "NI06_02", "NI06_03", "NI06_04", "NI06_05")]
)
cat("Cronbachs Alpha:", round(alpha_stress_kurz$total$raw_alpha, 3), "\n")
cat(
  "Interpretation:",
  ifelse(alpha_stress_kurz$total$raw_alpha > 0.80, "Gut",
    ifelse(alpha_stress_kurz$total$raw_alpha > 0.70, "Akzeptabel", "Problematisch")
  ), "\n\n"
)

cat("### 1.2 Cronbachs Alpha: Stressbelastung Gesamtskala (16 Items)\n\n")
alpha_stress_gesamt <- psych::alpha(
  data[, c(
    "NI06_01", "NI06_02", "NI06_03", "NI06_04", "NI06_05",
    "SO01_01", "SO01_02", "SO01_03", "SO01_04", "SO01_05",
    "SO01_06", "SO01_07", "SO01_08", "SO01_09", "SO01_10", "SO01_11"
  )]
)
cat("Cronbachs Alpha:", round(alpha_stress_gesamt$total$raw_alpha, 3), "\n")
cat(
  "Interpretation:",
  ifelse(alpha_stress_gesamt$total$raw_alpha > 0.80, "Gut",
    ifelse(alpha_stress_gesamt$total$raw_alpha > 0.70, "Akzeptabel", "Problematisch")
  ), "\n\n"
)

cat("### 1.3 CFA: Stressbelastung Kurzskala\n\n")
model_stress_kurz <- "
  Stressbelastung =~ NI06_01 + NI06_02 + NI06_03 + NI06_04 + NI06_05
"
fit_stress_kurz <- cfa(model_stress_kurz, data = data)
fit_indices <- fitMeasures(fit_stress_kurz, c("chisq", "df", "pvalue", "cfi", "tli", "rmsea", "srmr"))

cat("Fit-Indizes:\n")
cat(
  "  χ² =", round(fit_indices["chisq"], 2), ", df =", fit_indices["df"],
  ", p =", round(fit_indices["pvalue"], 3), "\n"
)
cat(
  "  CFI =", round(fit_indices["cfi"], 3),
  ifelse(fit_indices["cfi"] > 0.95, " (Sehr gut)",
    ifelse(fit_indices["cfi"] > 0.90, " (Akzeptabel)", " (Problematisch)")
  ), "\n"
)
cat(
  "  TLI =", round(fit_indices["tli"], 3),
  ifelse(fit_indices["tli"] > 0.95, " (Sehr gut)",
    ifelse(fit_indices["tli"] > 0.90, " (Akzeptabel)", " (Problematisch)")
  ), "\n"
)
rmsea_val <- fit_indices["rmsea"]
cat("  RMSEA =", round(rmsea_val, 3))
if (rmsea_val < 0.001) {
  cat(" (Exzellent - χ² nicht signifikant)")
} else if (rmsea_val < 0.05) {
  cat(" (Sehr gut)")
} else if (rmsea_val < 0.08) {
  cat(" (Akzeptabel)")
} else {
  cat(" (Problematisch)")
}
cat("\n")
cat(
  "  SRMR =", round(fit_indices["srmr"], 3),
  ifelse(fit_indices["srmr"] < 0.08, " (Gut)", " (Problematisch)"), "\n\n"
)

cat("Fazit Stressbelastung:\n")
cat(
  "  - Kurzskala hat",
  ifelse(alpha_stress_kurz$total$raw_alpha > 0.70, "akzeptable bis gute", "problematische"),
  "interne Konsistenz\n"
)
cat(
  "  - Faktorstruktur ist",
  ifelse(fit_indices["cfi"] > 0.90, "akzeptabel bis gut", "problematisch"), "\n\n"
)

# RELIABILITÄTS-PLOT: Stressbelastung
png("plots/05_reliabilitaet_stress_itemstatistik.png", width = 1600, height = 800, res = 150)
par(mfrow = c(1, 2))

# Item-Total-Korrelationen - Gesamtskala
item_stats_gesamt <- alpha_stress_gesamt$item.stats
item_names <- rownames(item_stats_gesamt)
item_colors <- ifelse(grepl("^NI", item_names), "steelblue4", "steelblue")

barplot(item_stats_gesamt$r.drop,
  main = "Item-Total-Korrelationen\nStressbelastung Gesamtskala",
  ylab = "Korrelation",
  names.arg = item_names,
  col = item_colors,
  las = 2,
  ylim = c(0, 1),
  cex.names = 0.7
)
abline(h = 0.3, col = "red", lty = 2, lwd = 2)
legend("topright", legend = "Mindestkriterium (r = 0.3)", col = "red", lty = 2, lwd = 2, bty = "n")

# Item-Trennschärfe - Gesamtskala
item_colors_coral <- ifelse(grepl("^NI", item_names), "coral4", "coral")
barplot(item_stats_gesamt$raw.r,
  main = "Item-Trennschärfe\nStressbelastung Gesamtskala",
  ylab = "Korrigierte Item-Total-Korrelation",
  names.arg = item_names,
  col = item_colors_coral,
  las = 2,
  ylim = c(0, 1),
  cex.names = 0.7
)
abline(h = 0.3, col = "red", lty = 2, lwd = 2)
legend("topright", legend = "Mindestkriterium (r = 0.3)", col = "red", lty = 2, lwd = 2, bty = "n")

dev.off()

# Verteilungsplot der Stressskalen
png("plots/06_reliabilitaet_stress_verteilung.png", width = 1600, height = 600, res = 150)
par(mfrow = c(1, 3))
hist(data$Stressbelastung_kurz,
  breaks = 20, col = "steelblue",
  main = "Stressbelastung Kurzskala", xlab = "Skalenwert", border = "white"
)
hist(data$Stressbelastung_lang,
  breaks = 20, col = "coral",
  main = "Stressbelastung Langskala", xlab = "Skalenwert", border = "white"
)
hist(data$Stressbelastung_gesamt,
  breaks = 20, col = "lightgreen",
  main = "Stressbelastung Gesamtskala", xlab = "Skalenwert", border = "white"
)
dev.off()

cat("✓ Reliabilitäts-Plots für Stressbelastung gespeichert\n\n")


# ==============================================================================
# 2. RELIABILITÄT: STRESSSYMPTOME
# ==============================================================================

print_section("2. RELIABILITÄT: STRESSSYMPTOME", 2)

cat("### 2.1 Cronbachs Alpha: Stresssymptome Kurzskala (5 Items)\n\n")
alpha_sympt_kurz <- psych::alpha(
  data[, c("NI13_01", "NI13_02", "NI13_03", "NI13_04", "NI13_05")]
)
cat("Cronbachs Alpha:", round(alpha_sympt_kurz$total$raw_alpha, 3), "\n")
cat(
  "Interpretation:",
  ifelse(alpha_sympt_kurz$total$raw_alpha > 0.80, "Gut",
    ifelse(alpha_sympt_kurz$total$raw_alpha > 0.70, "Akzeptabel", "Problematisch")
  ), "\n\n"
)

cat("### 2.2 Cronbachs Alpha: Stresssymptome Gesamtskala (18 Items)\n\n")
alpha_sympt_gesamt <- psych::alpha(
  data[, c(
    "NI13_01", "NI13_02", "NI13_03", "NI13_04", "NI13_05",
    "SO02_01", "SO02_02", "SO02_03", "SO02_04", "SO02_05",
    "SO02_06", "SO02_07", "SO02_08", "SO02_09", "SO02_10",
    "SO02_11", "SO02_12", "SO02_13"
  )]
)
cat("Cronbachs Alpha:", round(alpha_sympt_gesamt$total$raw_alpha, 3), "\n")
cat(
  "Interpretation:",
  ifelse(alpha_sympt_gesamt$total$raw_alpha > 0.80, "Gut",
    ifelse(alpha_sympt_gesamt$total$raw_alpha > 0.70, "Akzeptabel", "Problematisch")
  ), "\n\n"
)

cat("### 2.3 CFA: Stresssymptome Kurzskala\n\n")
model_sympt_kurz <- "
  Stresssymptome =~ NI13_01 + NI13_02 + NI13_03 + NI13_04 + NI13_05
"
fit_sympt_kurz <- cfa(model_sympt_kurz, data = data)
fit_indices <- fitMeasures(fit_sympt_kurz, c("chisq", "df", "pvalue", "cfi", "tli", "rmsea", "srmr"))

cat("Fit-Indizes:\n")
cat(
  "  χ² =", round(fit_indices["chisq"], 2), ", df =", fit_indices["df"],
  ", p =", round(fit_indices["pvalue"], 3), "\n"
)
cat(
  "  CFI =", round(fit_indices["cfi"], 3),
  ifelse(fit_indices["cfi"] > 0.95, " (Sehr gut)",
    ifelse(fit_indices["cfi"] > 0.90, " (Akzeptabel)", " (Problematisch)")
  ), "\n"
)
cat(
  "  TLI =", round(fit_indices["tli"], 3),
  ifelse(fit_indices["tli"] > 0.95, " (Sehr gut)",
    ifelse(fit_indices["tli"] > 0.90, " (Akzeptabel)", " (Problematisch)")
  ), "\n"
)
rmsea_val <- fit_indices["rmsea"]
cat("  RMSEA =", round(rmsea_val, 3))
if (rmsea_val < 0.001) {
  cat(" (Exzellent - χ² nicht signifikant)")
} else if (rmsea_val < 0.05) {
  cat(" (Sehr gut)")
} else if (rmsea_val < 0.08) {
  cat(" (Akzeptabel)")
} else {
  cat(" (Problematisch)")
}
cat("\n")
cat(
  "  SRMR =", round(fit_indices["srmr"], 3),
  ifelse(fit_indices["srmr"] < 0.08, " (Gut)", " (Problematisch)"), "\n\n"
)

cat("Fazit Stresssymptome:\n")
cat(
  "  - Kurzskala hat",
  ifelse(alpha_sympt_kurz$total$raw_alpha > 0.70, "akzeptable bis gute", "problematische"),
  "interne Konsistenz\n"
)
cat(
  "  - Faktorstruktur ist",
  ifelse(fit_indices["cfi"] > 0.90, "akzeptabel bis gut", "problematisch"), "\n\n"
)

# RELIABILITÄTS-PLOT: Stresssymptome
png("plots/07_reliabilitaet_symptome_itemstatistik.png", width = 1600, height = 800, res = 150)
par(mfrow = c(1, 2))

# Item-Total-Korrelationen - Gesamtskala
item_stats_sympt_gesamt <- alpha_sympt_gesamt$item.stats
item_names_sympt <- rownames(item_stats_sympt_gesamt)
item_colors_sympt <- ifelse(grepl("^NI", item_names_sympt), "steelblue4", "steelblue")

barplot(item_stats_sympt_gesamt$r.drop,
  main = "Item-Total-Korrelationen\nStresssymptome Gesamtskala",
  ylab = "Korrelation",
  names.arg = item_names_sympt,
  col = item_colors_sympt,
  las = 2,
  ylim = c(0, 1),
  cex.names = 0.6
)
abline(h = 0.3, col = "red", lty = 2, lwd = 2)
legend("topright", legend = "Mindestkriterium (r = 0.3)", col = "red", lty = 2, lwd = 2, bty = "n")

# Item-Trennschärfe - Gesamtskala
item_colors_sympt_coral <- ifelse(grepl("^NI", item_names_sympt), "coral4", "coral")
barplot(item_stats_sympt_gesamt$raw.r,
  main = "Item-Trennschärfe\nStresssymptome Gesamtskala",
  ylab = "Korrigierte Item-Total-Korrelation",
  names.arg = item_names_sympt,
  col = item_colors_sympt_coral,
  las = 2,
  ylim = c(0, 1),
  cex.names = 0.6
)
abline(h = 0.3, col = "red", lty = 2, lwd = 2)
legend("topright", legend = "Mindestkriterium (r = 0.3)", col = "red", lty = 2, lwd = 2, bty = "n")

dev.off()

# Verteilungsplot der Symptomskalen
png("plots/08_reliabilitaet_symptome_verteilung.png", width = 1600, height = 600, res = 150)
par(mfrow = c(1, 3))
hist(data$Stresssymptome_kurz,
  breaks = 20, col = "steelblue",
  main = "Stresssymptome Kurzskala", xlab = "Skalenwert", border = "white"
)
hist(data$Stresssymptome_lang,
  breaks = 20, col = "coral",
  main = "Stresssymptome Langskala", xlab = "Skalenwert", border = "white"
)
hist(data$Stresssymptome_gesamt,
  breaks = 20, col = "lightgreen",
  main = "Stresssymptome Gesamtskala", xlab = "Skalenwert", border = "white"
)
dev.off()

cat("✓ Reliabilitäts-Plots für Stresssymptome gespeichert\n\n")


# ==============================================================================
# 3. RELIABILITÄT: COPING-SKALEN
# ==============================================================================

print_section("3. RELIABILITÄT: COPING-SKALEN", 2)

# Liste aller Coping-Skalen
coping_skalen <- list(
  "Aktives Coping" = c("SO23_01", "SO23_20", "SO23_14", "NI07_05"),
  "Drogen-Coping" = c("NI07_01", "SO23_02", "SO23_07", "SO23_13", "SO23_17"),
  "Positive Neubewertung" = c("SO23_11", "SO23_10", "SO23_15", "NI07_04"),
  "Soziales Coping" = c("NI07_03", "SO23_04", "SO23_05", "SO23_09", "SO23_18"),
  "Religiöses Coping" = c("NI07_02", "SO23_06", "SO23_12", "SO23_16")
)

# Sammle Alpha-Werte für Plot
coping_alphas <- numeric(length(coping_skalen))
names(coping_alphas) <- names(coping_skalen)

for (skala_name in names(coping_skalen)) {
  cat("###", skala_name, "\n\n")
  items <- coping_skalen[[skala_name]]

  # Cronbachs Alpha
  alpha_result <- psych::alpha(data[, items])
  coping_alphas[skala_name] <- alpha_result$total$raw_alpha
  cat(
    "  Cronbachs Alpha:", round(alpha_result$total$raw_alpha, 3), "-",
    ifelse(alpha_result$total$raw_alpha > 0.70, "Akzeptabel bis gut", "Problematisch"), "\n\n"
  )

  # CFA (nur für Skalen mit 4+ Items)
  if (length(items) >= 4) {
    cat("  CFA Fit-Indizes:\n")

    # Modell erstellen
    skala_var <- gsub(" ", "_", gsub("-", "_", tolower(skala_name)))
    model_formula <- paste0("  ", skala_var, " =~ ", paste(items, collapse = " + "))
    model_str <- model_formula

    # CFA durchführen
    tryCatch(
      {
        fit <- cfa(model_str, data = data)
        fit_indices <- fitMeasures(fit, c("chisq", "df", "pvalue", "cfi", "tli", "rmsea", "srmr"))

        cat(
          "    χ² =", round(fit_indices["chisq"], 2), ", df =", fit_indices["df"],
          ", p =", round(fit_indices["pvalue"], 3), "\n"
        )
        cat(
          "    CFI =", round(fit_indices["cfi"], 3),
          ifelse(fit_indices["cfi"] > 0.95, " (Sehr gut)",
            ifelse(fit_indices["cfi"] > 0.90, " (Akzeptabel)", " (Problematisch)")
          ), "\n"
        )
        cat(
          "    TLI =", round(fit_indices["tli"], 3),
          ifelse(fit_indices["tli"] > 0.95, " (Sehr gut)",
            ifelse(fit_indices["tli"] > 0.90, " (Akzeptabel)", " (Problematisch)")
          ), "\n"
        )
        rmsea_val <- fit_indices["rmsea"]
        cat("    RMSEA =", round(rmsea_val, 3))
        if (rmsea_val < 0.001) {
          cat(" (Exzellent - χ² nicht signifikant)")
        } else if (rmsea_val < 0.05) {
          cat(" (Sehr gut)")
        } else if (rmsea_val < 0.08) {
          cat(" (Akzeptabel)")
        } else {
          cat(" (Problematisch)")
        }
        cat("\n")
        cat(
          "    SRMR =", round(fit_indices["srmr"], 3),
          ifelse(fit_indices["srmr"] < 0.08, " (Gut)", " (Problematisch)"), "\n"
        )
      },
      error = function(e) {
        cat("    CFA konnte nicht berechnet werden:", conditionMessage(e), "\n")
      }
    )
  } else {
    cat("  (CFA nicht möglich: weniger als 4 Items)\n")
  }
  cat("\n")
}

# RELIABILITÄTS-PLOT: Alle Skalen Cronbachs Alpha
png("plots/09_reliabilitaet_alle_alphas.png", width = 1600, height = 900, res = 150)
par(mar = c(10, 4, 4, 8), xpd = TRUE) # Mehr Platz rechts für Legende

# Kombiniere alle Alpha-Werte
alle_alphas <- c(
  coping_alphas,
  "Stressbelastung (kurz)" = alpha_stress_kurz$total$raw_alpha,
  "Stresssymptome (kurz)" = alpha_sympt_kurz$total$raw_alpha
)

# Farben für verschiedene Kategorien
coping_blues <- c("#08306B", "#2171B5", "#4292C6", "#6BAED6", "#9ECAE1", "#C6DBEF")
farben <- c(
  coping_blues[seq_along(coping_alphas)],
  "red", # Stressbelastung
  "orange" # Stresssymptome
)

bp <- barplot(alle_alphas,
  main = "Cronbachs Alpha für alle betrachteten Skalen",
  ylab = "Cronbachs Alpha",
  col = farben,
  las = 2,
  ylim = c(0, 1),
  cex.names = 0.7
)

dev.off()

cat("✓ Reliabilitäts-Plot für alle Skalen gespeichert\n\n")

# RELIABILITÄTS-PLOT: Itemstatistiken für alle Coping-Skalen
png("plots/10_reliabilitaet_coping_itemstatistiken.png", width = 2000, height = 1200, res = 150)
par(mfrow = c(2, 3), mar = c(8, 4, 4, 2))

for (i in seq_along(coping_skalen)) {
  skala_name <- names(coping_skalen)[i]
  items <- coping_skalen[[skala_name]]

  # Sortiere Items: NI-Items zuerst, dann SO-Items
  ni_items <- items[grepl("^NI", items)]
  so_items <- items[grepl("^SO", items)]
  items_sorted <- c(ni_items, so_items)

  # Berechne Alpha
  alpha_result <- psych::alpha(data[, items])
  item_stats <- alpha_result$item.stats

  # Sortiere Statistiken entsprechend
  item_stats_sorted <- item_stats[items_sorted, ]

  # Farben: NI-Items dunkler
  item_colors <- ifelse(grepl("^NI", items_sorted), "steelblue4", "steelblue")

  # Plot Item-Trennschärfe
  barplot(item_stats_sorted$r.drop,
    main = paste0(skala_name, "\n(α = ", round(alpha_result$total$raw_alpha, 3), ")"),
    ylab = "Korrigierte Item-Trennschärfe (rit)",
    names.arg = items_sorted,
    col = item_colors,
    las = 2,
    ylim = c(0, 1),
    cex.names = 0.7
  )
  abline(h = 0.3, col = "red", lty = 2, lwd = 2)
}

dev.off()

cat("✓ Itemstatistiken für Coping-Skalen gespeichert\n\n")

# Verteilungen der Coping-Skalen
png("plots/11_reliabilitaet_coping_verteilungen.png", width = 1600, height = 1000, res = 150)
par(mfrow = c(2, 3))
hist(data$Coping_aktiv,
  breaks = 15, col = "steelblue",
  main = "Aktives Coping", xlab = "Skalenwert", border = "white"
)
hist(data$Coping_Drogen,
  breaks = 15, col = "coral",
  main = "Drogen-Coping", xlab = "Skalenwert", border = "white"
)
hist(data$Coping_positiv,
  breaks = 15, col = "lightgreen",
  main = "Positive Neubewertung", xlab = "Skalenwert", border = "white"
)
hist(data$Coping_sozial,
  breaks = 15, col = "gold",
  main = "Soziales Coping", xlab = "Skalenwert", border = "white"
)
hist(data$Coping_rel,
  breaks = 15, col = "plum",
  main = "Religiöses Coping", xlab = "Skalenwert", border = "white"
)
dev.off()

cat("✓ Reliabilitäts-Plots für Coping-Skalen gespeichert\n\n")

# ##############################################################################
# TEIL II: RETEST-RELIABILITÄT
# ##############################################################################

print_section("TEIL II: RETEST-RELIABILITÄT")

cat("In diesem Abschnitt wird die Retest-Reliabilität (Stabilität) der Skalen geprüft.\n")
cat("Verwendet werden 16 Teilnehmer, die den Fragebogen zweimal ausgefüllt haben.\n\n")

# Lade zusätzliche Pakete falls nicht schon geladen
if (!require("stringdist", quietly = TRUE)) {
  cat("HINWEIS: stringdist Paket nicht verfügbar - verwende eigene Levenshtein-Implementierung\n\n")
}

# ==============================================================================
# 1. RETEST-DATEN LADEN UND VORBEREITEN
# ==============================================================================

print_section("1. RETEST-DATEN LADEN", 2)

# Lade Rohdaten (enthält sowohl A1 als auch B)
cat("Lade Rohdaten inklusive Retest-Fälle...\n")
data_raw <- read.csv("data/data_stressskala_2025-11-20_12-13.csv",
  header = TRUE,
  sep = ";",
  dec = ",",
  fileEncoding = "ISO-8859-1",
  stringsAsFactors = FALSE
)

cat("✓ Rohdaten geladen:", nrow(data_raw), "Zeilen\n\n")

# Trenne Original-Tests und Retests
original_tests <- data_raw[data_raw$QUESTNNR == "A1", ]
retest_tests <- data_raw[data_raw$QUESTNNR == "B", ]

cat("Original-Tests (QUESTNNR=A1):", nrow(original_tests), "\n")
cat("Retest-Tests (QUESTNNR=B):", nrow(retest_tests), "\n\n")

# ==============================================================================
# 2. RETEST-PAARE MATCHEN
# ==============================================================================

print_section("2. RETEST-PAARE MATCHEN", 2)

cat("Matching-Strategie: Zwei-Stufen-Matching\n")
cat("  1. Exakte Übereinstimmung (case-insensitive, ohne Leerzeichen)\n")
cat("  2. Fuzzy Matching (Levenshtein-Distanz ≤ 2) für ungematchte Fälle\n\n")

# Funktion: Levenshtein-Distanz (Edit Distance)
# Misst die minimale Anzahl von Einfügungen, Löschungen oder Ersetzungen,
# um einen String in einen anderen zu transformieren
levenshtein_distance <- function(s1, s2) {
  n <- nchar(s1)
  m <- nchar(s2)

  # Matrix initialisieren
  d <- matrix(0, nrow = n + 1, ncol = m + 1)

  # Erste Zeile und Spalte
  d[, 1] <- 0:n
  d[1, ] <- 0:m

  # Matrix füllen
  for (i in 2:(n + 1)) {
    for (j in 2:(m + 1)) {
      cost <- ifelse(substr(s1, i - 1, i - 1) == substr(s2, j - 1, j - 1), 0, 1)
      d[i, j] <- min(
        d[i - 1, j] + 1,      # Löschung
        d[i, j - 1] + 1,      # Einfügung
        d[i - 1, j - 1] + cost # Ersetzung
      )
    }
  }

  return(d[n + 1, m + 1])
}

# Bereinige VPN-Codes (Leerzeichen entfernen, Kleinbuchstaben)
clean_vpn <- function(vpn) {
  tolower(trimws(vpn))
}

original_tests$VPN_clean <- clean_vpn(original_tests$DE12_01)
retest_tests$VPN_clean <- clean_vpn(retest_tests$DE12_01)

# STUFE 1: Exakte Übereinstimmung
cat("STUFE 1: Exakte Übereinstimmung...\n")

retest_matches <- data.frame(
  VPN_original = character(),
  VPN_retest = character(),
  idx_original = integer(),
  idx_retest = integer(),
  match_type = character(),
  edit_distance = integer(),
  stringsAsFactors = FALSE
)

matched_retest_idx <- c()  # Bereits gematchte Retest-Fälle
matched_original_idx <- c() # Bereits gematchte Original-Fälle

for (i in 1:nrow(retest_tests)) {
  vpn_retest <- retest_tests$VPN_clean[i]

  # Suche exakte Übereinstimmung in original_tests
  match_idx <- which(original_tests$VPN_clean == vpn_retest)

  if (length(match_idx) > 0) {
    # Exakte Übereinstimmung gefunden
    retest_matches <- rbind(retest_matches, data.frame(
      VPN_original = original_tests$DE12_01[match_idx[1]],
      VPN_retest = retest_tests$DE12_01[i],
      idx_original = match_idx[1],
      idx_retest = i,
      match_type = "exact",
      edit_distance = 0,
      stringsAsFactors = FALSE
    ))

    matched_retest_idx <- c(matched_retest_idx, i)
    matched_original_idx <- c(matched_original_idx, match_idx[1])
  }
}

n_exact_matches <- nrow(retest_matches)
cat(sprintf("✓ Exakte Übereinstimmungen: %d\n", n_exact_matches))

# STUFE 2: Fuzzy Matching für ungematchte Fälle
cat("\nSTUFE 2: Fuzzy Matching für ungematchte Fälle...\n")

unmatched_retest_idx <- setdiff(1:nrow(retest_tests), matched_retest_idx)
unmatched_original_idx <- setdiff(1:nrow(original_tests), matched_original_idx)

cat(sprintf("  Ungematchte Retest-Fälle: %d\n", length(unmatched_retest_idx)))
cat(sprintf("  Ungematchte Original-Fälle: %d\n", length(unmatched_original_idx)))

MAX_EDIT_DISTANCE <- 2  # Maximale Edit-Distanz für Fuzzy Match

for (i in unmatched_retest_idx) {
  vpn_retest <- retest_tests$VPN_clean[i]

  # Berechne Edit-Distanz zu allen ungematchten Original-VPNs
  best_match_idx <- NA
  best_distance <- Inf

  for (j in unmatched_original_idx) {
    vpn_original <- original_tests$VPN_clean[j]
    distance <- levenshtein_distance(vpn_retest, vpn_original)

    if (distance < best_distance && distance <= MAX_EDIT_DISTANCE) {
      best_distance <- distance
      best_match_idx <- j
    }
  }

  # Wenn ein guter Match gefunden wurde
  if (!is.na(best_match_idx)) {
    retest_matches <- rbind(retest_matches, data.frame(
      VPN_original = original_tests$DE12_01[best_match_idx],
      VPN_retest = retest_tests$DE12_01[i],
      idx_original = best_match_idx,
      idx_retest = i,
      match_type = "fuzzy",
      edit_distance = best_distance,
      stringsAsFactors = FALSE
    ))

    # Entferne gematchte Fälle aus unmatched Listen
    unmatched_original_idx <- setdiff(unmatched_original_idx, best_match_idx)

    cat(sprintf("  Fuzzy Match: %s <-> %s (Distanz: %d)\n",
                retest_tests$DE12_01[i],
                original_tests$DE12_01[best_match_idx],
                best_distance))
  }
}

n_fuzzy_matches <- nrow(retest_matches) - n_exact_matches
cat(sprintf("\n✓ Fuzzy Matches: %d\n", n_fuzzy_matches))

n_matches <- nrow(retest_matches)
cat(sprintf("✓ Gesamt-Matches: %d von %d Retest-Fällen\n", n_matches, nrow(retest_tests)))
cat(sprintf("✓ Ungematchte Retest-Fälle: %d\n\n", nrow(retest_tests) - n_matches))

cat("Gematchte Retest-Paare:\n")
cat(paste(rep("-", 80), collapse = ""), "\n")
for (i in 1:nrow(retest_matches)) {
  match_symbol <- ifelse(retest_matches$match_type[i] == "exact", "=", "~")
  cat(sprintf("%2d. %s %s %s (%s, d=%d)\n", i,
    retest_matches$VPN_original[i],
    match_symbol,
    retest_matches$VPN_retest[i],
    retest_matches$match_type[i],
    retest_matches$edit_distance[i]))
}
cat("\n")

# ==============================================================================
# 3. SKALEN FÜR RETEST-PAARE BERECHNEN
# ==============================================================================

print_section("3. SKALEN FÜR RETEST-PAARE BERECHNEN", 2)

cat("Berechne Skalenwerte für Original- und Retest-Daten...\n\n")

# Funktion: Berechne alle Skalen für einen Datensatz
calculate_scales <- function(df) {
  # Neurotizismus
  df$Neurotizismus <- (df$BF01_02 + 6 - df$BF01_01) / 2

  # Resilienz (mit Reverse Coding)
  df$RE01_02_rev <- 7 - df$RE01_02
  df$RE01_04_rev <- 7 - df$RE01_04
  df$RE01_06_rev <- 7 - df$RE01_06
  df$Resilienz <- rowMeans(
    df[, c("RE01_01", "RE01_02_rev", "RE01_03", "RE01_04_rev", "RE01_05", "RE01_06_rev")],
    na.rm = TRUE
  )

  # Stressbelastung
  df$Stressbelastung_kurz <- rowMeans(
    df[, c("NI06_01", "NI06_02", "NI06_03", "NI06_04", "NI06_05")],
    na.rm = TRUE
  )
  df$Stressbelastung_lang <- rowMeans(
    df[, c("SO01_01", "SO01_02", "SO01_03", "SO01_04", "SO01_05",
           "SO01_06", "SO01_07", "SO01_09", "SO01_10", "SO01_11")],
    na.rm = TRUE
  )
  df$Stressbelastung_gesamt <- rowMeans(
    df[, c("NI06_01", "NI06_02", "NI06_03", "NI06_04", "NI06_05",
           "SO01_01", "SO01_02", "SO01_03", "SO01_04", "SO01_05",
           "SO01_06", "SO01_07", "SO01_08", "SO01_09", "SO01_10", "SO01_11")],
    na.rm = TRUE
  )

  # Stresssymptome
  df$Stresssymptome_kurz <- rowMeans(
    df[, c("NI13_01", "NI13_02", "NI13_03", "NI13_04", "NI13_05")],
    na.rm = TRUE
  )
  df$Stresssymptome_lang <- rowMeans(
    df[, c("SO02_01", "SO02_02", "SO02_03", "SO02_04", "SO02_05",
           "SO02_06", "SO02_07", "SO02_08", "SO02_09", "SO02_10",
           "SO02_11", "SO02_12", "SO02_13")],
    na.rm = TRUE
  )
  df$Stresssymptome_gesamt <- rowMeans(
    df[, c("NI13_01", "NI13_02", "NI13_03", "NI13_04", "NI13_05",
           "SO02_01", "SO02_02", "SO02_03", "SO02_04", "SO02_05",
           "SO02_06", "SO02_07", "SO02_08", "SO02_09", "SO02_10",
           "SO02_11", "SO02_12", "SO02_13", "SO02_14")],
    na.rm = TRUE
  )

  # Coping (mit Reverse Coding)
  df$SO23_13_rev <- 7 - df$SO23_13

  df$Coping_aktiv <- rowMeans(
    df[, c("SO23_01", "SO23_20", "SO23_14", "NI07_05")],
    na.rm = TRUE
  )
  df$Coping_Drogen <- rowMeans(
    df[, c("NI07_01", "SO23_02", "SO23_07", "SO23_13_rev", "SO23_17")],
    na.rm = TRUE
  )
  df$Coping_positiv <- rowMeans(
    df[, c("SO23_11", "SO23_10", "SO23_15", "NI07_04")],
    na.rm = TRUE
  )
  df$Coping_sozial <- rowMeans(
    df[, c("NI07_03", "SO23_04", "SO23_05", "SO23_09", "SO23_18")],
    na.rm = TRUE
  )
  df$Coping_rel <- rowMeans(
    df[, c("NI07_02", "SO23_06", "SO23_12", "SO23_16")],
    na.rm = TRUE
  )

  return(df)
}

# Berechne Skalen
original_tests <- calculate_scales(original_tests)
retest_tests <- calculate_scales(retest_tests)

cat("✓ Skalen für Original-Tests berechnet\n")
cat("✓ Skalen für Retest-Tests berechnet\n\n")

# ==============================================================================
# 4. RETEST-RELIABILITÄT BERECHNEN
# ==============================================================================

print_section("4. RETEST-RELIABILITÄT (Test-Retest-Korrelationen)", 2)

cat("Methode: Pearson-Korrelation zwischen Test und Retest\n")
cat("Interpretation:\n")
cat("  r > .80: Exzellent\n")
cat("  r > .70: Gut\n")
cat("  r > .60: Akzeptabel\n")
cat("  r < .60: Problematisch\n\n")

# Liste der zu analysierenden Skalen
skalen_liste <- c(
  "Neurotizismus",
  "Resilienz",
  "Stressbelastung_kurz",
  "Stressbelastung_lang",
  "Stressbelastung_gesamt",
  "Stresssymptome_kurz",
  "Stresssymptome_lang",
  "Stresssymptome_gesamt",
  "Coping_aktiv",
  "Coping_Drogen",
  "Coping_positiv",
  "Coping_sozial",
  "Coping_rel"
)

# Dataframe für Ergebnisse
retest_results <- data.frame(
  Skala = character(),
  N = integer(),
  r = numeric(),
  p = numeric(),
  CI_lower = numeric(),
  CI_upper = numeric(),
  Interpretation = character(),
  stringsAsFactors = FALSE
)

cat("Retest-Reliabilitäten (N =", n_matches, "):\n")
cat(paste(rep("=", 80), collapse = ""), "\n\n")

for (skala in skalen_liste) {
  # Hole Werte für Test und Retest
  test_values <- original_tests[retest_matches$idx_original, skala]
  retest_values <- retest_tests[retest_matches$idx_retest, skala]

  # Entferne NA-Paare
  valid_pairs <- !is.na(test_values) & !is.na(retest_values)
  test_values <- test_values[valid_pairs]
  retest_values <- retest_values[valid_pairs]

  n_pairs <- length(test_values)

  if (n_pairs >= 3) {
    # Berechne Korrelation
    cor_result <- cor.test(test_values, retest_values, method = "pearson")
    r_value <- cor_result$estimate
    p_value <- cor_result$p.value
    ci_lower <- cor_result$conf.int[1]
    ci_upper <- cor_result$conf.int[2]

    # Interpretation
    interpretation <- ifelse(r_value > 0.80, "Exzellent",
                      ifelse(r_value > 0.70, "Gut",
                      ifelse(r_value > 0.60, "Akzeptabel", "Problematisch")))

    # Speichere Ergebnisse
    retest_results <- rbind(retest_results, data.frame(
      Skala = skala,
      N = n_pairs,
      r = r_value,
      p = p_value,
      CI_lower = ci_lower,
      CI_upper = ci_upper,
      Interpretation = interpretation,
      stringsAsFactors = FALSE
    ))

    # Ausgabe
    sig_symbol <- ifelse(p_value < 0.001, "***",
                  ifelse(p_value < 0.01, "**",
                  ifelse(p_value < 0.05, "*", "")))

    cat(sprintf("%-30s: r = %.3f%s [%.3f, %.3f] (N = %d) - %s\n",
                skala, r_value, sig_symbol, ci_lower, ci_upper,
                n_pairs, interpretation))
  } else {
    cat(sprintf("%-30s: Nicht genug Daten (N = %d)\n", skala, n_pairs))
  }
}

cat("\n")
cat("Signifikanzniveaus: *** p<.001, ** p<.01, * p<.05\n\n")

# ==============================================================================
# 4.1. ITEM-LEVEL RETEST-RELIABILITÄT
# ==============================================================================

print_section("4.1. ITEM-LEVEL RETEST-RELIABILITÄT", 2)

cat("Retest-Reliabilitäten auf Item-Ebene (nach Skala geordnet)\n\n")

# Definiere Item-Gruppen nach Skalen
item_gruppen <- list(
  "Big Five (Neurotizismus)" = c("BF01_01", "BF01_02"),

  "Resilienz" = c("RE01_01", "RE01_02", "RE01_03", "RE01_04", "RE01_05", "RE01_06"),

  "Stressbelastung (kurz)" = c("NI06_01", "NI06_02", "NI06_03", "NI06_04", "NI06_05"),

  "Stressbelastung (lang)" = c("SO01_01", "SO01_02", "SO01_03", "SO01_04", "SO01_05",
                               "SO01_06", "SO01_07", "SO01_08", "SO01_09", "SO01_10", "SO01_11"),

  "Stresssymptome (kurz)" = c("NI13_01", "NI13_02", "NI13_03", "NI13_04", "NI13_05"),

  "Stresssymptome (lang)" = c("SO02_01", "SO02_02", "SO02_03", "SO02_04", "SO02_05",
                              "SO02_06", "SO02_07", "SO02_08", "SO02_09", "SO02_10",
                              "SO02_11", "SO02_12", "SO02_13"),

  "Coping: Aktiv" = c("SO23_01", "SO23_20", "SO23_14", "NI07_05"),

  "Coping: Drogen" = c("NI07_01", "SO23_02", "SO23_07", "SO23_13", "SO23_17"),

  "Coping: Positive Neubewertung" = c("SO23_11", "SO23_10", "SO23_15", "NI07_04"),

  "Coping: Sozial" = c("NI07_03", "SO23_04", "SO23_05", "SO23_09", "SO23_18"),

  "Coping: Religiös" = c("NI07_02", "SO23_06", "SO23_12", "SO23_16")
)

# Berechne Retest-Reliabilitäten für jedes Item
for (gruppe_name in names(item_gruppen)) {
  items <- item_gruppen[[gruppe_name]]

  cat(sprintf("### %s\n", gruppe_name))

  # Sammle Korrelationen für diese Gruppe
  item_cors <- c()

  for (item in items) {
    # Prüfe ob Item in beiden Datensätzen vorhanden ist
    if (item %in% colnames(original_tests) && item %in% colnames(retest_tests)) {
      # Hole Werte für Test und Retest
      test_values <- original_tests[retest_matches$idx_original, item]
      retest_values <- retest_tests[retest_matches$idx_retest, item]

      # Entferne NA-Paare
      valid_pairs <- !is.na(test_values) & !is.na(retest_values)
      test_values <- test_values[valid_pairs]
      retest_values <- retest_values[valid_pairs]

      if (length(test_values) >= 3) {
        # Berechne Korrelation
        cor_result <- tryCatch({
          cor.test(test_values, retest_values, method = "pearson")
        }, error = function(e) NULL)

        if (!is.null(cor_result)) {
          r_value <- cor_result$estimate
          p_value <- cor_result$p.value
          item_cors <- c(item_cors, r_value)

          # Interpretation
          interpretation <- ifelse(r_value > 0.80, "Exz",
                            ifelse(r_value > 0.70, "Gut",
                            ifelse(r_value > 0.60, "Akz", "Pro")))

          sig_symbol <- ifelse(p_value < 0.001, "***",
                        ifelse(p_value < 0.01, "**",
                        ifelse(p_value < 0.05, "*", "ns")))
        } else {
          interpretation <- "Err"
          sig_symbol <- ""
        }
      } else {
        interpretation <- "N<3"
        sig_symbol <- ""
        r_value <- NA
      }
    } else {
      interpretation <- "N/A"
      sig_symbol <- ""
      r_value <- NA
    }

    if (!is.na(r_value)) {
      cat(sprintf("  %-10s: r = %.3f%-3s [%s]\n", item, r_value, sig_symbol, interpretation))
    } else {
      cat(sprintf("  %-10s: %s\n", item, interpretation))
    }
  }

  # Durchschnitt für diese Gruppe
  if (length(item_cors) > 0) {
    mean_r <- mean(item_cors, na.rm = TRUE)
    cat(sprintf("  → Durchschnitt: r = %.3f\n\n", mean_r))
  } else {
    cat("  → Durchschnitt: nicht berechenbar\n\n")
  }
}

cat("Abkürzungen: Exz=Exzellent (>.80), Gut (>.70), Akz=Akzeptabel (>.60), Pro=Problematisch (<.60)\n")
cat("Signifikanz: *** p<.001, ** p<.01, * p<.05, ns=nicht signifikant\n\n")

# ==============================================================================
# 5. RETEST-RELIABILITÄT VISUALISIERUNG
# ==============================================================================

print_section("5. RETEST-RELIABILITÄT VISUALISIERUNG", 2)

# Sammle alle Item-Korrelationen für Plot
all_item_cors <- c()
all_item_names <- c()
all_item_groups <- c()

for (gruppe_name in names(item_gruppen)) {
  items <- item_gruppen[[gruppe_name]]

  for (item in items) {
    if (item %in% colnames(original_tests) && item %in% colnames(retest_tests)) {
      test_values <- original_tests[retest_matches$idx_original, item]
      retest_values <- retest_tests[retest_matches$idx_retest, item]

      valid_pairs <- !is.na(test_values) & !is.na(retest_values)
      test_values <- test_values[valid_pairs]
      retest_values <- retest_values[valid_pairs]

      if (length(test_values) >= 3) {
        cor_result <- tryCatch({
          cor.test(test_values, retest_values, method = "pearson")
        }, error = function(e) NULL)

        if (!is.null(cor_result)) {
          all_item_cors <- c(all_item_cors, cor_result$estimate)
          all_item_names <- c(all_item_names, item)
          all_item_groups <- c(all_item_groups, gruppe_name)
        }
      }
    }
  }
}

# Plot: Item-Level Retest-Reliabilitäten
png("plots/12_retest_item_reliabilitaet.png", width = 2000, height = 1000, res = 150)
par(mar = c(8, 4, 8, 2), xpd = TRUE)

# Filtere Big Five und Resilienz Items aus
keep_idx <- !(all_item_groups %in% c("Big Five (Neurotizismus)", "Resilienz"))
filtered_cors <- all_item_cors[keep_idx]
filtered_names <- all_item_names[keep_idx]
filtered_groups <- all_item_groups[keep_idx]

# Sortiere Items nach Gruppe (Skala), dann nach Item-Name
sort_idx <- order(filtered_groups, filtered_names)
item_cors_sorted <- filtered_cors[sort_idx]
item_names_sorted <- filtered_names[sort_idx]
item_groups_sorted <- filtered_groups[sort_idx]

# Farben basierend auf Gruppe (Skala) - wie im CFA-Netzwerk-Plot
# Rottöne für Belastung und Symptome, Blautöne für Coping-Skalen
gruppe_colors <- c(
  "Stressbelastung (kurz)" = "#8B0000",  # Dunkelrot
  "Stressbelastung (lang)" = "#B22222",  # Feuerrot
  "Stresssymptome (kurz)" = "#DC143C",   # Crimson
  "Stresssymptome (lang)" = "#FF6347",   # Tomatenrot
  "Coping: Aktiv" = "#08306B",           # Dunkelblau
  "Coping: Drogen" = "#2171B5",          # Mittelblau
  "Coping: Positive Neubewertung" = "#4292C6",  # Helleres Blau
  "Coping: Sozial" = "#6BAED6",          # Noch helleres Blau
  "Coping: Religiös" = "#9ECAE1"         # Hellblau
)

item_colors <- gruppe_colors[item_groups_sorted]

barplot(item_cors_sorted,
  main = "Item-Level Retest-Reliabilitäten (nach Skala sortiert)",
  ylab = "Korrelation (r)",
  names.arg = item_names_sorted,
  col = item_colors,
  las = 2,
  ylim = c(0, 1),
  cex.names = 0.6
)

# Referenzlinien (alle grau)
abline(h = 0.80, col = "grey50", lty = 2, lwd = 1.5)
abline(h = 0.70, col = "grey50", lty = 2, lwd = 1.5)
abline(h = 0.60, col = "grey50", lty = 2, lwd = 1.5)

# Legende mit Skalen-Namen (oberhalb des Plots)
legend("top", inset = c(0, -0.15),
  legend = c("Stressbelastung (kurz)", "Stressbelastung (lang)",
             "Stresssymptome (kurz)", "Stresssymptome (lang)",
             "Coping: Aktiv", "Coping: Drogen",
             "Coping: Positive Neubewertung", "Coping: Sozial", "Coping: Religiös"),
  fill = c("#8B0000", "#B22222", "#DC143C", "#FF6347",
           "#08306B", "#2171B5", "#4292C6", "#6BAED6", "#9ECAE1"),
  bty = "n",
  cex = 0.7,
  ncol = 3
)

dev.off()

cat("✓ Item-Level Retest-Reliabilitäts-Plot gespeichert (Plot 12)\n\n")

# ==============================================================================
# 6. FAZIT RETEST-RELIABILITÄT
# ==============================================================================

print_section("6. FAZIT RETEST-RELIABILITÄT", 2)

# Berechne Durchschnitt
mean_r <- mean(retest_results$r, na.rm = TRUE)
median_r <- median(retest_results$r, na.rm = TRUE)

# Zähle nach Interpretation
n_exzellent <- sum(retest_results$Interpretation == "Exzellent")
n_gut <- sum(retest_results$Interpretation == "Gut")
n_akzeptabel <- sum(retest_results$Interpretation == "Akzeptabel")
n_problematisch <- sum(retest_results$Interpretation == "Problematisch")

cat("ZUSAMMENFASSUNG RETEST-RELIABILITÄT:\n")
cat(paste(rep("=", 80), collapse = ""), "\n\n")

cat(sprintf("Anzahl Retest-Paare: %d\n", n_matches))
cat(sprintf("Zeitabstand zwischen Test und Retest: ~2 Wochen\n\n"))

cat(sprintf("Durchschnittliche Retest-Reliabilität: r = %.3f\n", mean_r))
cat(sprintf("Median Retest-Reliabilität: r = %.3f\n\n", median_r))

cat("Verteilung der Reliabilitäten:\n")
cat(sprintf("  - Exzellent (r > .80):     %2d (%.1f%%)\n",
            n_exzellent, 100 * n_exzellent / nrow(retest_results)))
cat(sprintf("  - Gut (r > .70):           %2d (%.1f%%)\n",
            n_gut, 100 * n_gut / nrow(retest_results)))
cat(sprintf("  - Akzeptabel (r > .60):    %2d (%.1f%%)\n",
            n_akzeptabel, 100 * n_akzeptabel / nrow(retest_results)))
cat(sprintf("  - Problematisch (r < .60): %2d (%.1f%%)\n\n",
            n_problematisch, 100 * n_problematisch / nrow(retest_results)))

if (mean_r > 0.70) {
  cat("INTERPRETATION: Die Skalen zeigen insgesamt gute bis exzellente Retest-Reliabilitäten.\n")
  cat("                Die Messungen sind über die Zeit stabil.\n")
} else if (mean_r > 0.60) {
  cat("INTERPRETATION: Die Skalen zeigen akzeptable Retest-Reliabilitäten.\n")
  cat("                Einige Skalen könnten instabiler sein.\n")
} else {
  cat("INTERPRETATION: Die Retest-Reliabilitäten sind teilweise problematisch.\n")
  cat("                Prüfen Sie die Skalen mit niedriger Reliabilität genauer.\n")
}

cat("\n✓ Retest-Reliabilitätsanalyse abgeschlossen\n\n")

# ==============================================================================
# ZUSAMMENFASSUNG
# ==============================================================================

print_section("FERTIG")

cat("Alle Reliabilitätsanalysen wurden erfolgreich durchgeführt.\n\n")
cat("Plots gespeichert: 05-12\n\n")
cat("Führen Sie als nächstes aus: 04_validity_main.R\n\n")
