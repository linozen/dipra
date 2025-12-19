#!/usr/bin/env Rscript
# ==============================================================================
# FINALE SKALENMETRIKEN FÜR PUBLIKATION
# ==============================================================================
#
# Gibt alle relevanten psychometrischen Kennwerte für die finalen Kurzskalen aus:
# - Stressbelastung (kurz, 5 Items)
# - Stresssymptome (kurz, 5 Items)
# - Coping Items (NI07_01 bis NI07_05, je 1 Item)
#
# Berichtete Metriken:
# - Deskriptive Statistiken (N, M, SD, Min, Max, Schiefe, Kurtosis)
# - Reliabilität (Cronbach's Alpha für Multi-Item-Skalen)
# - Itemstatistiken (Trennschärfe, Schwierigkeit)
# - Validität (Korrelationen mit Außenkriterien)
# - Normierung (Normierungsstrategie)
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
  library(psych)
})

# ==============================================================================
# WORKSPACE LADEN
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

print_section("FINALE SKALENMETRIKEN FÜR PUBLIKATION")

cat("Dieser Bericht enthält alle relevanten psychometrischen Kennwerte\n")
cat("für die finalen Kurzskalen des Stress-Assessments.\n\n")

# ==============================================================================
# HILFSFUNKTIONEN
# ==============================================================================

# Funktion für Schiefe und Kurtosis
calc_skewness <- function(x) {
  x <- x[!is.na(x)]
  n <- length(x)
  m <- mean(x)
  s <- sd(x)
  skew <- (sum((x - m)^3) / n) / s^3
  return(skew)
}

calc_kurtosis <- function(x) {
  x <- x[!is.na(x)]
  n <- length(x)
  m <- mean(x)
  s <- sd(x)
  kurt <- (sum((x - m)^4) / n) / s^4 - 3
  return(kurt)
}

# ==============================================================================
# 1. STRESSBELASTUNG (KURZ)
# ==============================================================================

print_section("1. STRESSBELASTUNG (KURZSKALA)", 1)

cat("Items: NI06_01, NI06_02, NI06_03, NI06_04, NI06_05 (5 Items)\n\n")

# Items extrahieren
stress_items <- c("NI06_01", "NI06_02", "NI06_03", "NI06_04", "NI06_05")
stress_data <- data[, stress_items]

# Deskriptive Statistiken
cat("DESKRIPTIVE STATISTIKEN:\n")
cat(paste(rep("-", 80), collapse = ""), "\n")
n_valid <- sum(complete.cases(stress_data))
n_missing <- nrow(data) - n_valid
m <- mean(data$Stressbelastung_kurz, na.rm = TRUE)
sd_val <- sd(data$Stressbelastung_kurz, na.rm = TRUE)
min_val <- min(data$Stressbelastung_kurz, na.rm = TRUE)
max_val <- max(data$Stressbelastung_kurz, na.rm = TRUE)
skew <- calc_skewness(data$Stressbelastung_kurz)
kurt <- calc_kurtosis(data$Stressbelastung_kurz)

cat(sprintf("  N gültig:              %d\n", n_valid))
cat(sprintf("  N fehlend:             %d\n", n_missing))
cat(sprintf("  Mittelwert (M):        %.2f\n", m))
cat(sprintf("  Standardabweichung:    %.2f\n", sd_val))
cat(sprintf("  Minimum:               %.2f\n", min_val))
cat(sprintf("  Maximum:               %.2f\n", max_val))
cat(sprintf("  Range:                 %.2f\n", max_val - min_val))
cat(sprintf("  Schiefe:               %.2f\n", skew))
cat(sprintf("  Kurtosis:              %.2f\n\n", kurt))

