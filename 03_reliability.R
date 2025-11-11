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
# Plots: 06-12
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
png("plots/06_reliabilitaet_stress_itemstatistik.png", width = 1600, height = 800, res = 150)
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
png("plots/07_reliabilitaet_stress_verteilung.png", width = 1600, height = 600, res = 150)
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
png("plots/08_reliabilitaet_symptome_itemstatistik.png", width = 1600, height = 800, res = 150)
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
png("plots/09_reliabilitaet_symptome_verteilung.png", width = 1600, height = 600, res = 150)
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
png("plots/10_reliabilitaet_alle_alphas.png", width = 1600, height = 900, res = 150)
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
png("plots/11_reliabilitaet_coping_itemstatistiken.png", width = 2000, height = 1200, res = 150)
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
png("plots/12_reliabilitaet_coping_verteilungen.png", width = 1600, height = 1000, res = 150)
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

# ==============================================================================
# ZUSAMMENFASSUNG
# ==============================================================================

print_section("FERTIG")

cat("Alle Reliabilitätsanalysen wurden erfolgreich durchgeführt.\n\n")
cat("Plots gespeichert: 06-12\n\n")
cat("Führen Sie als nächstes aus: 04_validity_main.R\n\n")
