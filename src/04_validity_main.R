#!/usr/bin/env Rscript
# ==============================================================================
# VALIDITÄTSANALYSEN (HAUPTANALYSEN)
# ==============================================================================
#
# Dieses Skript führt die Hauptvaliditätsanalysen durch:
# - Konvergente Validität für Stressbelastung
# - Konvergente Validität für Stresssymptome
# - Konvergente Validität für Coping-Strategien
#
# Validitätskriterien:
# - Zufriedenheit
# - Neurotizismus
# - Resilienz
#
# Plots: 13-16
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
if (!exists("PLOTS_DIR")) {
  PLOTS_DIR <- "plots"
}

# ==============================================================================
# WORKSPACE LADEN
# ==============================================================================

cat("Lade Workspace von 01_setup_and_scales.R...\n")
load(WORKSPACE_FILE)
cat("✓ Workspace geladen:", WORKSPACE_FILE, "\n\n")

# ==============================================================================
# PAKETE LADEN
# ==============================================================================

suppressPackageStartupMessages({
  library(tidyverse)
  library(lavaan)
  library(psych)
})

# ##############################################################################
# TEIL II: VALIDITÄT
# ##############################################################################

print_section("TEIL II: VALIDITÄTSANALYSEN (KONVERGENTE VALIDITÄT)")

cat("In diesem Abschnitt wird die Validität der Skalen geprüft.\n")
cat("Konvergente Validität: Korrelationen mit theoretisch verwandten Konstrukten\n\n")
cat("Erwartete Zusammenhänge:\n")
cat("  - Stressbelastung/Stresssymptome → negativ mit Zufriedenheit\n")
cat("  - Stressbelastung/Stresssymptome → positiv mit Neurotizismus\n")
cat("  - Stressbelastung/Stresssymptome → negativ mit Resilienz\n")
cat("  - Coping-Strategien → unterschiedliche Muster je nach Adaptivität\n\n")


# ==============================================================================
# 4. VALIDITÄT: STRESSBELASTUNG
# ==============================================================================

print_section("4. KONVERGENTE VALIDITÄT: STRESSBELASTUNG", 2)

cat("### 4.1 Korrelationen mit Zufriedenheit\n\n")
cor_kurz_zuf <- cor.test(data$Stressbelastung_kurz, data$Zufriedenheit)
cor_lang_zuf <- cor.test(data$Stressbelastung_lang, data$Zufriedenheit)
cor_gesamt_zuf <- cor.test(data$Stressbelastung_gesamt, data$Zufriedenheit)

cat(
  "  Kurzskala:    r =", round(cor_kurz_zuf$estimate, 3),
  ", p =", format.pval(cor_kurz_zuf$p.value, digits = 3), "\n"
)
cat(
  "  Langskala:    r =", round(cor_lang_zuf$estimate, 3),
  ", p =", format.pval(cor_lang_zuf$p.value, digits = 3), "\n"
)
cat(
  "  Gesamtskala:  r =", round(cor_gesamt_zuf$estimate, 3),
  ", p =", format.pval(cor_gesamt_zuf$p.value, digits = 3), "\n\n"
)

cat("### 4.2 Korrelationen mit Neurotizismus\n\n")
cor_kurz_neu <- cor.test(data$Stressbelastung_kurz, data$Neurotizismus)
cor_lang_neu <- cor.test(data$Stressbelastung_lang, data$Neurotizismus)
cor_gesamt_neu <- cor.test(data$Stressbelastung_gesamt, data$Neurotizismus)

cat(
  "  Kurzskala:    r =", round(cor_kurz_neu$estimate, 3),
  ", p =", format.pval(cor_kurz_neu$p.value, digits = 3), "\n"
)
cat(
  "  Langskala:    r =", round(cor_lang_neu$estimate, 3),
  ", p =", format.pval(cor_lang_neu$p.value, digits = 3), "\n"
)
cat(
  "  Gesamtskala:  r =", round(cor_gesamt_neu$estimate, 3),
  ", p =", format.pval(cor_gesamt_neu$p.value, digits = 3), "\n\n"
)

cat("### 4.3 Korrelationen mit Resilienz\n\n")
cor_kurz_res <- cor.test(data$Stressbelastung_kurz, data$Resilienz)
cor_lang_res <- cor.test(data$Stressbelastung_lang, data$Resilienz)
cor_gesamt_res <- cor.test(data$Stressbelastung_gesamt, data$Resilienz)

cat(
  "  Kurzskala:    r =", round(cor_kurz_res$estimate, 3),
  ", p =", format.pval(cor_kurz_res$p.value, digits = 3), "\n"
)
cat(
  "  Langskala:    r =", round(cor_lang_res$estimate, 3),
  ", p =", format.pval(cor_lang_res$p.value, digits = 3), "\n"
)
cat(
  "  Gesamtskala:  r =", round(cor_gesamt_res$estimate, 3),
  ", p =", format.pval(cor_gesamt_res$p.value, digits = 3), "\n\n"
)

cat("Fazit:\n")
cat(
  "  - Kurzskala korreliert",
  ifelse(abs(cor_kurz_zuf$estimate) > 0.3, "substanziell", "schwach"),
  "mit Validitätskriterien\n"
)
cat(
  "  - Konvergente Validität ist",
  ifelse(cor_kurz_zuf$p.value < 0.001 & cor_kurz_neu$p.value < 0.001,
    "gegeben", "fraglich"
  ), "\n\n"
)

# VALIDITÄTS-PLOT: Stressbelastung Korrelationen (standardisiert)
png(file.path(PLOTS_DIR, "13_validitaet_stress_korrelationen.png"), width = 1800, height = 600, res = 150)
par(mfrow = c(1, 3))

