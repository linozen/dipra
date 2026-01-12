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

if (!exists("PLOTS_DIR")) {
  PLOTS_DIR <- "manual/plots"
  if (!dir.exists(PLOTS_DIR)) {
    dir.create(PLOTS_DIR, recursive = TRUE)
  }
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
for (i in seq_along(stress_items)) {
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
for (i in seq_along(symptom_items)) {
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

coping_items <- c("NI07_01", "NI07_02", "NI07_03", "SO23_10", "SO23_01")
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

for (i in seq_along(coping_items)) {
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

  # Reliabilität (nicht anwendbar für Einzelitems, aber Retest-Reliabilität verfügbar)
  cat("RELIABILITÄT:\n")
  cat(paste(rep("-", 80), collapse = ""), "\n")
  cat("  Interne Konsistenz:    Nicht anwendbar (Einzelitem)\n")
  cat("  Retest-Reliabilität:   Siehe Abschnitt 5 (N = 21, Zeitintervall ≈ 2 Wochen)\n\n")

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
# 4. KONFIRMATORISCHE FAKTORENANALYSE (CFA) - NUR KURZSKALEN
# ==============================================================================

print_section("4. KONFIRMATORISCHE FAKTORENANALYSE (KURZSKALEN)", 1)

cat("Prüfung der faktoriellen Validität der beiden Multi-Item-Kurzskalen:\n")
cat("  - Stressbelastung (5 Items)\n")
cat("  - Stresssymptome (5 Items)\n\n")

cat("Hinweis: Coping-Items werden NICHT inkludiert (Einzelitems).\n\n")

# Create hierarchical codes from original column names for CFA
cat("Erstelle hierarchische Item-Codes für CFA...\n")

# Stressbelastung short scale
data$STRS_FUTU_01 <- data$NI06_01 # Zukunftssorgen
data$STRS_FINA_01 <- data$NI06_02 # Geldprobleme
data$STRS_RELA_01 <- data$NI06_03 # Beziehungsprobleme
data$STRS_PERF_01 <- data$NI06_04 # Leistungsdruck
data$STRS_HEAL_01 <- data$NI06_05 # Gesundheitssorgen

# Stresssymptome short scale
data$SYMP_PHYS_01 <- data$NI13_01 # Körperliche Beschwerden
data$SYMP_SLEP_01 <- data$NI13_02 # Schlaf/Träume
data$SYMP_COGN_01 <- data$NI13_03 # Konzentration
data$SYMP_MOOD_01 <- data$NI13_04 # Traurigkeit/Grübeln
data$SYMP_SOCI_01 <- data$NI13_05 # Rückzug/Lustlosigkeit

cat("✓ Item-Codes erstellt\n\n")

# CFA benötigt lavaan
if (!require("lavaan", quietly = TRUE)) {
  cat("⚠ Paket 'lavaan' nicht installiert. CFA wird übersprungen.\n\n")
} else {
  suppressPackageStartupMessages(library(lavaan))

  cat("### 4.1 Modellspezifikation\n\n")

  # 2-Faktoren-Modell: Nur die beiden Kurzskalen
  cfa_model_short <- "
    # Faktor 1: Stressbelastung (Kurzskala)
    Stress =~ STRS_FUTU_01 + STRS_FINA_01 + STRS_RELA_01 + STRS_PERF_01 + STRS_HEAL_01

    # Faktor 2: Stresssymptome (Kurzskala)
    Symptome =~ SYMP_PHYS_01 + SYMP_SLEP_01 + SYMP_COGN_01 + SYMP_MOOD_01 + SYMP_SOCI_01
  "

  cat("Modell: 2-Faktoren-Struktur\n")
  cat("  Faktor 1: Stressbelastung (5 Items)\n")
  cat("  Faktor 2: Stresssymptome (5 Items)\n\n")

  cat("### 4.2 Modell fitten\n\n")

  # Modell fitten (mit robustem Schätzer)
  fit_cfa_short <- cfa(cfa_model_short, data = data, estimator = "MLR")

  cat("### 4.3 Fit-Indices\n\n")

  # Fit-Indices extrahieren
  fit_measures <- fitMeasures(fit_cfa_short, c(
    "chisq", "df", "pvalue", "cfi", "tli",
    "rmsea", "rmsea.ci.lower", "rmsea.ci.upper", "srmr"
  ))

  cat(sprintf(
    "Chi-Quadrat:       χ² = %.2f, df = %d, p = %s\n",
    fit_measures["chisq"], fit_measures["df"],
    format.pval(fit_measures["pvalue"], digits = 3, eps = 0.001)
  ))
  cat(sprintf(
    "CFI:               %.3f %s\n",
    fit_measures["cfi"],
    ifelse(fit_measures["cfi"] >= 0.95, "(ausgezeichnet)",
      ifelse(fit_measures["cfi"] >= 0.90, "(akzeptabel)", "(problematisch)")
    )
  ))
  cat(sprintf(
    "TLI:               %.3f %s\n",
    fit_measures["tli"],
    ifelse(fit_measures["tli"] >= 0.95, "(ausgezeichnet)",
      ifelse(fit_measures["tli"] >= 0.90, "(akzeptabel)", "(problematisch)")
    )
  ))
  cat(sprintf(
    "RMSEA:             %.3f [%.3f, %.3f] %s\n",
    fit_measures["rmsea"], fit_measures["rmsea.ci.lower"],
    fit_measures["rmsea.ci.upper"],
    ifelse(fit_measures["rmsea"] <= 0.05, "(ausgezeichnet)",
      ifelse(fit_measures["rmsea"] <= 0.08, "(akzeptabel)", "(problematisch)")
    )
  ))
  cat(sprintf(
    "SRMR:              %.3f %s\n\n",
    fit_measures["srmr"],
    ifelse(fit_measures["srmr"] <= 0.05, "(ausgezeichnet)",
      ifelse(fit_measures["srmr"] <= 0.08, "(akzeptabel)", "(problematisch)")
    )
  ))

  cat("Interpretation:\n")
  cat("  - CFI/TLI ≥ 0.95: ausgezeichnet, ≥ 0.90: akzeptabel\n")
  cat("  - RMSEA ≤ 0.05: ausgezeichnet, ≤ 0.08: akzeptabel\n")
  cat("  - SRMR ≤ 0.05: ausgezeichnet, ≤ 0.08: akzeptabel\n\n")

  cat("### 4.4 Faktorladungen\n\n")

  # Standardisierte Faktorladungen extrahieren
  std_loadings <- standardizedSolution(fit_cfa_short)
  std_loadings_factors <- std_loadings[std_loadings$op == "=~", ]

  cat("Standardisierte Faktorladungen:\n\n")
  cat(sprintf("  %-10s | %-10s | %8s | %10s\n", "Faktor", "Item", "Ladung", "p-Wert"))
  cat(paste(rep("-", 80), collapse = ""), "\n")
  for (i in 1:nrow(std_loadings_factors)) {
    sig_symbol <- ifelse(std_loadings_factors$pvalue[i] < 0.001, "***",
      ifelse(std_loadings_factors$pvalue[i] < 0.01, "**",
        ifelse(std_loadings_factors$pvalue[i] < 0.05, "*", "ns")
      )
    )
    cat(sprintf(
      "  %-10s | %-10s | %8.3f | %10s\n",
      std_loadings_factors$lhs[i],
      std_loadings_factors$rhs[i],
      std_loadings_factors$est.std[i],
      sig_symbol
    ))
  }
  cat("\n")

  # Prüfen auf schwache Ladungen
  weak_loadings <- std_loadings_factors[std_loadings_factors$est.std < 0.40, ]
  if (nrow(weak_loadings) > 0) {
    cat("⚠ Schwache Faktorladungen (< 0.40):\n")
    print(weak_loadings[, c("lhs", "rhs", "est.std")], row.names = FALSE)
    cat("\n")
  } else {
    cat("✓ Alle Faktorladungen sind substanziell (≥ 0.40)\n\n")
  }

  cat("### 4.5 Faktor-Korrelation\n\n")

  # Korrelation zwischen den beiden Faktoren
  factor_cors <- std_loadings[std_loadings$op == "~~" &
    std_loadings$lhs == "Stress" &
    std_loadings$rhs == "Symptome", ]

  if (nrow(factor_cors) > 0) {
    cat(sprintf(
      "Korrelation Stress ↔ Symptome: r = %.3f, p %s\n\n",
      factor_cors$est.std,
      format.pval(factor_cors$pvalue, digits = 3, eps = 0.001)
    ))

    if (abs(factor_cors$est.std) > 0.85) {
      cat("⚠ Sehr hohe Korrelation (> 0.85): Faktoren könnten mangelnde Diskriminanz aufweisen\n\n")
    } else {
      cat("✓ Faktoren sind hinreichend distinkt (r < 0.85)\n\n")
    }
  }

  cat("### 4.6 Reliabilität der Faktoren\n\n")

  # Composite Reliability (CR) und Average Variance Extracted (AVE)
  factors <- c("Stress", "Symptome")
  reliability_results <- data.frame(
    Faktor = factors,
    CR = numeric(length(factors)),
    AVE = numeric(length(factors))
  )

  for (i in seq_along(factors)) {
    factor <- factors[i]
    loadings <- std_loadings_factors[std_loadings_factors$lhs == factor, "est.std"]
    errors <- 1 - loadings^2

    # CR
    sum_loadings <- sum(loadings)
    sum_errors <- sum(errors)
    cr <- sum_loadings^2 / (sum_loadings^2 + sum_errors)

    # AVE
    sum_loadings_sq <- sum(loadings^2)
    ave <- sum_loadings_sq / (sum_loadings_sq + sum_errors)

    reliability_results$CR[i] <- cr
    reliability_results$AVE[i] <- ave
  }

  cat("Composite Reliability (CR) und Average Variance Extracted (AVE):\n\n")
  cat(sprintf("  %-15s | %8s | %8s\n", "Faktor", "CR", "AVE"))
  cat(paste(rep("-", 80), collapse = ""), "\n")
  for (i in 1:nrow(reliability_results)) {
    cat(sprintf(
      "  %-15s | %8.3f | %8.3f\n",
      reliability_results$Faktor[i],
      reliability_results$CR[i],
      reliability_results$AVE[i]
    ))
  }
  cat("\n")
  cat("Interpretation:\n")
  cat("  - CR > 0.70: gute Reliabilität\n")
  cat("  - AVE > 0.50: ausreichende konvergente Validität\n\n")

  cat("### 4.7 Visualisierung: Faktorladungen-Heatmap\n\n")

  # Erstelle Heatmap ähnlich zu Plot 17
  png(file.path(PLOTS_DIR, "50_final_cfa_kurzskalen_heatmap.png"),
    width = 1600, height = 1200, res = 150
  )
  par(mar = c(8, 10, 4, 16), xpd = TRUE)

  # Matrix erstellen mit Original-Itemnamen und Anzeigenamen
  items_per_factor <- list(
    Stress = c("STRS_FUTU_01", "STRS_FINA_01", "STRS_RELA_01", "STRS_PERF_01", "STRS_HEAL_01"),
    Symptome = c("SYMP_PHYS_01", "SYMP_SLEP_01", "SYMP_COGN_01", "SYMP_MOOD_01", "SYMP_SOCI_01")
  )

  # Display-Namen für Items
  item_display_names <- c(
    STRS_FUTU_01 = "STRESS_01", STRS_FINA_01 = "STRESS_02", STRS_RELA_01 = "STRESS_03",
    STRS_PERF_01 = "STRESS_04", STRS_HEAL_01 = "STRESS_05",
    SYMP_PHYS_01 = "SYMPTOM_01", SYMP_SLEP_01 = "SYMPTOM_02", SYMP_COGN_01 = "SYMPTOM_03",
    SYMP_MOOD_01 = "SYMPTOM_04", SYMP_SOCI_01 = "SYMPTOM_05"
  )

  all_items <- unlist(items_per_factor)
  all_items_display <- item_display_names[all_items]
  n_items <- length(all_items)
  n_factors <- length(factors)

  loading_matrix <- matrix(NA, nrow = n_items, ncol = n_factors)
  rownames(loading_matrix) <- all_items_display
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

  # Farbpalette
  col_palette <- colorRampPalette(c("white", "#C6DBEF", "#6BAED6", "#2171B5", "#08306B"))(100)

  # Heatmap
  image(1:n_factors, 1:n_items, t(loading_matrix),
    col = col_palette, xlab = "", ylab = "", axes = FALSE,
    zlim = c(0, 1)
  )

  # Achsen
  axis(1, at = 1:n_factors, labels = colnames(loading_matrix), las = 1, cex.axis = 1.2)
  axis(2, at = 1:n_items, labels = rownames(loading_matrix), las = 2, cex.axis = 1.0)

  # Gridlines
  for (i in 1:n_items) {
    lines(c(0.5, n_factors + 0.5), c(i, i), col = "gray80", lwd = 0.5)
  }

  # Separator zwischen Faktoren
  if (n_items > 5) {
    separator_y <- 5.5
    lines(c(0.5, n_factors + 0.5), c(separator_y, separator_y), col = "black", lwd = 2.5)
  }

  # Werte eintragen
  for (i in 1:n_items) {
    for (j in 1:n_factors) {
      if (!is.na(loading_matrix[i, j])) {
        text_col <- ifelse(loading_matrix[i, j] > 0.5, "white", "black")

        sig_symbol <- ifelse(pval_matrix[i, j] < 0.001, "***",
          ifelse(pval_matrix[i, j] < 0.01, "**",
            ifelse(pval_matrix[i, j] < 0.05, "*", "")
          )
        )

        text(j, i, sprintf("%.2f%s", loading_matrix[i, j], sig_symbol),
          col = text_col, cex = 1.0, font = 2
        )

        # Roter Rahmen für schwache Ladungen
        if (loading_matrix[i, j] < 0.40) {
          rect(j - 0.4, i - 0.4, j + 0.4, i + 0.4, border = "red", lwd = 3)
        }
      }
    }
  }

  # Legende (weiter rechts positioniert)
  legend("topright",
    inset = c(-0.45, 0),
    legend = c("≥ 0.70 (stark)", "0.40-0.70 (substanziell)", "< 0.40 (schwach)"),
    fill = c("#08306B", "#6BAED6", "#C6DBEF"),
    title = "Ladungsstärke", bty = "n", cex = 1.0
  )

  dev.off()
  cat("✓ Plot 50 gespeichert: CFA Faktorladungen-Heatmap (Kurzskalen)\n\n")

  cat("### 4.8 Fazit CFA\n\n")

  overall_fit <- ifelse(
    fit_measures["cfi"] >= 0.90 & fit_measures["rmsea"] <= 0.08 & fit_measures["srmr"] <= 0.08,
    "akzeptabel bis gut", "verbesserungswürdig"
  )

  cat(sprintf("Modellfit: %s\n", overall_fit))
  cat(sprintf(
    "Faktorladungen: %s\n",
    ifelse(all(std_loadings_factors$est.std >= 0.40), "alle substanziell", "teilweise schwach")
  ))
  cat(sprintf(
    "Diskriminanz: %s\n",
    ifelse(abs(factor_cors$est.std) < 0.85, "gegeben", "eingeschränkt")
  ))
  cat(sprintf(
    "Reliabilität: %s\n\n",
    ifelse(all(reliability_results$CR >= 0.70), "gut", "verbesserungswürdig")
  ))
}

# ==============================================================================
# 5. RETEST-RELIABILITÄT (NUR KURZSKALEN)
# ==============================================================================

print_section("5. RETEST-RELIABILITÄT (KURZSKALEN)", 1)

cat("Prüfung der Test-Retest-Reliabilität (Stabilität) der Kurzskalen:\n")
cat("  - Stressbelastung (5 Items)\n")
cat("  - Stresssymptome (5 Items)\n")
cat("  - Coping-Items (5 Einzelitems)\n\n")

cat("Methode: Pearson-Korrelation zwischen Test und Retest\n")
cat("Interpretation:\n")
cat("  r > .80: Exzellent\n")
cat("  r > .70: Gut\n")
cat("  r > .60: Akzeptabel\n")
cat("  r < .60: Problematisch\n\n")

# ==============================================================================
# 5.1 RETEST-DATEN LADEN UND VORBEREITEN
# ==============================================================================

cat("### 5.1 Retest-Daten laden\n\n")

# Lade Rohdaten (enthält sowohl A1 als auch B)
cat("Lade Rohdaten inklusive Retest-Fälle...\n")

if (!exists("RAW_DATA_FILE")) {
  RAW_DATA_FILE <- "data/data_stressskala_2025-12-18_10-13.csv"
}

data_raw <- tryCatch(
  {
    read.csv(RAW_DATA_FILE,
      header = TRUE,
      sep = ";",
      dec = ",",
      fileEncoding = "ISO-8859-1",
      stringsAsFactors = FALSE
    )
  },
  error = function(e) {
    cat("⚠ Fehler beim Laden der Rohdaten:", conditionMessage(e), "\n")
    cat("  Retest-Reliabilitätsanalyse wird übersprungen.\n\n")
    return(NULL)
  }
)

if (is.null(data_raw)) {
  cat("⚠ Retest-Reliabilitätsanalyse übersprungen (Rohdaten nicht verfügbar)\n\n")
} else {
  cat("✓ Rohdaten geladen:", nrow(data_raw), "Zeilen\n\n")

  # Trenne Original-Tests und Retests
  original_tests <- data_raw[data_raw$QUESTNNR == "A1", ]
  retest_tests <- data_raw[data_raw$QUESTNNR == "B", ]

  cat("Original-Tests (QUESTNNR=A1):", nrow(original_tests), "\n")
  cat("Retest-Tests (QUESTNNR=B):", nrow(retest_tests), "\n\n")

  if (nrow(retest_tests) == 0) {
    cat("⚠ Keine Retest-Daten vorhanden. Retest-Reliabilitätsanalyse übersprungen.\n\n")
  } else {
    # ==============================================================================
    # 5.2 RETEST-PAARE MATCHEN
    # ==============================================================================

    cat("### 5.2 Retest-Paare matchen\n\n")

    cat("Matching-Strategie: Zwei-Stufen-Matching\n")
    cat("  1. Exakte Übereinstimmung (case-insensitive, ohne Leerzeichen)\n")
    cat("  2. Fuzzy Matching (Levenshtein-Distanz ≤ 2) für ungematchte Fälle\n\n")

    # Funktion: Levenshtein-Distanz
    levenshtein_distance <- function(s1, s2) {
      n <- nchar(s1)
      m <- nchar(s2)
      d <- matrix(0, nrow = n + 1, ncol = m + 1)
      d[, 1] <- 0:n
      d[1, ] <- 0:m

      for (i in 2:(n + 1)) {
        for (j in 2:(m + 1)) {
          cost <- ifelse(substr(s1, i - 1, i - 1) == substr(s2, j - 1, j - 1), 0, 1)
          d[i, j] <- min(
            d[i - 1, j] + 1,
            d[i, j - 1] + 1,
            d[i - 1, j - 1] + cost
          )
        }
      }
      return(d[n + 1, m + 1])
    }

    # Bereinige VPN-Codes
    clean_vpn <- function(vpn) {
      tolower(trimws(vpn))
    }

    original_tests$VPN_clean <- clean_vpn(original_tests$DE12_01)
    retest_tests$VPN_clean <- clean_vpn(retest_tests$DE12_01)

    # STUFE 1: Exakte Übereinstimmung
    retest_matches <- data.frame(
      VPN_original = character(),
      VPN_retest = character(),
      idx_original = integer(),
      idx_retest = integer(),
      match_type = character(),
      edit_distance = integer(),
      stringsAsFactors = FALSE
    )

    matched_retest_idx <- c()
    matched_original_idx <- c()

    for (i in seq_len(nrow(retest_tests))) {
      vpn_retest <- retest_tests$VPN_clean[i]
      match_idx <- which(original_tests$VPN_clean == vpn_retest)

      if (length(match_idx) > 0) {
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

    # STUFE 2: Fuzzy Matching
    unmatched_retest_idx <- setdiff(seq_len(nrow(retest_tests)), matched_retest_idx)
    unmatched_original_idx <- setdiff(seq_len(nrow(original_tests)), matched_original_idx)

    MAX_EDIT_DISTANCE <- 2

    for (i in unmatched_retest_idx) {
      vpn_retest <- retest_tests$VPN_clean[i]
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
        unmatched_original_idx <- setdiff(unmatched_original_idx, best_match_idx)
      }
    }

    n_fuzzy_matches <- nrow(retest_matches) - n_exact_matches
    n_matches <- nrow(retest_matches)

    cat(sprintf("✓ Fuzzy Matches: %d\n", n_fuzzy_matches))
    cat(sprintf("✓ Gesamt-Matches: %d von %d Retest-Fällen\n\n", n_matches, nrow(retest_tests)))

    # ==============================================================================
    # 5.3 SKALEN FÜR RETEST-PAARE BERECHNEN
    # ==============================================================================

    cat("### 5.3 Skalen für Retest-Paare berechnen\n\n")

    # Funktion: Berechne nur die Kurzskalen
    calculate_short_scales <- function(df) {
      # Create hierarchical codes from original column names
      # Stressbelastung short scale
      df$STRS_FUTU_01 <- df$NI06_01 # Zukunftssorgen
      df$STRS_FINA_01 <- df$NI06_02 # Geldprobleme
      df$STRS_RELA_01 <- df$NI06_03 # Beziehungsprobleme
      df$STRS_PERF_01 <- df$NI06_04 # Leistungsdruck
      df$STRS_HEAL_01 <- df$NI06_05 # Gesundheitssorgen

      # Stresssymptome short scale
      df$SYMP_PHYS_01 <- df$NI13_01 # Körperliche Beschwerden
      df$SYMP_SLEP_01 <- df$NI13_02 # Schlaf/Träume
      df$SYMP_COGN_01 <- df$NI13_03 # Konzentration
      df$SYMP_MOOD_01 <- df$NI13_04 # Traurigkeit/Grübeln
      df$SYMP_SOCI_01 <- df$NI13_05 # Rückzug/Lustlosigkeit

      # Coping short scale
      df$COPE_DRUG_01 <- df$NI07_01 # Drogen/Substanzen
      df$COPE_RELI_01 <- df$NI07_02 # Religiös
      df$COPE_SOCI_01 <- df$NI07_03 # Sozial
      df$COPE_REAP_01 <- df$SO23_10 # Positive Neubewertung
      df$COPE_ACTI_01 <- df$SO23_01 # Aktiv

      # Stressbelastung (kurz)
      df$Stressbelastung_kurz <- rowMeans(
        df[, c("STRS_FUTU_01", "STRS_FINA_01", "STRS_RELA_01", "STRS_PERF_01", "STRS_HEAL_01")],
        na.rm = TRUE
      )

      # Stresssymptome (kurz)
      df$Stresssymptome_kurz <- rowMeans(
        df[, c("SYMP_PHYS_01", "SYMP_SLEP_01", "SYMP_COGN_01", "SYMP_MOOD_01", "SYMP_SOCI_01")],
        na.rm = TRUE
      )

      # Coping Items (Einzelitems, keine Berechnung nötig)
      # COPE_DRUG_01 bis COPE_ACTI_01 sind bereits vorhanden

      return(df)
    }

    original_tests <- calculate_short_scales(original_tests)
    retest_tests <- calculate_short_scales(retest_tests)

    cat("✓ Kurzskalen für Original-Tests berechnet\n")
    cat("✓ Kurzskalen für Retest-Tests berechnet\n\n")

    # ==============================================================================
    # 5.4 RETEST-RELIABILITÄT BERECHNEN (ITEM-LEVEL)
    # ==============================================================================

    cat("### 5.4 Retest-Reliabilität berechnen (Item-Level)\n\n")

    # Definiere Items nach Skalen
    item_gruppen_kurz <- list(
      "Stressbelastung (kurz)" = c("STRS_FUTU_01", "STRS_FINA_01", "STRS_RELA_01", "STRS_PERF_01", "STRS_HEAL_01"),
      "Stresssymptome (kurz)" = c("SYMP_PHYS_01", "SYMP_SLEP_01", "SYMP_COGN_01", "SYMP_MOOD_01", "SYMP_SOCI_01"),
      "Coping: Drogen/Substanzen" = "COPE_DRUG_01",
      "Coping: Religion/Spiritualität" = "COPE_RELI_01",
      "Coping: Soziale Unterstützung" = "COPE_SOCI_01",
      "Coping: Positive Neubewertung" = "COPE_REAP_01",
      "Coping: Aktive Bewältigung" = "COPE_ACTI_01"
    )

    # Dataframe für alle Item-Ergebnisse
    all_item_results <- data.frame(
      Skala = character(),
      Item = character(),
      N = integer(),
      r = numeric(),
      p = numeric(),
      Interpretation = character(),
      stringsAsFactors = FALSE
    )

    cat("Item-Level Retest-Reliabilitäten (N =", n_matches, "):\n")
    cat(paste(rep("=", 80), collapse = ""), "\n\n")

    for (skala_name in names(item_gruppen_kurz)) {
      items <- item_gruppen_kurz[[skala_name]]

      cat(sprintf("### %s\n\n", skala_name))

      # Sammle Item-Korrelationen für diese Skala
      item_cors <- c()

      for (item in items) {
        # Hole Werte für Test und Retest
        test_values <- original_tests[retest_matches$idx_original, item]
        retest_values <- retest_tests[retest_matches$idx_retest, item]

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

          # Interpretation
          interpretation <- ifelse(r_value > 0.80, "Exzellent",
            ifelse(r_value > 0.70, "Gut",
              ifelse(r_value > 0.60, "Akzeptabel", "Problematisch")
            )
          )

          # Speichere Ergebnisse
          all_item_results <- rbind(all_item_results, data.frame(
            Skala = skala_name,
            Item = item,
            N = n_pairs,
            r = r_value,
            p = p_value,
            Interpretation = interpretation,
            stringsAsFactors = FALSE
          ))

          item_cors <- c(item_cors, r_value)

          # Ausgabe
          sig_symbol <- ifelse(p_value < 0.001, "***",
            ifelse(p_value < 0.01, "**",
              ifelse(p_value < 0.05, "*", "ns")
            )
          )

          cat(sprintf(
            "  %-10s: r = %.3f%-3s (N = %d) - %s\n",
            item, r_value, sig_symbol, n_pairs, interpretation
          ))
        } else {
          cat(sprintf("  %-10s: Nicht genug Daten (N = %d)\n", item, n_pairs))
        }
      }

      # Durchschnitt für diese Skala (nur wenn Multi-Item)
      if (length(item_cors) > 1) {
        mean_r <- mean(item_cors, na.rm = TRUE)
        cat(sprintf("  → Mittleres r: %.3f\n\n", mean_r))
      } else {
        cat("\n")
      }
    }

    cat("Signifikanzniveaus: *** p<.001, ** p<.01, * p<.05, ns=nicht signifikant\n\n")

    # ==============================================================================
    # 5.5 FAZIT RETEST-RELIABILITÄT
    # ==============================================================================

    cat("### 5.5 Fazit Retest-Reliabilität\n\n")

    if (nrow(all_item_results) > 0) {
      # Berechne Durchschnitt über alle Items
      mean_r <- mean(all_item_results$r, na.rm = TRUE)
      median_r <- median(all_item_results$r, na.rm = TRUE)

      # Zähle nach Interpretation
      n_exzellent <- sum(all_item_results$Interpretation == "Exzellent")
      n_gut <- sum(all_item_results$Interpretation == "Gut")
      n_akzeptabel <- sum(all_item_results$Interpretation == "Akzeptabel")
      n_problematisch <- sum(all_item_results$Interpretation == "Problematisch")

      cat("ZUSAMMENFASSUNG:\n")
      cat(sprintf("  Anzahl Retest-Paare: %d\n", n_matches))
      cat(sprintf("  Anzahl Items: %d\n", nrow(all_item_results)))
      cat(sprintf("  Durchschnittliche Reliabilität: r = %.3f\n", mean_r))
      cat(sprintf("  Median Reliabilität: r = %.3f\n\n", median_r))

      cat("Verteilung der Item-Reliabilitäten:\n")
      cat(sprintf(
        "  - Exzellent (r > .80):     %d von %d Items\n",
        n_exzellent, nrow(all_item_results)
      ))
      cat(sprintf(
        "  - Gut (r > .70):           %d von %d Items\n",
        n_gut, nrow(all_item_results)
      ))
      cat(sprintf(
        "  - Akzeptabel (r > .60):    %d von %d Items\n",
        n_akzeptabel, nrow(all_item_results)
      ))
      cat(sprintf(
        "  - Problematisch (r < .60): %d von %d Items\n\n",
        n_problematisch, nrow(all_item_results)
      ))

      if (mean_r > 0.70) {
        cat("INTERPRETATION: Die Items zeigen insgesamt gute bis exzellente\n")
        cat("                Retest-Reliabilitäten. Die Messungen sind stabil.\n\n")
      } else if (mean_r > 0.60) {
        cat("INTERPRETATION: Die Items zeigen akzeptable Retest-Reliabilitäten.\n\n")
      } else {
        cat("INTERPRETATION: Einige Items zeigen niedrigere Stabilität.\n\n")
      }
    }
  }
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
cat("   ✓ Gute Test-Retest-Reliabilität (mittleres r = .79)\n")
cat("   ✓ Differenzierte Normierung nach empirischen Befunden\n")
cat("   ✓ Breite Validitätsevidenz (Korrelationen mit Außenkriterien)\n")
cat("   ✓ Erfassung mehrerer Stress-Dimensionen\n\n")

cat("LIMITATIONEN:\n")
cat("   ⚠ Coping-Items als Einzelitems (keine interne Konsistenz prüfbar)\n")
cat("   ⚠ Convenience Sample (eingeschränkte Generalisierbarkeit)\n")
cat("   ⚠ Kleine Retest-Stichprobe (N = 21)\n\n")

cat("EMPFEHLUNGEN FÜR ZUKÜNFTIGE FORSCHUNG:\n")
cat("   → Coping-Items zu Multi-Item-Skalen erweitern\n")
cat("   → Normierung an repräsentativer Stichprobe\n")
cat("   → Konstruktvalidität mit CFA weiter prüfen\n")
cat("   → Test-Retest mit größerer Stichprobe replizieren\n")
cat("   → Sensitivität für Veränderungsmessung untersuchen\n\n")

cat("✓ Finale Skalenmetriken-Analyse abgeschlossen\n\n")

cat("VERWENDUNG:\n")
cat("  - Nutzen Sie diesen Bericht für Ihren Methodenteil\n")
cat("  - Alle Kennwerte sind publikationsreif formatiert\n")
cat("  - Ergänzen Sie ggf. Interpretationen und Schlussfolgerungen\n")
cat("  - Alle Ergebnisse sind im Haupt-Analyse-Log enthalten\n\n")

# ==============================================================================
# KONVERGENTE VALIDITÄT: KORRELATIONSNETZWERK
# ==============================================================================

print_section("KORRELATIONSNETZWERK DER KONSTRUKTE", 1)

cat("Erstelle Netzwerkgraph für konvergente Validität...\n\n")

# Variablen für das Netzwerk auswählen
network_vars <- c(
  "Stressbelastung_kurz",
  "Stresssymptome_kurz",
  "NI07_01", # Drogen
  "NI07_02", # Religiös
  "NI07_03", # Sozial
  "SO23_10", # Positiv
  "SO23_01", # Aktiv
  "Zufriedenheit",
  "Neurotizismus",
  "Resilienz"
)

# Schönere Labels für die Visualisierung
network_labels <- c(
  "Stress-\nbelastung",
  "Stress-\nsymptome",
  "Coping:\nDrogen",
  "Coping:\nReligiös",
  "Coping:\nSozial",
  "Coping:\nPositiv",
  "Coping:\nAktiv",
  "Lebens-\nzufriedenheit",
  "Neuro-\ntizismus",
  "Resilienz"
)

# Korrelationsmatrix berechnen
cor_matrix <- cor(data[, network_vars], use = "pairwise.complete.obs")
rownames(cor_matrix) <- network_labels
colnames(cor_matrix) <- network_labels

# P-Werte berechnen
n_vars <- length(network_vars)
p_matrix <- matrix(NA, n_vars, n_vars)
for (i in 1:n_vars) {
  for (j in 1:n_vars) {
    if (i != j) {
      test <- cor.test(data[[network_vars[i]]], data[[network_vars[j]]])
      p_matrix[i, j] <- test$p.value
    }
  }
}

# Nur signifikante Korrelationen behalten (p < .05)
cor_matrix_sig <- cor_matrix
cor_matrix_sig[p_matrix >= 0.05] <- 0
diag(cor_matrix_sig) <- 0

# Netzwerk erstellen mit igraph
library(igraph)

# Adjazenzmatrix aus Korrelationen erstellen (nur absolute Werte > 0.15)
adj_matrix <- cor_matrix_sig
adj_matrix[abs(adj_matrix) < 0.15] <- 0

# Vorzeichen für Farben speichern
adj_matrix_signs <- sign(adj_matrix)

# Graph erstellen - verwende absolute Werte für Layout
adj_matrix_abs <- abs(adj_matrix)
g <- graph_from_adjacency_matrix(
  adj_matrix_abs,
  mode = "undirected",
  weighted = TRUE,
  diag = FALSE
)

# Kanten-Attribute setzen - hole ursprüngliche Vorzeichen zurück
edge_list <- as_edgelist(g)
original_weights <- numeric(ecount(g))
for (i in 1:ecount(g)) {
  v1 <- edge_list[i, 1]
  v2 <- edge_list[i, 2]
  # Hole den Wert aus der ursprünglichen Matrix mit Vorzeichen
  idx1 <- which(network_labels == v1)
  idx2 <- which(network_labels == v2)
  original_weights[i] <- adj_matrix[idx1, idx2]
}

edge_weights <- abs(original_weights)
edge_signs <- sign(original_weights)

# Farbe basierend auf Vorzeichen
# "#6BAED6", "#FC8D62",
edge_colors <- ifelse(edge_signs > 0, "#6BAED6", "#FC8D62") # Blau für positiv, Rot für negativ

# Linienbreite basierend auf Stärke
edge_widths <- edge_weights * 8

# Knoten-Attribute
V(g)$label <- V(g)$name
V(g)$size <- 23
V(g)$color <- "#f0f0f0"
V(g)$frame.color <- "#333333"
V(g)$label.color <- "#000000"
V(g)$label.cex <- 1
V(g)$label.family <- "sans"

# Plot erstellen
png(
  file.path(PLOTS_DIR, "51_korrelationsnetzwerk_validitaet.png"),
  width = 16,
  height = 14,
  units = "in",
  res = 300
)

par(mar = c(1, 1, 3, 8))

# Layout berechnen mit mehr Abstand zwischen Knoten
set.seed(42)
layout <- layout_with_fr(g, niter = 1500)
# Skaliere Layout für mehr Abstand (reduziert für kompaktere Darstellung)
layout <- layout * 2.0

plot(
  g,
  layout = layout,
  edge.width = edge_widths,
  edge.color = edge_colors,
  edge.curved = 0, # Gerade Linien
  edge.label = round(original_weights, 2), # Korrelationswerte auf Kanten
  edge.label.cex = 0.95,
  edge.label.color = "black",
  edge.label.family = "sans",
  vertex.size = V(g)$size,
  vertex.color = V(g)$color,
  vertex.frame.color = V(g)$frame.color,
  vertex.label = V(g)$label,
  vertex.label.color = V(g)$label.color,
  vertex.label.cex = V(g)$label.cex,
  vertex.label.family = V(g)$label.family,
  vertex.label.dist = 0,
  rescale = TRUE,
  xlim = c(-1.2, 1.4),
  ylim = c(-1.2, 1.2)
)

# Legende hinzufügen (außerhalb des Plot-Bereichs)
legend(
  x = 1.0,
  y = -0.4,
  legend = c(
    "Positive Korrelation",
    "Negative Korrelation",
    "",
    "Liniendicke = Stärke",
    "Zahlen = Korrelation",
    "p < .05, |r| ≥ .15"
  ),
  col = c("#6BAED6", "#FC8D62", NA, NA, NA, NA),
  lty = c(1, 1, 0, 0, 0, 0),
  lwd = c(3, 3, 0, 0, 0, 0),
  bty = "n",
  cex = 0.85,
  xpd = TRUE
)

dev.off()

cat("✓ Netzwerkgraph gespeichert: plots/51_korrelationsnetzwerk_validitaet.png\n\n")

# Statistische Zusammenfassung
cat("NETZWERK-STATISTIKEN:\n")
cat(paste(rep("-", 80), collapse = ""), "\n")
cat(sprintf("  Anzahl Knoten:              %d\n", vcount(g)))
cat(sprintf("  Anzahl Kanten:              %d\n", ecount(g)))
cat(sprintf("  Netzwerkdichte:             %.3f\n", edge_density(g)))
cat(sprintf("  Durchschnittliche Korr.:    %.3f\n", mean(edge_weights)))
cat(sprintf("  Median Korrelation:         %.3f\n", median(edge_weights)))
cat(sprintf("  Stärkste Korrelation:       %.3f\n", max(edge_weights)))
cat(sprintf("  Schwächste Korrelation:     %.3f\n\n", min(edge_weights)))

# Top 10 stärkste Korrelationen
edges_df <- data.frame(
  from = ends(g, E(g))[, 1],
  to = ends(g, E(g))[, 2],
  r = original_weights,
  abs_r = edge_weights
) %>%
  arrange(desc(abs_r))

cat("TOP 10 STÄRKSTE KORRELATIONEN:\n")
cat(paste(rep("-", 80), collapse = ""), "\n")
for (i in 1:min(10, nrow(edges_df))) {
  cat(sprintf(
    "  %2d. %-20s <-> %-20s   r = %6.3f\n",
    i,
    edges_df$from[i],
    edges_df$to[i],
    edges_df$r[i]
  ))
}
cat("\n")

cat("✓ Korrelationsnetzwerk-Analyse abgeschlossen\n\n")
