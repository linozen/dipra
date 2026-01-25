#!/usr/bin/env Rscript
# ==============================================================================
# NORMIERUNG: GRUPPENDIFFERENZEN & NORMTABELLEN
# ==============================================================================
#
# ZWECK:
# Dieses Skript kombiniert Normierungsanalyse und Normtabellen-Erstellung.
# Es untersucht, ob separate Normen für demographische Subgruppen nötig sind
# und erstellt entsprechende Normtabellen als CSV-Dateien.
#
# DOKUMENTATION:
#
# 1. NORMIERUNGSANALYSE
#    Untersucht systematisch, ob separate Normen für verschiedene demographische
#    Subgruppen notwendig sind oder ob eine gemeinsame Normierung angemessen ist.
#
#    Analysierte Faktoren:
#    - Geschlecht: Männlich vs. Weiblich
#    - Bildung: Niedrig vs. Mittel vs. Hoch
#    - Alter: Jung (<30) vs. Mittel (30-45) vs. Alt (>45)
#    - Beschäftigung: Hauptgruppen mit n≥20
#
#    Analysierte Skalen:
#    - Stressbelastung (kurz, 5 Items)
#    - Stresssymptome (kurz, 5 Items)
#    - Coping-Items (COPE_DRUG_01 bis COPE_ACTI_01, je 1 Item)
#
#    Statistische Methoden:
#    - Mittelwertsunterschiede: t-Tests (Geschlecht), ANOVA (andere)
#    - Varianzunterschiede: Levene-Test
#    - Effektgrößen: Cohen's d (Geschlecht), Eta² (andere)
#
#    Entscheidungskriterien für separate Normierung:
#    1. Signifikante Mittelwertsunterschiede (p < .05)
#    2. Substanzielle Effektgröße (d ≥ 0.3 oder η² ≥ 0.06)
#    3. Signifikante Varianzunterschiede (p < .05)
#    4. Praktische Relevanz der Unterschiede
#
#    Interpretation der Empfehlungen:
#    - "Gemeinsame Norm": Keine substanziellen Gruppenunterschiede
#    - "Getrennte Normen empfohlen": Signifikante + substanzielle Unterschiede
#    - "Getrennte Normen erwägen": Signifikante, aber kleine Effektgrößen
#    - "(+ Varianzunterschiede)": Zusätzlich heterogene Streuungen
#
# 2. NORMTABELLEN
#    Erstellt Normtabellen basierend auf den Analyseergebnissen:
#    - Gemeinsame Normen für homogene Skalen
#    - Geschlechtsspezifische Normen bei relevanten Unterschieden
#    - Altersspezifische Normen bei Alterseffekten
#
#    Normwerte:
#    - Z-Werte (M=0, SD=1): Standardisierte Abweichung vom Mittelwert
#    - T-Werte (M=50, SD=10): Intuitivere Skala (Normalbereich: 40-60)
#    - Beziehung: T = 50 + 10×Z
#
#    Interpretation der Normwerte:
#    Z-Werte:
#      < -2.0: Sehr niedrig (untere 2.5%)
#      -2.0 bis -1.0: Unterdurchschnittlich
#      -1.0 bis +1.0: Durchschnittlich (ca. 68%)
#      +1.0 bis +2.0: Überdurchschnittlich
#      > +2.0: Sehr hoch (obere 2.5%)
#
#    T-Werte:
#      < 30: Sehr niedrig
#      30-39: Unterdurchschnittlich
#      40-60: Durchschnittlich (Normalbereich)
#      61-70: Überdurchschnittlich
#      > 70: Sehr hoch
#
# VERWENDUNG IM MANUAL:
# 1. Rohwert berechnen (Mittelwert der Items)
# 2. Passende Normtabelle auswählen (nach Geschlecht/Alter falls nötig)
# 3. Normwerte (Z, T) aus Tabelle ablesen
# 4. Interpretation im Kontext der Normstichprobe
#
# BEISPIEL:
# Testperson: Weiblich, 28 Jahre, Rohwert Stressbelastung = 3.8
# 1. Alter: 28 → Jung (<30)
# 2. Tabelle: normtabelle_stressbelastung_jung.csv
# 3. Rohwert 3.8 → Z=+0.5, T=55
# 4. Interpretation: "Durchschnittliche Stressbelastung (T=55) im Vergleich
#    zu jungen Erwachsenen, 0.5 SD über dem Gruppenmittelwert"
#
# PRAKTISCHE ÜBERLEGUNGEN:
# - Mindestens n=50 pro Subgruppe empfohlen
# - Balance zwischen statistischer Differenzierung und Praktikabilität
# - Theoretische Plausibilität der Gruppenunterschiede prüfen
# - Bei mehreren relevanten Faktoren: Priorisierung oder Kombination erwägen
#
# OUTPUT:
# - CSV-Dateien: normtabelle_*.csv (Normwerte für Manual)
#
# LITERATUR:
# - Cohen, J. (1988). Statistical power analysis for the behavioral sciences
# - Lenhard, W., & Lenhard, A. (2014). Berechnung der Normwerte
# - Lienert, G. A., & Raatz, U. (1998). Testaufbau und Testanalyse
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

