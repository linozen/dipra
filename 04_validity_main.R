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
# WORKSPACE LADEN
# ==============================================================================

cat("Lade Workspace von 01_setup_and_scales.R...\n")
load("data/01_scales.RData")
cat("✓ Workspace geladen\n\n")

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
png("plots/13_validitaet_stress_korrelationen.png", width = 1800, height = 600, res = 150)
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
png("plots/14_validitaet_symptome_korrelationen.png", width = 1800, height = 600, res = 150)
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
png("plots/15_validitaet_coping_heatmap.png", width = 1400, height = 1000, res = 150)
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
png("plots/16_validitaet_ni07_items_heatmap.png", width = 1400, height = 1000, res = 150)
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
# ZUSAMMENFASSUNG
# ==============================================================================

print_section("FERTIG")

cat("Alle Hauptvaliditätsanalysen wurden erfolgreich durchgeführt.\n\n")
cat("Plots gespeichert: 13-16\n\n")
cat("Führen Sie als nächstes aus: 05_validity_subgroups.R\n\n")