# Standardisiere Variablen
stress_z <- scale(data$Stressbelastung_kurz)
zuf_z <- scale(data$Zufriedenheit)
neu_z <- scale(data$Neurotizismus)
res_z <- scale(data$Resilienz)

# Mit Zufriedenheit
lm_zuf_std <- lm(zuf_z ~ stress_z)
plot(stress_z, zuf_z,
  main = "Stressbelastung × Zufriedenheit",
  xlab = "Stressbelastung (standardisiert)",
  ylab = "Zufriedenheit (standardisiert)",
  pch = 19, col = rgb(0, 0, 1, 0.3)
)
abline(lm_zuf_std, col = "red", lwd = 2)
legend("topright",
  legend = c(
    paste0(
      "β = ", round(coef(lm_zuf_std)[2], 3),
      ifelse(cor_kurz_zuf$p.value < 0.001, "***",
        ifelse(cor_kurz_zuf$p.value < 0.01, "**",
          ifelse(cor_kurz_zuf$p.value < 0.05, "*", "")
        )
      )
    ),
    paste0("R² = ", round(summary(lm_zuf_std)$r.squared, 3))
  ),
  bty = "n"
)

# Mit Neurotizismus
lm_neu_std <- lm(neu_z ~ stress_z)
plot(stress_z, neu_z,
  main = "Stressbelastung × Neurotizismus",
  xlab = "Stressbelastung (standardisiert)",
  ylab = "Neurotizismus (standardisiert)",
  pch = 19, col = rgb(1, 0, 0, 0.3)
)
abline(lm_neu_std, col = "blue", lwd = 2)
legend("topleft",
  legend = c(
    paste0(
      "β = ", round(coef(lm_neu_std)[2], 3),
      ifelse(cor_kurz_neu$p.value < 0.001, "***",
        ifelse(cor_kurz_neu$p.value < 0.01, "**",
          ifelse(cor_kurz_neu$p.value < 0.05, "*", "")
        )
      )
    ),
    paste0("R² = ", round(summary(lm_neu_std)$r.squared, 3))
  ),
  bty = "n"
)

# Mit Resilienz
lm_res_std <- lm(res_z ~ stress_z)
plot(stress_z, res_z,
  main = "Stressbelastung × Resilienz",
  xlab = "Stressbelastung (standardisiert)",
  ylab = "Resilienz (standardisiert)",
  pch = 19, col = rgb(0, 0.5, 0, 0.3)
)
abline(lm_res_std, col = "purple", lwd = 2)
legend("topright",
  legend = c(
    paste0(
      "β = ", round(coef(lm_res_std)[2], 3),
      ifelse(cor_kurz_res$p.value < 0.001, "***",
        ifelse(cor_kurz_res$p.value < 0.01, "**",
          ifelse(cor_kurz_res$p.value < 0.05, "*", "")
        )
      )
    ),
    paste0("R² = ", round(summary(lm_res_std)$r.squared, 3))
  ),
  bty = "n"
)

dev.off()

cat("✓ Validitäts-Plots für Stressbelastung gespeichert\n\n")


# ==============================================================================
# 5. VALIDITÄT: STRESSSYMPTOME
# ==============================================================================

print_section("5. KONVERGENTE VALIDITÄT: STRESSSYMPTOME", 2)

cat("### 5.1 Korrelationen mit Zufriedenheit\n\n")
cor_kurz_zuf <- cor.test(data$Stresssymptome_kurz, data$Zufriedenheit)
cor_lang_zuf <- cor.test(data$Stresssymptome_lang, data$Zufriedenheit)
cor_gesamt_zuf <- cor.test(data$Stresssymptome_gesamt, data$Zufriedenheit)

cat(
  "  Kurzskala:    r =", round(cor_kurz_zuf$estimate, 3),
  ", p =", format.pval(cor_kurz_zuf$p.value, digits = 3), "\n"
)
cat(
  "  Langskala:    r =", round(cor_lang_zuf$estimate, 3),
  ", p =", format.pval(cor_lang_zuf$p.value, digits = 3), "\n"
)
cat(
  "  Gesamtskala:  r =", round(cor_gesamt_zuf$estimate, 3),
  ", p =", format.pval(cor_gesamt_zuf$p.value, digits = 3), "\n\n"
)

cat("### 5.2 Korrelationen mit Neurotizismus\n\n")
cor_kurz_neu <- cor.test(data$Stresssymptome_kurz, data$Neurotizismus)
cor_lang_neu <- cor.test(data$Stresssymptome_lang, data$Neurotizismus)
cor_gesamt_neu <- cor.test(data$Stresssymptome_gesamt, data$Neurotizismus)

cat(
  "  Kurzskala:    r =", round(cor_kurz_neu$estimate, 3),
  ", p =", format.pval(cor_kurz_neu$p.value, digits = 3), "\n"
)
cat(
  "  Langskala:    r =", round(cor_lang_neu$estimate, 3),
  ", p =", format.pval(cor_lang_neu$p.value, digits = 3), "\n"
)
cat(
  "  Gesamtskala:  r =", round(cor_gesamt_neu$estimate, 3),
  ", p =", format.pval(cor_gesamt_neu$p.value, digits = 3), "\n\n"
)

cat("### 5.3 Korrelationen mit Resilienz\n\n")
cor_kurz_res <- cor.test(data$Stresssymptome_kurz, data$Resilienz)
cor_lang_res <- cor.test(data$Stresssymptome_lang, data$Resilienz)
cor_gesamt_res <- cor.test(data$Stresssymptome_gesamt, data$Resilienz)