print_section("NORMIERUNG: GRUPPENDIFFERENZEN & NORMTABELLEN")

cat("Dieses Skript analysiert Gruppenunterschiede und erstellt Normtabellen.\n\n")

# ==============================================================================
# HILFSFUNKTIONEN FÜR STATISTISCHE ANALYSEN
# ==============================================================================

# Cohen's d berechnen
cohens_d <- function(x, y) {
  nx <- length(x)
  ny <- length(y)
  pooled_sd <- sqrt(((nx - 1) * var(x) + (ny - 1) * var(y)) / (nx + ny - 2))
  d <- (mean(x) - mean(y)) / pooled_sd
  return(d)
}

# Effektgröße interpretieren
interpret_d <- function(d) {
  abs_d <- abs(d)
  if (abs_d < 0.2) {
    return("trivial")
  }
  if (abs_d < 0.5) {
    return("klein")
  }
  if (abs_d < 0.8) {
    return("mittel")
  }
  return("groß")
}

interpret_eta <- function(eta) {
  if (eta < 0.01) {
    return("trivial")
  }
  if (eta < 0.06) {
    return("klein")
  }
  if (eta < 0.14) {
    return("mittel")
  }
  return("groß")
}

# Levene-Test (eigene Implementierung)
levene_test <- function(value, group) {
  complete_cases <- complete.cases(value, group)
  value <- value[complete_cases]
  group <- factor(group[complete_cases])

  group_medians <- tapply(value, group, median, na.rm = TRUE)
  abs_dev <- abs(value - group_medians[group]) # nolint: object_usage_linter
  anova_result <- anova(lm(abs_dev ~ group))

  f_value <- anova_result$`F value`[1]
  p_value <- anova_result$`Pr(>F)`[1]
  df1 <- anova_result$Df[1]
  df2 <- anova_result$Df[2]

  return(list(
    statistic = f_value,
    p.value = p_value,
    df1 = df1,
    df2 = df2
  ))
}

# ==============================================================================
# HILFSFUNKTIONEN FÜR NORMTABELLEN
# ==============================================================================

# Z-Wert berechnen
calculate_z_score <- function(raw_score, mean_val, sd_val) {
  z_score <- (raw_score - mean_val) / sd_val
  return(round(z_score, 2))
}

# T-Wert berechnen (M=50, SD=10)
calculate_t_score <- function(raw_score, mean_val, sd_val) {
  t_score <- 50 + 10 * ((raw_score - mean_val) / sd_val)
  return(round(t_score))
}

# Normtabelle erstellen und als CSV speichern
create_norm_table_csv <- function(scores, filename, title, subtitle = NULL, integer_only = FALSE) {
  # Entferne fehlende Werte
  scores <- scores[!is.na(scores)]

  # Berechne Statistiken
  mean_val <- mean(scores)
  sd_val <- sd(scores)
  n <- length(scores)

  # Bestimme Wertebereich und Schrittweite
  if (integer_only) {
    # Für Single-Item-Skalen: Nur ganze Zahlen
    min_score <- floor(min(scores))
    max_score <- ceiling(max(scores))
    raw_scores <- seq(min_score, max_score, by = 1)
  } else {
    # Für Multi-Item-Skalen: 0.1er Schritte
    min_score <- floor(min(scores) * 10) / 10
    max_score <- ceiling(max(scores) * 10) / 10
    raw_scores <- seq(min_score, max_score, by = 0.1)
    raw_scores <- round(raw_scores, 1)
  }
  raw_scores <- unique(raw_scores)

  # Berechne Z-Werte und T-Werte
  norm_data <- data.frame(
    Rohwert = raw_scores,
    Z_Wert = sapply(raw_scores, function(x) calculate_z_score(x, mean_val, sd_val)),
    T_Wert = sapply(raw_scores, function(x) calculate_t_score(x, mean_val, sd_val))
  )

  # Filtere relevanten Bereich (T-Werte zwischen 20 und 80)
  norm_data <- norm_data[norm_data$T_Wert >= 20 & norm_data$T_Wert <= 80, ]

  # Füge Metadaten hinzu
  metadata <- data.frame(
    Rohwert = c("# Titel", "# Untertitel", "# N", "# Mittelwert", "# SD", "# Min", "# Max", ""),
    Z_Wert = c(
      title, ifelse(is.null(subtitle), "", subtitle), n,
      round(mean_val, 2), round(sd_val, 2),
      round(min(scores), 2), round(max(scores), 2), ""
    ),
    T_Wert = rep("", 8)
  )

  # Kombiniere Metadaten und Normwerte
  output_data <- rbind(metadata, norm_data)

  # Speichere als CSV
  write.csv(output_data, filename, row.names = FALSE, quote = FALSE)

  cat(sprintf("✓ Normtabelle gespeichert: %s\n", filename))
  cat(sprintf("  N = %d, M = %.2f, SD = %.2f\n\n", n, mean_val, sd_val))

  return(list(
    data = norm_data,
    stats = list(n = n, mean = mean_val, sd = sd_val)
  ))
}