# Reliabilität
cat("RELIABILITÄT:\n")
cat(paste(rep("-", 80), collapse = ""), "\n")
alpha_result <- psych::alpha(stress_data, check.keys = FALSE)
cat(sprintf("  Cronbach's Alpha:      %.3f\n", alpha_result$total$raw_alpha))
cat(sprintf("  Standardisiertes α:    %.3f\n", alpha_result$total$std.alpha))
cat(sprintf(
  "  95%% CI:                [%.3f, %.3f]\n\n",
  alpha_result$feldt$lower.ci,
  alpha_result$feldt$upper.ci
))

# Itemstatistiken
cat("ITEMSTATISTIKEN:\n")
cat(paste(rep("-", 80), collapse = ""), "\n")
cat(sprintf("  %-10s | %8s | %8s | %12s\n", "Item", "M", "SD", "Trennschärfe"))
cat(paste(rep("-", 80), collapse = ""), "\n")
for (i in 1:length(stress_items)) {
  item <- stress_items[i]
  item_m <- mean(data[[item]], na.rm = TRUE)
  item_sd <- sd(data[[item]], na.rm = TRUE)
  item_r <- alpha_result$item.stats$r.drop[i]
  cat(sprintf("  %-10s | %8.2f | %8.2f | %12.3f\n", item, item_m, item_sd, item_r))
}
cat("\n")

# Validität
cat("VALIDITÄT (Korrelationen mit Außenkriterien):\n")
cat(paste(rep("-", 80), collapse = ""), "\n")
cor_zufriedenheit <- cor.test(data$Stressbelastung_kurz, data$Zufriedenheit)
cor_neuro <- cor.test(data$Stressbelastung_kurz, data$Neurotizismus)
cor_resilienz <- cor.test(data$Stressbelastung_kurz, data$Resilienz)

cat(sprintf(
  "  Zufriedenheit:         r = %.3f, p %s\n",
  cor_zufriedenheit$estimate,
  format.pval(cor_zufriedenheit$p.value, digits = 3, eps = 0.001)
))
cat(sprintf(
  "  Neurotizismus:         r = %.3f, p %s\n",
  cor_neuro$estimate,
  format.pval(cor_neuro$p.value, digits = 3, eps = 0.001)
))
cat(sprintf(
  "  Resilienz:             r = %.3f, p %s\n\n",
  cor_resilienz$estimate,
  format.pval(cor_resilienz$p.value, digits = 3, eps = 0.001)
))

# Normierung
cat("NORMIERUNG:\n")
cat(paste(rep("-", 80), collapse = ""), "\n")
cat("  Strategie:             Altersspezifische Normen\n")
cat("  Gruppen:               Jung (<30), Mittel (30-45), Alt (>45)\n")
cat("  Hinweis:               Zusätzlich Beschäftigungsunterschiede beachten\n")
cat("  Normtabellen:          3 Tabellen (Plots 48-50)\n\n")

# ==============================================================================
# 2. STRESSSYMPTOME (KURZ)
# ==============================================================================

print_section("2. STRESSSYMPTOME (KURZSKALA)", 1)

cat("Items: NI13_01, NI13_02, NI13_03, NI13_04, NI13_05 (5 Items)\n\n")

# Items extrahieren
symptom_items <- c("NI13_01", "NI13_02", "NI13_03", "NI13_04", "NI13_05")
symptom_data <- data[, symptom_items]

# Deskriptive Statistiken
cat("DESKRIPTIVE STATISTIKEN:\n")
cat(paste(rep("-", 80), collapse = ""), "\n")
n_valid <- sum(complete.cases(symptom_data))
n_missing <- nrow(data) - n_valid
m <- mean(data$Stresssymptome_kurz, na.rm = TRUE)
sd_val <- sd(data$Stresssymptome_kurz, na.rm = TRUE)
min_val <- min(data$Stresssymptome_kurz, na.rm = TRUE)
max_val <- max(data$Stresssymptome_kurz, na.rm = TRUE)
skew <- calc_skewness(data$Stresssymptome_kurz)
kurt <- calc_kurtosis(data$Stresssymptome_kurz)