cat(
  "  Kurzskala:    r =", round(cor_kurz_res$estimate, 3),
  ", p =", format.pval(cor_kurz_res$p.value, digits = 3), "\n"
)
cat(
  "  Langskala:    r =", round(cor_lang_res$estimate, 3),
  ", p =", format.pval(cor_lang_res$p.value, digits = 3), "\n"
)
cat(
  "  Gesamtskala:  r =", round(cor_gesamt_res$estimate, 3),
  ", p =", format.pval(cor_gesamt_res$p.value, digits = 3), "\n\n"
)

# VALIDITÄTS-PLOT: Stresssymptome Korrelationen (standardisiert)
png(file.path(PLOTS_DIR, "14_validitaet_symptome_korrelationen.png"), width = 1800, height = 600, res = 150)
par(mfrow = c(1, 3))

# Korrelationen neu berechnen für Stresssymptome
cor_sympt_zuf <- cor.test(data$Stresssymptome_kurz, data$Zufriedenheit)
cor_sympt_neu <- cor.test(data$Stresssymptome_kurz, data$Neurotizismus)
cor_sympt_res <- cor.test(data$Stresssymptome_kurz, data$Resilienz)

# Standardisiere Variablen
symptome_z <- scale(data$Stresssymptome_kurz)
zuf_z <- scale(data$Zufriedenheit)
neu_z <- scale(data$Neurotizismus)
res_z <- scale(data$Resilienz)

# Mit Zufriedenheit
lm_sympt_zuf_std <- lm(zuf_z ~ symptome_z)
plot(symptome_z, zuf_z,
  main = "Stresssymptome × Zufriedenheit",
  xlab = "Stresssymptome (standardisiert)",
  ylab = "Zufriedenheit (standardisiert)",
  pch = 19, col = rgb(0, 0, 1, 0.3)
)
abline(lm_sympt_zuf_std, col = "red", lwd = 2)
legend("topright",
  legend = c(
    paste0(
      "β = ", round(coef(lm_sympt_zuf_std)[2], 3),
      ifelse(cor_sympt_zuf$p.value < 0.001, "***",
        ifelse(cor_sympt_zuf$p.value < 0.01, "**",
          ifelse(cor_sympt_zuf$p.value < 0.05, "*", "")
        )
      )
    ),
    paste0("R² = ", round(summary(lm_sympt_zuf_std)$r.squared, 3))
  ),
  bty = "n"
)

# Mit Neurotizismus
lm_sympt_neu_std <- lm(neu_z ~ symptome_z)
plot(symptome_z, neu_z,
  main = "Stresssymptome × Neurotizismus",
  xlab = "Stresssymptome (standardisiert)",
  ylab = "Neurotizismus (standardisiert)",
  pch = 19, col = rgb(1, 0, 0, 0.3)
)
abline(lm_sympt_neu_std, col = "blue", lwd = 2)
legend("topleft",
  legend = c(
    paste0(
      "β = ", round(coef(lm_sympt_neu_std)[2], 3),
      ifelse(cor_sympt_neu$p.value < 0.001, "***",
        ifelse(cor_sympt_neu$p.value < 0.01, "**",
          ifelse(cor_sympt_neu$p.value < 0.05, "*", "")
        )
      )
    ),
    paste0("R² = ", round(summary(lm_sympt_neu_std)$r.squared, 3))
  ),
  bty = "n"
)

# Mit Resilienz
lm_sympt_res_std <- lm(res_z ~ symptome_z)
plot(symptome_z, res_z,
  main = "Stresssymptome × Resilienz",
  xlab = "Stresssymptome (standardisiert)",
  ylab = "Resilienz (standardisiert)",
  pch = 19, col = rgb(0, 0.5, 0, 0.3)
)
abline(lm_sympt_res_std, col = "purple", lwd = 2)
legend("topright",
  legend = c(
    paste0(
      "β = ", round(coef(lm_sympt_res_std)[2], 3),
      ifelse(cor_sympt_res$p.value < 0.001, "***",
        ifelse(cor_sympt_res$p.value < 0.01, "**",
          ifelse(cor_sympt_res$p.value < 0.05, "*", "")
        )
      )
    ),
    paste0("R² = ", round(summary(lm_sympt_res_std)$r.squared, 3))
  ),
  bty = "n"
)

dev.off()

cat("✓ Validitäts-Plots für Stresssymptome gespeichert\n\n")


# ==============================================================================
# 6. VALIDITÄT: COPING-STRATEGIEN
# ==============================================================================

print_section("6. KONVERGENTE VALIDITÄT: COPING-STRATEGIEN", 2)

coping_vars <- c(
  "Coping_aktiv", "Coping_Drogen", "Coping_positiv",
  "Coping_sozial", "Coping_rel"
)
coping_labels <- c("Aktiv", "Drogen", "Positiv", "Sozial", "Religiös")
validitaets_vars <- c("Zufriedenheit", "Neurotizismus", "Resilienz")

# Korrelationsmatrix erstellen
cor_matrix <- matrix(NA, nrow = length(coping_vars), ncol = length(validitaets_vars))
rownames(cor_matrix) <- coping_labels
colnames(cor_matrix) <- validitaets_vars

for (i in seq_along(coping_vars)) {
  coping <- coping_vars[i]
  cat("###", gsub("_", " ", coping), "\n\n")
  for (j in seq_along(validitaets_vars)) {
    valid <- validitaets_vars[j]
    cor_result <- cor.test(data[[coping]], data[[valid]])
    cor_matrix[i, j] <- cor_result$estimate
    cat(
      "  mit", valid, ": r =", round(cor_result$estimate, 3),
      ", p =", format.pval(cor_result$p.value, digits = 3), "\n"
    )
  }
  cat("\n")
}