# ==============================================================================
# SKALEN DEFINIEREN
# ==============================================================================

skalen_namen <- c(
  "Stressbelastung_kurz",
  "Stresssymptome_kurz",
  "NI07_01", # Coping: Drogen
  "NI07_02", # Coping: Religiös
  "NI07_03", # Coping: Sozial
  "NI07_04", # Coping: Positiv
  "NI07_05" # Coping: Aktiv
)

skalen_labels <- c(
  "Stressbelastung (kurz)",
  "Stresssymptome (kurz)",
  "Coping: Drogen (NI07_01)",
  "Coping: Religiös (NI07_02)",
  "Coping: Sozial (NI07_03)",
  "Coping: Positiv (NI07_04)",
  "Coping: Aktiv (NI07_05)"
)

# ==============================================================================
# GRUPPIERUNGSVARIABLEN VORBEREITEN
# ==============================================================================

print_section("Vorbereitung der Gruppierungsvariablen", 2)

# Geschlecht
data$Geschlecht_clean <- factor(
  ifelse(data$Geschlecht == "1", "Männlich",
    ifelse(data$Geschlecht == "2", "Weiblich", NA)
  ),
  levels = c("Männlich", "Weiblich")
)

# Bildung
data$Bildung_gruppiert <- cut(
  as.numeric(data$Bildung),
  breaks = c(0, 3, 4, 7, 8),
  labels = c("Niedrig", "Mittel", "Hoch", "Andere"),
  include.lowest = TRUE
)

# Alter
data$Alter_gruppiert <- cut(
  data$Alter,
  breaks = c(0, 30, 45, 100),
  labels = c("Jung (<30)", "Mittel (30-45)", "Alt (>45)"),
  include.lowest = TRUE
)

# Beschäftigung
beschaeftigung_freq <- table(data$Beschäftigung)
beschaeftigung_freq <- beschaeftigung_freq[beschaeftigung_freq >= 20]
data$Beschäftigung_gruppiert <- ifelse(
  data$Beschäftigung %in% names(beschaeftigung_freq),
  as.character(data$Beschäftigung),
  "Andere"
)

cat("Gruppierungsvariablen erstellt:\n")
cat("  ✓ Geschlecht: Männlich, Weiblich\n")
cat("  ✓ Bildung: Niedrig, Mittel, Hoch\n")
cat("  ✓ Alter: Jung (<30), Mittel (30-45), Alt (>45)\n")
cat("  ✓ Beschäftigung: Hauptgruppen mit n≥20\n\n")

# Erstelle Ausgabeordner
dir.create("manual", showWarnings = FALSE)
dir.create("manual/output/normtabellen", showWarnings = FALSE)

# ==============================================================================
# TEIL 1: NORMIERUNGSANALYSE - GESCHLECHTSUNTERSCHIEDE
# ==============================================================================

print_section("TEIL 1: NORMIERUNGSANALYSE")
print_section("1.1 GESCHLECHTSUNTERSCHIEDE", 2)

geschlecht_results <- data.frame(
  Skala = character(),
  Label = character(),
  M_Maennlich = numeric(),
  SD_Maennlich = numeric(),
  M_Weiblich = numeric(),
  SD_Weiblich = numeric(),
  t = numeric(),
  df = numeric(),
  p_ttest = numeric(),
  d = numeric(),
  d_interpretation = character(),
  F_levene = numeric(),
  p_levene = numeric(),
  Empfehlung = character(),
  stringsAsFactors = FALSE
)

data_gender <- subset(data, !is.na(Geschlecht_clean))