cat(sprintf("  N gültig:              %d\n", n_valid))
cat(sprintf("  N fehlend:             %d\n", n_missing))
cat(sprintf("  Mittelwert (M):        %.2f\n", m))
cat(sprintf("  Standardabweichung:    %.2f\n", sd_val))
cat(sprintf("  Minimum:               %.2f\n", min_val))
cat(sprintf("  Maximum:               %.2f\n", max_val))
cat(sprintf("  Range:                 %.2f\n", max_val - min_val))
cat(sprintf("  Schiefe:               %.2f\n", skew))
cat(sprintf("  Kurtosis:              %.2f\n\n", kurt))

# Reliabilität
cat("RELIABILITÄT:\n")
cat(paste(rep("-", 80), collapse = ""), "\n")
alpha_result <- psych::alpha(symptom_data, check.keys = FALSE)
cat(sprintf("  Cronbach's Alpha:      %.3f\n", alpha_result$total$raw_alpha))
cat(sprintf("  Standardisiertes α:    %.3f\n", alpha_result$total$std.alpha))
cat(sprintf(
  "  95%% CI:                [%.3f, %.3f]\n\n",
  alpha_result$feldt$lower.ci,
  alpha_result$feldt$upper.ci
))

# Itemstatistiken
cat("ITEMSTATISTIKEN:\n")
cat(paste(rep("-", 80), collapse = ""), "\n")
cat(sprintf("  %-10s | %8s | %8s | %12s\n", "Item", "M", "SD", "Trennschärfe"))
cat(paste(rep("-", 80), collapse = ""), "\n")
for (i in 1:length(symptom_items)) {
  item <- symptom_items[i]
  item_m <- mean(data[[item]], na.rm = TRUE)
  item_sd <- sd(data[[item]], na.rm = TRUE)
  item_r <- alpha_result$item.stats$r.drop[i]
  cat(sprintf("  %-10s | %8.2f | %8.2f | %12.3f\n", item, item_m, item_sd, item_r))
}
cat("\n")

# Validität
cat("VALIDITÄT (Korrelationen mit Außenkriterien):\n")
cat(paste(rep("-", 80), collapse = ""), "\n")
cor_zufriedenheit <- cor.test(data$Stresssymptome_kurz, data$Zufriedenheit)
cor_neuro <- cor.test(data$Stresssymptome_kurz, data$Neurotizismus)
cor_resilienz <- cor.test(data$Stresssymptome_kurz, data$Resilienz)

cat(sprintf(
  "  Zufriedenheit:         r = %.3f, p %s\n",
  cor_zufriedenheit$estimate,
  format.pval(cor_zufriedenheit$p.value, digits = 3, eps = 0.001)
))
cat(sprintf(
  "  Neurotizismus:         r = %.3f, p %s\n",
  cor_neuro$estimate,
  format.pval(cor_neuro$p.value, digits = 3, eps = 0.001)
))
cat(sprintf(
  "  Resilienz:             r = %.3f, p %s\n\n",
  cor_resilienz$estimate,
  format.pval(cor_resilienz$p.value, digits = 3, eps = 0.001)
))

# Normierung
cat("NORMIERUNG:\n")
cat(paste(rep("-", 80), collapse = ""), "\n")
cat("  Strategie:             Gemeinsame Norm\n")
cat("  Gruppen:               Gesamte Stichprobe\n")
cat("  Begründung:            Keine signifikanten Gruppenunterschiede\n")
cat("  Normtabellen:          1 Tabelle (Plot 41)\n\n")

# ==============================================================================
# 3. COPING ITEMS (EINZELITEMS)
# ==============================================================================

print_section("3. COPING-ITEMS (EINZELITEMS)", 1)