# VALIDITÄTS-PLOT: Coping-Strategien Korrelations-Heatmap
png(file.path(PLOTS_DIR, "15_validitaet_coping_heatmap.png"), width = 1400, height = 1000, res = 150)
par(mar = c(8, 10, 4, 6))

# Farbpalette erstellen
library(grDevices)
col_palette <- colorRampPalette(c("red", "white", "blue"))(100)

# Heatmap erstellen
image(seq_len(ncol(cor_matrix)), seq_len(nrow(cor_matrix)), t(cor_matrix),
  col = col_palette,
  xlab = "", ylab = "",
  axes = FALSE,
  main = "Korrelationen: Coping-Skalen × Validitätskriterien",
  zlim = c(-1, 1)
)

# Achsenbeschriftungen
axis(1, at = seq_len(ncol(cor_matrix)), labels = colnames(cor_matrix), las = 2)
axis(2, at = seq_len(nrow(cor_matrix)), labels = rownames(cor_matrix), las = 2)

# Korrelationswerte eintragen
for (i in seq_len(nrow(cor_matrix))) {
  for (j in seq_len(ncol(cor_matrix))) {
    text(j, i, round(cor_matrix[i, j], 2), cex = 1.2)
  }
}

# Legende
legend_breaks <- seq(-1, 1, length.out = 11)
legend("right",
  legend = sprintf("%.1f", legend_breaks),
  fill = col_palette[seq(1, 100, length.out = 11)],
  title = "Korrelation",
  bty = "n",
  xpd = TRUE,
  inset = c(-0.15, 0)
)

dev.off()

cat("✓ Validitäts-Plots für Coping-Strategien gespeichert\n\n")

# Zusätzliche Heatmap nur für NI07-Items
ni07_items <- c("NI07_05", "NI07_01", "NI07_04", "NI07_03", "NI07_02")
ni07_labels <- c("Aktiv", "Drogen", "Positiv", "Sozial", "Religiös")

# Korrelationsmatrix für NI07-Items erstellen
cor_matrix_ni07 <- matrix(NA, nrow = length(ni07_items), ncol = length(validitaets_vars))
rownames(cor_matrix_ni07) <- ni07_labels
colnames(cor_matrix_ni07) <- validitaets_vars

for (i in seq_along(ni07_items)) {
  for (j in seq_along(validitaets_vars)) {
    cor_result <- cor.test(data[[ni07_items[i]]], data[[validitaets_vars[j]]])
    cor_matrix_ni07[i, j] <- cor_result$estimate
  }
}

# VALIDITÄTS-PLOT: NI07 Single-Items Heatmap
png(file.path(PLOTS_DIR, "16_validitaet_ni07_items_heatmap.png"), width = 1400, height = 1000, res = 150)
par(mar = c(8, 10, 4, 6))

# Farbpalette
col_palette <- colorRampPalette(c("red", "white", "blue"))(100)

# Heatmap erstellen
image(seq_len(ncol(cor_matrix_ni07)), seq_len(nrow(cor_matrix_ni07)), t(cor_matrix_ni07),
  col = col_palette,
  xlab = "", ylab = "",
  axes = FALSE,
  main = "Korrelationen: Einzelitems Coping-Skalen × Validitätskriterien",
  zlim = c(-1, 1)
)

# Achsenbeschriftungen
axis(1, at = seq_len(ncol(cor_matrix_ni07)), labels = colnames(cor_matrix_ni07), las = 2)
axis(2, at = seq_len(nrow(cor_matrix_ni07)), labels = rownames(cor_matrix_ni07), las = 2)

# Korrelationswerte eintragen
for (i in seq_len(nrow(cor_matrix_ni07))) {
  for (j in seq_len(ncol(cor_matrix_ni07))) {
    text(j, i, round(cor_matrix_ni07[i, j], 2), cex = 1.2)
  }
}

# Legende
legend_breaks <- seq(-1, 1, length.out = 11)
legend("right",
  legend = sprintf("%.1f", legend_breaks),
  fill = col_palette[seq(1, 100, length.out = 11)],
  title = "Korrelation",
  bty = "n",
  xpd = TRUE,
  inset = c(-0.15, 0)
)

dev.off()

cat("✓ Zusätzliche Heatmap für NI07-Items gespeichert\n\n")

# ==============================================================================
# 7. KONFIRMATORISCHE FAKTORENANALYSE (CFA): 7-FAKTOREN-STRUKTUR
# ==============================================================================

print_section("7. KONFIRMATORISCHE FAKTORENANALYSE: 7-FAKTOREN-MODELL", 2)

cat("In diesem Abschnitt wird die theoretisch angenommene 7-Faktoren-Struktur\n")
cat("mittels CFA überprüft.\n\n")
cat("Erwartete Faktoren:\n")
cat("  1. Stressbelastung (5 Items - Kurzskala)\n")
cat("  2. Stresssymptome (5 Items - Kurzskala)\n")
cat("  3. Aktives Coping (4 Items)\n")
cat("  4. Drogen-Coping (5 Items)\n")
cat("  5. Positives Coping (4 Items)\n")
cat("  6. Soziales Coping (5 Items)\n")
cat("  7. Religiöses Coping (4 Items)\n\n")