cat("Stichprobengröße:\n")
cat(sprintf("  Männlich:  n = %d\n", sum(data_gender$Geschlecht_clean == "Männlich")))
cat(sprintf("  Weiblich:  n = %d\n\n", sum(data_gender$Geschlecht_clean == "Weiblich")))

for (i in seq_along(skalen_namen)) {
  skala <- skalen_namen[i]
  label <- skalen_labels[i]

  values_male <- data_gender[[skala]][data_gender$Geschlecht_clean == "Männlich"]
  values_female <- data_gender[[skala]][data_gender$Geschlecht_clean == "Weiblich"]

  values_male <- values_male[!is.na(values_male)]
  values_female <- values_female[!is.na(values_female)]

  if (length(values_male) > 0 && length(values_female) > 0) {
    m_male <- mean(values_male)
    sd_male <- sd(values_male)
    m_female <- mean(values_female)
    sd_female <- sd(values_female)

    t_result <- t.test(values_male, values_female)
    d <- cohens_d(values_male, values_female)
    d_interp <- interpret_d(d)

    levene_values <- c(values_male, values_female)
    levene_groups <- factor(c(rep("M", length(values_male)), rep("F", length(values_female))))
    levene_result <- levene_test(levene_values, levene_groups)

    empfehlung <- "Gemeinsame Norm"
    if (t_result$p.value < 0.05 && abs(d) >= 0.3) {
      empfehlung <- "Getrennte Normen empfohlen"
    } else if (t_result$p.value < 0.05) {
      empfehlung <- "Getrennte Normen erwägen"
    }
    if (levene_result$p.value < 0.05) {
      empfehlung <- paste(empfehlung, "(+ Varianzunterschiede)")
    }

    cat(sprintf("### %s\n", label))
    cat(sprintf("  Männlich:  M = %.2f, SD = %.2f\n", m_male, sd_male))
    cat(sprintf("  Weiblich:  M = %.2f, SD = %.2f\n", m_female, sd_female))
    cat(sprintf(
      "  t-Test:    t(%.1f) = %.3f, p = %s\n",
      t_result$parameter, t_result$statistic,
      format.pval(t_result$p.value, digits = 3)
    ))
    cat(sprintf("  Cohen's d: d = %.3f (%s)\n", d, d_interp))
    cat(sprintf("  → %s\n\n", empfehlung))

    geschlecht_results <- rbind(geschlecht_results, data.frame(
      Skala = skala,
      Label = label,
      M_Maennlich = m_male,
      SD_Maennlich = sd_male,
      M_Weiblich = m_female,
      SD_Weiblich = sd_female,
      t = t_result$statistic,
      df = t_result$parameter,
      p_ttest = t_result$p.value,
      d = d,
      d_interpretation = d_interp,
      F_levene = levene_result$statistic,
      p_levene = levene_result$p.value,
      Empfehlung = empfehlung,
      stringsAsFactors = FALSE
    ))
  }
}



# ==============================================================================
# TEIL 2: NORMTABELLEN ERSTELLEN
# ==============================================================================

print_section("TEIL 2: NORMTABELLEN ERSTELLEN")

cat("Erstelle Normtabellen basierend auf Analyseergebnissen...\n\n")
cat("Hinweis: Intermediate analysis results are used internally only.\n")
cat("Final output: Norm tables in output/normtabellen/\n\n")

# 1. Stresssymptome (kurz) - Gemeinsame Norm
print_section("2.1 Stresssymptome - Gemeinsame Norm", 2)
create_norm_table_csv(
  scores = data$Stresssymptome_kurz,
  filename = "manual/output/normtabellen/normtabelle_stresssymptome.csv",
  title = "Stresssymptome (Kurzskala)",
  subtitle = "Gemeinsame Norm für gesamte Stichprobe"
)

# 2. Coping Drogen - Gemeinsame Norm
print_section("2.2 Coping: Drogen - Gemeinsame Norm", 2)
create_norm_table_csv(
  scores = data$NI07_01,
  title = "Coping: Drogen (Item NI07_01)",
  filename = "manual/output/normtabellen/normtabelle_coping_drogen.csv",
  subtitle = "Gemeinsame Norm",
  integer_only = TRUE
)

# 3. Coping Religiös - Gemeinsame Norm
print_section("2.3 Coping: Religiös - Gemeinsame Norm", 2)
create_norm_table_csv(
  scores = data$NI07_02,
  title = "Coping: Religiös (Item NI07_02)",
  filename = "manual/output/normtabellen/normtabelle_coping_religioes.csv",
  subtitle = "Gemeinsame Norm",
  integer_only = TRUE
)