coping_items <- c("NI07_01", "NI07_02", "NI07_03", "NI07_04", "NI07_05")
coping_labels <- c(
  "Drogen/Substanzen",
  "Religion/Spiritualität",
  "Soziale Unterstützung",
  "Positive Neubewertung",
  "Aktive Bewältigung"
)
coping_norms <- c(
  "Gemeinsame Norm (Plot 42)",
  "Gemeinsame Norm (Plot 43)",
  "Gemeinsame Norm (Plot 44)",
  "Gemeinsame Norm (Plot 45)",
  "Geschlechtsspezifisch (Plots 46-47)"
)

for (i in 1:length(coping_items)) {
  item <- coping_items[i]
  label <- coping_labels[i]
  norm <- coping_norms[i]

  print_section(sprintf("3.%d Coping: %s (%s)", i, label, item), 2)

  # Deskriptive Statistiken
  cat("DESKRIPTIVE STATISTIKEN:\n")
  cat(paste(rep("-", 80), collapse = ""), "\n")

  item_data <- data[[item]]
  n_valid <- sum(!is.na(item_data))
  n_missing <- sum(is.na(item_data))
  m <- mean(item_data, na.rm = TRUE)
  sd_val <- sd(item_data, na.rm = TRUE)
  min_val <- min(item_data, na.rm = TRUE)
  max_val <- max(item_data, na.rm = TRUE)
  skew <- calc_skewness(item_data)
  kurt <- calc_kurtosis(item_data)

  cat(sprintf("  N gültig:              %d\n", n_valid))
  cat(sprintf("  N fehlend:             %d\n", n_missing))
  cat(sprintf("  Mittelwert (M):        %.2f\n", m))
  cat(sprintf("  Standardabweichung:    %.2f\n", sd_val))
  cat(sprintf("  Minimum:               %.0f\n", min_val))
  cat(sprintf("  Maximum:               %.0f\n", max_val))
  cat(sprintf("  Range:                 %.0f\n", max_val - min_val))
  cat(sprintf("  Schiefe:               %.2f\n", skew))
  cat(sprintf("  Kurtosis:              %.2f\n\n", kurt))

  # Reliabilität (nicht anwendbar für Einzelitems)
  cat("RELIABILITÄT:\n")
  cat(paste(rep("-", 80), collapse = ""), "\n")
  cat("  Nicht anwendbar:       Einzelitem (keine interne Konsistenz)\n")
  cat("  Empfehlung:            Test-Retest-Reliabilität in Folgestudie prüfen\n\n")

  # Validität
  cat("VALIDITÄT (Korrelationen mit Außenkriterien):\n")
  cat(paste(rep("-", 80), collapse = ""), "\n")
  cor_zufriedenheit <- cor.test(item_data, data$Zufriedenheit)
  cor_neuro <- cor.test(item_data, data$Neurotizismus)
  cor_resilienz <- cor.test(item_data, data$Resilienz)
  cor_stress <- cor.test(item_data, data$Stressbelastung_kurz)
  cor_symptom <- cor.test(item_data, data$Stresssymptome_kurz)

  cat(sprintf(
    "  Zufriedenheit:         r = %.3f, p %s\n",
    cor_zufriedenheit$estimate,
    format.pval(cor_zufriedenheit$p.value, digits = 3, eps = 0.001)
  ))
  cat(sprintf(
    "  Neurotizismus:         r = %.3f, p %s\n",
    cor_neuro$estimate,
    format.pval(cor_neuro$p.value, digits = 3, eps = 0.001)
  ))
  cat(sprintf(
    "  Resilienz:             r = %.3f, p %s\n",
    cor_resilienz$estimate,
    format.pval(cor_resilienz$p.value, digits = 3, eps = 0.001)
  ))
  cat(sprintf(
    "  Stressbelastung:       r = %.3f, p %s\n",
    cor_stress$estimate,
    format.pval(cor_stress$p.value, digits = 3, eps = 0.001)
  ))
  cat(sprintf(
    "  Stresssymptome:        r = %.3f, p %s\n\n",
    cor_symptom$estimate,
    format.pval(cor_symptom$p.value, digits = 3, eps = 0.001)
  ))

  # Normierung
  cat("NORMIERUNG:\n")
  cat(paste(rep("-", 80), collapse = ""), "\n")
  cat(sprintf("  Strategie:             %s\n", norm))
  if (i == 5) {
    cat("  Begründung:            Signifikante Geschlechtsunterschiede\n")
  } else {
    cat("  Begründung:            Keine signifikanten Gruppenunterschiede\n")
  }
  cat("\n")
}