# CFA-Modell spezifizieren
cfa_model <- "
  # Faktor 1: Stressbelastung (Kurzskala)
  Stress =~ NI06_01 + NI06_02 + NI06_03 + NI06_04 + NI06_05

  # Faktor 2: Stresssymptome (Kurzskala)
  Symptome =~ NI13_01 + NI13_02 + NI13_03 + NI13_04 + NI13_05

  # Faktor 3: Aktives Coping
  Aktiv =~ SO23_01 + SO23_20 + SO23_14 + NI07_05

  # Faktor 4: Drogen-Coping
  Drogen =~ NI07_01 + SO23_02 + SO23_07 + SO23_13 + SO23_17

  # Faktor 5: Positives Coping
  Positiv =~ SO23_11 + SO23_10 + SO23_15 + NI07_04

  # Faktor 6: Soziales Coping
  Sozial =~ NI07_03 + SO23_04 + SO23_05 + SO23_09 + SO23_18

  # Faktor 7: Religiöses Coping
  Religioes =~ NI07_02 + SO23_06 + SO23_12 + SO23_16
"

cat("### 7.1 CFA-Modell fitten\n\n")

# Modell fitten (mit robustem Schätzer für nicht-normalverteilte Daten)
fit_cfa <- cfa(cfa_model, data = data, estimator = "MLR")

# Modell-Zusammenfassung
cat("Modell-Zusammenfassung:\n\n")
summary(fit_cfa, fit.measures = TRUE, standardized = TRUE)

cat("\n### 7.2 Fit-Indices interpretieren\n\n")

# Fit-Indices extrahieren
fit_measures <- fitMeasures(fit_cfa, c(
  "chisq", "df", "pvalue", "cfi", "tli",
  "rmsea", "rmsea.ci.lower", "rmsea.ci.upper", "srmr"
))

cat(
  "Chi-Quadrat:       χ² =", round(fit_measures["chisq"], 2),
  ", df =", fit_measures["df"],
  ", p =", format.pval(fit_measures["pvalue"], digits = 3), "\n"
)
cat(
  "CFI:              ", round(fit_measures["cfi"], 3),
  ifelse(fit_measures["cfi"] >= 0.95, "(ausgezeichnet)",
    ifelse(fit_measures["cfi"] >= 0.90, "(akzeptabel)", "(problematisch)")
  ), "\n"
)
cat(
  "TLI:              ", round(fit_measures["tli"], 3),
  ifelse(fit_measures["tli"] >= 0.95, "(ausgezeichnet)",
    ifelse(fit_measures["tli"] >= 0.90, "(akzeptabel)", "(problematisch)")
  ), "\n"
)
cat("RMSEA:            ", round(fit_measures["rmsea"], 3),
  " [", round(fit_measures["rmsea.ci.lower"], 3), ", ",
  round(fit_measures["rmsea.ci.upper"], 3), "]",
  ifelse(fit_measures["rmsea"] <= 0.05, "(ausgezeichnet)",
    ifelse(fit_measures["rmsea"] <= 0.08, "(akzeptabel)", "(problematisch)")
  ), "\n",
  sep = ""
)
cat(
  "SRMR:             ", round(fit_measures["srmr"], 3),
  ifelse(fit_measures["srmr"] <= 0.05, "(ausgezeichnet)",
    ifelse(fit_measures["srmr"] <= 0.08, "(akzeptabel)", "(problematisch)")
  ), "\n\n"
)

cat("Interpretation der Fit-Indices:\n")
cat("  - CFI/TLI ≥ 0.95: ausgezeichneter Fit, ≥ 0.90: akzeptabel\n")
cat("  - RMSEA ≤ 0.05: ausgezeichneter Fit, ≤ 0.08: akzeptabel\n")
cat("  - SRMR ≤ 0.05: ausgezeichneter Fit, ≤ 0.08: akzeptabel\n\n")

# Fazit
overall_fit <- ifelse(
  fit_measures["cfi"] >= 0.90 & fit_measures["rmsea"] <= 0.08 & fit_measures["srmr"] <= 0.08,
  "akzeptabel bis gut", "verbesserungswürdig"
)

cat("Fazit:\n")
cat("  - Der Modellfit ist", overall_fit, "\n")
cat(
  "  - Die 7-Faktoren-Struktur wird",
  ifelse(overall_fit == "akzeptabel bis gut", "bestätigt", "nicht vollständig bestätigt"), "\n\n"
)

cat("### 7.3 Faktorladungen extrahieren\n\n")

# Standardisierte Faktorladungen
std_loadings <- standardizedSolution(fit_cfa)
std_loadings_factors <- std_loadings[std_loadings$op == "=~", ]

cat("Standardisierte Faktorladungen:\n\n")
print(std_loadings_factors[, c("lhs", "rhs", "est.std", "pvalue")], row.names = FALSE)

cat("\n")
cat("Interpretation:\n")
cat("  - Faktorladungen > 0.40 gelten als substanziell\n")
cat("  - Faktorladungen > 0.70 gelten als stark\n\n")

# Prüfen ob alle Ladungen substanziell sind
weak_loadings <- std_loadings_factors[std_loadings_factors$est.std < 0.40, ]
if (nrow(weak_loadings) > 0) {
  cat("⚠ Schwache Faktorladungen (< 0.40):\n")
  print(weak_loadings[, c("lhs", "rhs", "est.std")], row.names = FALSE)
  cat("\n")
} else {
  cat("✓ Alle Faktorladungen sind substanziell (≥ 0.40)\n\n")
}

cat("### 7.4 Faktor-Korrelationen\n\n")

# Faktor-Korrelationen extrahieren
factor_cors <- std_loadings[std_loadings$op == "~~" &
  std_loadings$lhs != std_loadings$rhs &
  std_loadings$lhs %in% c("Stress", "Symptome", "Aktiv", "Drogen", "Positiv", "Sozial", "Religioes"), ]