# 4. Coping Sozial - Gemeinsame Norm
print_section("2.4 Coping: Sozial - Gemeinsame Norm", 2)
create_norm_table_csv(
  scores = data$NI07_03,
  title = "Coping: Sozial (Item NI07_03)",
  filename = "manual/output/normtabellen/normtabelle_coping_sozial.csv",
  subtitle = "Gemeinsame Norm",
  integer_only = TRUE
)

# 5. Coping Positiv - Gemeinsame Norm
print_section("2.5 Coping: Positiv - Gemeinsame Norm", 2)
create_norm_table_csv(
  scores = data$NI07_04,
  title = "Coping: Positiv (Item NI07_04)",
  filename = "manual/output/normtabellen/normtabelle_coping_positiv.csv",
  subtitle = "Gemeinsame Norm",
  integer_only = TRUE
)

# 6. Coping Aktiv - Geschlechtsspezifische Normen (basierend auf Analyse)
print_section("2.6 Coping: Aktiv - Geschlechtsspezifische Normen", 2)
cat("Erstelle separate Normtabellen für Männer und Frauen...\n\n")

data_male <- subset(data, Geschlecht_clean == "Männlich")
create_norm_table_csv(
  scores = data_male$NI07_05,
  title = "Coping: Aktiv (Item NI07_05)",
  filename = "manual/output/normtabellen/normtabelle_coping_aktiv_maennlich.csv",
  subtitle = "Norm für Männer",
  integer_only = TRUE
)

data_female <- subset(data, Geschlecht_clean == "Weiblich")
create_norm_table_csv(
  scores = data_female$NI07_05,
  title = "Coping: Aktiv (Item NI07_05)",
  filename = "manual/output/normtabellen/normtabelle_coping_aktiv_weiblich.csv",
  subtitle = "Norm für Frauen",
  integer_only = TRUE
)

# 7. Stressbelastung - Altersspezifische Normen
print_section("2.7 Stressbelastung - Altersspezifische Normen", 2)
cat("Erstelle altersspezifische Normtabellen...\n\n")

data_jung <- subset(data, Alter_gruppiert == "Jung (<30)")
create_norm_table_csv(
  scores = data_jung$Stressbelastung_kurz,
  filename = "manual/output/normtabellen/normtabelle_stressbelastung_jung.csv",
  title = "Stressbelastung (Kurzskala)",
  subtitle = "Norm für junge Erwachsene (< 30 Jahre)"
)

data_mittel <- subset(data, Alter_gruppiert == "Mittel (30-45)")
create_norm_table_csv(
  scores = data_mittel$Stressbelastung_kurz,
  filename = "manual/output/normtabellen/normtabelle_stressbelastung_mittel.csv",
  title = "Stressbelastung (Kurzskala)",
  subtitle = "Norm für mittleres Alter (30-45 Jahre)"
)

data_alt <- subset(data, Alter_gruppiert == "Alt (>45)")
create_norm_table_csv(
  scores = data_alt$Stressbelastung_kurz,
  filename = "manual/output/normtabellen/normtabelle_stressbelastung_alt.csv",
  title = "Stressbelastung (Kurzskala)",
  subtitle = "Norm für ältere Erwachsene (> 45 Jahre)"
)

# ==============================================================================
# ZUSAMMENFASSUNG SPEICHERN
# ==============================================================================

print_section("ZUSAMMENFASSUNG", 2)

cat("Erstellte Normtabellen:\n")
cat("  1. Stresssymptome: 1 gemeinsame Normtabelle\n")
cat("  2. Coping Drogen: 1 gemeinsame Normtabelle\n")
cat("  3. Coping Religiös: 1 gemeinsame Normtabelle\n")
cat("  4. Coping Sozial: 1 gemeinsame Normtabelle\n")
cat("  5. Coping Positiv: 1 gemeinsame Normtabelle\n")
cat("  6. Coping Aktiv: 2 geschlechtsspezifische Normtabellen\n")
cat("  7. Stressbelastung: 3 altersspezifische Normtabellen\n\n")

cat("Gesamt: 10 Normtabellen als CSV-Dateien\n")
cat("Speicherort: output/normtabellen/\n\n")



print_section("NORMIERUNG ABGESCHLOSSEN")

cat("NÄCHSTE SCHRITTE:\n")
cat("1. Überprüfen Sie die Normtabellen in output/normtabellen/\n")
cat("2. Integrieren Sie die Tabellen in Ihr Test-Manual\n")
cat("3. Dokumentieren Sie die Normierungsstrategie in Ihrer Arbeit\n")
cat("4. Beachten Sie geschlechts- und altersspezifische Normen bei der Anwendung\n\n")