# ==============================================================================
# GESAMTZUSAMMENFASSUNG
# ==============================================================================

print_section("GESAMTZUSAMMENFASSUNG", 1)

cat("ÜBERSICHT DER FINALEN SKALEN:\n")
cat(paste(rep("=", 80), collapse = ""), "\n\n")

cat("1. STRESSBELASTUNG (KURZ)\n")
cat("   - Items:               5\n")
cat("   - Cronbach's Alpha:    ", sprintf(
  "%.3f\n",
  psych::alpha(data[, stress_items], check.keys = FALSE)$total$raw_alpha
))
cat("   - Normierung:          Altersspezifisch (3 Gruppen)\n\n")

cat("2. STRESSSYMPTOME (KURZ)\n")
cat("   - Items:               5\n")
cat("   - Cronbach's Alpha:    ", sprintf(
  "%.3f\n",
  psych::alpha(data[, symptom_items], check.keys = FALSE)$total$raw_alpha
))
cat("   - Normierung:          Gemeinsam\n\n")

cat("3. COPING-ITEMS (EINZELITEMS)\n")
cat("   - Items:               5 (je 1 pro Dimension)\n")
cat("   - Reliabilität:        Einzelitems (keine interne Konsistenz)\n")
cat("   - Normierung:          4× Gemeinsam, 1× Geschlechtsspezifisch\n\n")

cat("GESAMTTEST:\n")
cat("   - Anzahl Items:        15 (5 + 5 + 5)\n")
cat("   - Bearbeitungszeit:    ca. 5-10 Minuten (geschätzt)\n")
cat("   - Normtabellen:        10 Tabellen\n")
cat("   - Einsatzbereich:      Erwachsene (≥18 Jahre)\n\n")

cat("STÄRKEN:\n")
cat("   ✓ Ökonomisch (nur 15 Items)\n")
cat("   ✓ Gute Reliabilität der Multi-Item-Skalen (α > .70)\n")
cat("   ✓ Differenzierte Normierung nach empirischen Befunden\n")
cat("   ✓ Breite Validitätsevidenz (Korrelationen mit Außenkriterien)\n")
cat("   ✓ Erfassung mehrerer Stress-Dimensionen\n\n")

cat("LIMITATIONEN:\n")
cat("   ⚠ Coping-Items als Einzelitems (keine interne Konsistenz prüfbar)\n")
cat("   ⚠ Querschnittsdaten (keine Test-Retest-Reliabilität)\n")
cat("   ⚠ Convenience Sample (eingeschränkte Generalisierbarkeit)\n\n")

cat("EMPFEHLUNGEN FÜR ZUKÜNFTIGE FORSCHUNG:\n")
cat("   → Test-Retest-Reliabilität erheben\n")
cat("   → Coping-Items zu Multi-Item-Skalen erweitern\n")
cat("   → Normierung an repräsentativer Stichprobe\n")
cat("   → Konstruktvalidität mit CFA weiter prüfen\n")
cat("   → Sensitivität für Veränderungsmessung untersuchen\n\n")

cat("✓ Finale Skalenmetriken-Analyse abgeschlossen\n\n")

cat("VERWENDUNG:\n")
cat("  - Nutzen Sie diesen Bericht für Ihren Methodenteil\n")
cat("  - Alle Kennwerte sind publikationsreif formatiert\n")
cat("  - Ergänzen Sie ggf. Interpretationen und Schlussfolgerungen\n")
cat("  - Alle Ergebnisse sind im Haupt-Analyse-Log enthalten\n\n")