if (nrow(factor_cors) > 0) {
  cat("Korrelationen zwischen den Faktoren:\n\n")
  print(factor_cors[, c("lhs", "rhs", "est.std", "pvalue")], row.names = FALSE)
  cat("\n")
  cat("Interpretation:\n")
  cat("  - Moderate Korrelationen (0.30-0.70) zeigen verwandte aber distinkte Faktoren\n")
  cat("  - Hohe Korrelationen (> 0.85) deuten auf mangelnde Diskriminanz hin\n\n")

  # Prüfen auf zu hohe Korrelationen
  high_cors <- factor_cors[abs(factor_cors$est.std) > 0.85, ]
  if (nrow(high_cors) > 0) {
    cat("⚠ Sehr hohe Faktor-Korrelationen (> 0.85):\n")
    print(high_cors[, c("lhs", "rhs", "est.std")], row.names = FALSE)
    cat("  → Diese Faktoren sind möglicherweise nicht klar unterscheidbar\n\n")
  } else {
    cat("✓ Faktoren sind hinreichend distinkt (alle Korrelationen < 0.85)\n\n")
  }
}

cat("### 7.5 Reliabilität der Faktoren\n\n")

# Composite Reliability (CR) und Average Variance Extracted (AVE) berechnen
# CR = (Σλ)² / [(Σλ)² + Σθ]
# AVE = Σλ² / [Σλ² + Σθ]

factors <- c("Stress", "Symptome", "Aktiv", "Drogen", "Positiv", "Sozial", "Religioes")
reliability_results <- data.frame(
  Faktor = factors,
  CR = numeric(length(factors)),
  AVE = numeric(length(factors))
)

for (i in seq_along(factors)) {
  factor <- factors[i]

  # Ladungen für diesen Faktor
  loadings <- std_loadings_factors[std_loadings_factors$lhs == factor, "est.std"]

  # Fehlervarianzen
  errors <- 1 - loadings^2

  # CR berechnen
  sum_loadings <- sum(loadings)
  sum_errors <- sum(errors)
  cr <- sum_loadings^2 / (sum_loadings^2 + sum_errors)

  # AVE berechnen
  sum_loadings_sq <- sum(loadings^2)
  ave <- sum_loadings_sq / (sum_loadings_sq + sum_errors)

  reliability_results$CR[i] <- cr
  reliability_results$AVE[i] <- ave
}

cat("Composite Reliability (CR) und Average Variance Extracted (AVE):\n\n")
print(reliability_results, row.names = FALSE)
cat("\n")
cat("Interpretation:\n")
cat("  - CR > 0.70: gute Reliabilität\n")
cat("  - AVE > 0.50: ausreichende konvergente Validität\n")
cat("  - AVE > r²: diskriminante Validität gegeben\n\n")

# Fazit
poor_cr <- reliability_results[reliability_results$CR < 0.70, ]
poor_ave <- reliability_results[reliability_results$AVE < 0.50, ]

if (nrow(poor_cr) > 0) {
  cat("⚠ Faktoren mit niedriger Reliabilität (CR < 0.70):\n")
  print(poor_cr$Faktor)
  cat("\n")
}

if (nrow(poor_ave) > 0) {
  cat("⚠ Faktoren mit niedriger konvergenter Validität (AVE < 0.50):\n")
  print(poor_ave$Faktor)
  cat("\n")
}

if (nrow(poor_cr) == 0 && nrow(poor_ave) == 0) {
  cat("✓ Alle Faktoren zeigen gute Reliabilität und konvergente Validität\n\n")
}

cat("### 7.6 Visualisierung\n\n")

# ==============================================================================
# PLOT 1: Improved Factor Loading Heatmap
# ==============================================================================

cat("Erstelle Plot 1: Verbesserte Faktorladungen-Heatmap...\n")

png(file.path(PLOTS_DIR, "17_cfa_faktorladungen_heatmap.png"), width = 2000, height = 1400, res = 150)
par(mar = c(10, 12, 4, 14), xpd = TRUE)

# Erstelle Matrix: Items × Faktoren
items_per_factor <- list(
  Stress = c("NI06_01", "NI06_02", "NI06_03", "NI06_04", "NI06_05"),
  Symptome = c("NI13_01", "NI13_02", "NI13_03", "NI13_04", "NI13_05"),
  Aktiv = c("SO23_01", "SO23_20", "SO23_14", "NI07_05"),
  Drogen = c("NI07_01", "SO23_02", "SO23_07", "SO23_13", "SO23_17"),
  Positiv = c("SO23_11", "SO23_10", "SO23_15", "NI07_04"),
  Sozial = c("NI07_03", "SO23_04", "SO23_05", "SO23_09", "SO23_18"),
  Religioes = c("NI07_02", "SO23_06", "SO23_12", "SO23_16")
)

# Alle Items sammeln
all_items <- unlist(items_per_factor)
n_items <- length(all_items)
n_factors <- length(factors)

# Matrix erstellen (Items in Zeilen, Faktoren in Spalten)
loading_matrix <- matrix(NA, nrow = n_items, ncol = n_factors)
rownames(loading_matrix) <- all_items
colnames(loading_matrix) <- factors
pval_matrix <- matrix(NA, nrow = n_items, ncol = n_factors)

# Fülle Matrix
for (i in seq_along(all_items)) {
  item <- all_items[i]
  for (j in seq_along(factors)) {
    factor <- factors[j]
    match_row <- which(std_loadings_factors$lhs == factor & std_loadings_factors$rhs == item)
    if (length(match_row) > 0) {
      loading_matrix[i, j] <- std_loadings_factors$est.std[match_row]
      pval_matrix[i, j] <- std_loadings_factors$pvalue[match_row]
    }
  }
}

# Farbpalette: Weiß → Hellblau → Dunkelblau
col_palette <- colorRampPalette(c("white", "#C6DBEF", "#6BAED6", "#2171B5", "#08306B"))(100)

# Heatmap plotten
image(1:n_factors, 1:n_items, t(loading_matrix),
  col = col_palette, xlab = "", ylab = "", axes = FALSE,
  main = "CFA Faktorladungen (7-Faktoren-Modell)",
  zlim = c(0, 1)
)

# Achsen
axis(1, at = 1:n_factors, labels = colnames(loading_matrix), las = 2, cex.axis = 1.1)
axis(2, at = 1:n_items, labels = rownames(loading_matrix), las = 2, cex.axis = 0.9)

# Horizontale Gridlines für bessere Lesbarkeit (INNERHALB des Plots)
for (i in 1:n_items) {
  lines(c(0.5, n_factors + 0.5), c(i, i), col = "gray80", lwd = 0.5)
}

# Faktor-Gruppenseparatoren und Labels auf der rechten Seite
current_row <- 0
for (fac_name in names(items_per_factor)) {
  n_items_in_factor <- length(items_per_factor[[fac_name]])

  # Trennlinie NACH diesem Faktor (außer beim letzten) - INNERHALB des Plots
  if (current_row + n_items_in_factor < n_items) {
    separator_y <- current_row + n_items_in_factor + 0.5
    lines(c(0.5, n_factors + 0.5), c(separator_y, separator_y),
      col = "black", lwd = 2.5
    )
  }


  current_row <- current_row + n_items_in_factor
}

# Werte eintragen
for (i in 1:n_items) {
  for (j in 1:n_factors) {
    if (!is.na(loading_matrix[i, j])) {
      # Textfarbe basierend auf Hintergrund
      text_col <- ifelse(loading_matrix[i, j] > 0.5, "white", "black")

      # Signifikanzsterne
      sig_symbol <- ifelse(pval_matrix[i, j] < 0.001, "***",
        ifelse(pval_matrix[i, j] < 0.01, "**",
          ifelse(pval_matrix[i, j] < 0.05, "*", "")
        )
      )

      # Text
      text(j, i, sprintf("%.2f%s", loading_matrix[i, j], sig_symbol),
        col = text_col, cex = 0.9, font = 2
      )

      # Roter Rahmen für schwache Ladungen
      if (loading_matrix[i, j] < 0.40) {
        rect(j - 0.4, i - 0.4, j + 0.4, i + 0.4, border = "red", lwd = 3)
      }
    }
  }
}

# Legende
legend("topright",
  inset = c(-0.25, 0),
  legend = c("≥ 0.70 (stark)", "0.40-0.70 (substanziell)", "< 0.40 (schwach)"),
  fill = c("#08306B", "#6BAED6", "#C6DBEF"),
  title = "Ladungsstärke", bty = "n", cex = 0.9
)

dev.off()
cat("✓ Plot 17 gespeichert: Faktorladungen-Heatmap\n\n")

# ==============================================================================
# PLOT 2: CR & AVE Comparison Chart
# ==============================================================================

cat("Erstelle Plot 2: CR & AVE Vergleich...\n")

png(file.path(PLOTS_DIR, "18_cfa_reliabilität_vergleich.png"), width = 1600, height = 1000, res = 150)
par(mar = c(8, 5, 4, 2))

# Daten vorbereiten (sortiert nach CR)
reliability_sorted <- reliability_results[order(-reliability_results$CR), ]
n_fac <- nrow(reliability_sorted)

# Positionen für gruppierte Balken
x_pos <- 1:n_fac
bar_width <- 0.35

# Erstelle Plot
barplot_data <- rbind(reliability_sorted$CR, reliability_sorted$AVE)
bp <- barplot(barplot_data,
  beside = TRUE,
  names.arg = reliability_sorted$Faktor,
  col = c("#2171B5", "#FD8D3C"),
  ylim = c(0, 1),
  las = 2,
  ylab = "Wert",
  main = "Composite Reliability (CR) und Average Variance Extracted (AVE)",
  border = NA
)

# Referenzlinien
abline(h = 0.70, col = "darkgreen", lty = 2, lwd = 2)
abline(h = 0.50, col = "darkred", lty = 2, lwd = 2)

# Werte auf Balken
for (i in 1:n_fac) {
  text(bp[1, i], reliability_sorted$CR[i] + 0.03,
    sprintf("%.2f", reliability_sorted$CR[i]),
    cex = 0.9
  )
  text(bp[2, i], reliability_sorted$AVE[i] + 0.03,
    sprintf("%.2f", reliability_sorted$AVE[i]),
    cex = 0.9
  )
}

# Legende
legend("topright",
  legend = c(
    "CR (Composite Reliability)", "AVE (Average Variance Extracted)",
    "CR Schwelle (0.70)", "AVE Schwelle (0.50)"
  ),
  fill = c("#2171B5", "#FD8D3C", NA, NA),
  border = c("black", "black", NA, NA),
  lty = c(NA, NA, 2, 2),
  lwd = c(NA, NA, 2, 2),
  col = c(NA, NA, "darkgreen", "darkred"),
  bty = "n", cex = 0.9
)

dev.off()
cat("✓ Plot 18 gespeichert: CR & AVE Vergleich\n\n")

# ==============================================================================
# PLOT 3: Factor Correlation Network
# ==============================================================================

cat("Erstelle Plot 3: Faktor-Korrelations-Netzwerk...\n")

png(file.path(PLOTS_DIR, "19_cfa_faktor_netzwerk.png"), width = 1600, height = 1600, res = 150)
par(mar = c(2, 2, 4, 2))

# Erstelle Korrelationsmatrix aus factor_cors
cor_mat <- matrix(0, nrow = n_factors, ncol = n_factors)
rownames(cor_mat) <- factors
colnames(cor_mat) <- factors
diag(cor_mat) <- 1

for (i in 1:nrow(factor_cors)) {
  f1 <- as.character(factor_cors$lhs[i])
  f2 <- as.character(factor_cors$rhs[i])
  cor_val <- factor_cors$est.std[i]

  idx1 <- which(factors == f1)
  idx2 <- which(factors == f2)

  if (length(idx1) > 0 && length(idx2) > 0) {
    cor_mat[idx1, idx2] <- cor_val
    cor_mat[idx2, idx1] <- cor_val
  }
}

# Kreislayout für Faktoren
theta <- seq(0, 2 * pi, length.out = n_factors + 1)[1:n_factors]
x <- cos(theta)
y <- sin(theta)

# Plot erstellen
plot(x, y,
  type = "n", xlim = c(-1.5, 1.5), ylim = c(-1.5, 1.5),
  axes = FALSE, xlab = "", ylab = "",
  main = "Faktor-Korrelationen (7-Faktoren-Modell)"
)

# Verbindungslinien zeichnen (nur für |r| > 0.20)
for (i in 1:(n_factors - 1)) {
  for (j in (i + 1):n_factors) {
    cor_val <- cor_mat[i, j]
    if (abs(cor_val) > 0.20) {
      # Linienfarbe und -dicke basierend auf Korrelation
      if (cor_val > 0) {
        line_col <- rgb(0.18, 0.55, 0.20, alpha = abs(cor_val) * 0.8) # Grün für positiv
      } else {
        line_col <- rgb(0.83, 0.18, 0.18, alpha = abs(cor_val) * 0.8) # Rot für negativ
      }

      line_width <- 1 + abs(cor_val) * 4
      line_type <- ifelse(abs(cor_val) > 0.50, 1, 2)

      lines(c(x[i], x[j]), c(y[i], y[j]),
        col = line_col, lwd = line_width, lty = line_type
      )
    }
  }
}

# Knoten zeichnen (Größe basierend auf CR)
node_size <- 0.15 + (reliability_results$CR - min(reliability_results$CR)) * 0.15

# Farbpalette für Faktoren
# Rottöne für Belastung und Symptome, Blautöne für Coping-Skalen
factor_colors <- c(
  "#8B0000", # Stress (Belastung) - Dunkelrot
  "#DC143C", # Symptome - Crimson
  "#08306B", # Aktiv - Dunkelblau
  "#2171B5", # Drogen - Mittelblau
  "#4292C6", # Positiv - Helleres Blau
  "#6BAED6", # Sozial - Noch helleres Blau
  "#9ECAE1" # Religioes - Hellblau
)

# Labels für die Faktoren (Belastung statt Stress, Symptome abgekürzt)
factor_labels <- c("Belastung", "Symptome", "Aktiv", "Drogen", "Positiv", "Sozial", "Religioes")

for (i in 1:n_factors) {
  # Kreis zeichnen
  symbols(x[i], y[i],
    circles = node_size[i],
    inches = FALSE, add = TRUE,
    bg = factor_colors[i], fg = "black", lwd = 2
  )

  # Faktorname (mit angepassten Labels)
  text(x[i], y[i], factor_labels[i], cex = 0.9, font = 2, col = "white")

  # CR/AVE Werte außerhalb
  label_dist <- 1.3
  text(x[i] * label_dist, y[i] * label_dist,
    sprintf(
      "CR=%.2f\nAVE=%.2f",
      reliability_results$CR[i],
      reliability_results$AVE[i]
    ),
    cex = 0.7, col = "black"
  )
}

# Legende
legend("bottomright",
  legend = c(
    "Positive Korr. (r > 0)", "Negative Korr. (r < 0)",
    "Stark (|r| > 0.50)", "Moderat (|r| 0.20-0.50)"
  ),
  col = c(rgb(0.18, 0.55, 0.20, 0.8), rgb(0.83, 0.18, 0.18, 0.8), "black", "black"),
  lty = c(1, 1, 1, 2),
  lwd = c(3, 3, 3, 2),
  bty = "n", cex = 0.9
)

dev.off()
cat("✓ Plot 19 gespeichert: Faktor-Korrelations-Netzwerk\n\n")

cat("### 7.7 Fazit CFA\n\n")
cat("Die konfirmatorische Faktorenanalyse zeigt:\n")
cat("  - Modellfit:", overall_fit, "\n")
cat("  - Faktorladungen:", ifelse(nrow(weak_loadings) == 0, "alle substanziell", "teilweise schwach"), "\n")
cat(
  "  - Faktoren-Diskriminanz:",
  ifelse(nrow(high_cors) == 0, "gegeben", "teilweise problematisch"), "\n"
)
cat(
  "  - Reliabilität:",
  ifelse(nrow(poor_cr) == 0, "gut", "teilweise verbesserungswürdig"), "\n\n"
)

cat("✓ CFA abgeschlossen\n\n")


# ==============================================================================
# ZUSAMMENFASSUNG
# ==============================================================================

print_section("FERTIG")

cat("Alle Hauptvaliditätsanalysen wurden erfolgreich durchgeführt.\n\n")
cat("Plots gespeichert: 13-19\n")
cat("  - 13-16: Validitätskorrelationen\n")
cat("  - 17: CFA Faktorladungen-Heatmap\n")
cat("  - 18: CFA CR & AVE Vergleich\n")
cat("  - 19: CFA Faktor-Korrelations-Netzwerk\n\n")
cat("Führen Sie als nächstes aus: 05_validity_subgroups.R\n\n")
