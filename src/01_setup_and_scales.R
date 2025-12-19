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
# KONFIGURATION - FILEPATHS VON run_all.R
# ==============================================================================

# Diese Variablen sollten von run_all.R gesetzt sein
# Falls direkt ausgeführt, verwende Defaults
if (!exists("CLEAN_DATA_FILE")) {
  CLEAN_DATA_FILE <- "data/data.csv"
}
if (!exists("WORKSPACE_FILE")) {
  WORKSPACE_FILE <- "data/workspace.RData"
}
if (!exists("PLOTS_DIR")) {
  PLOTS_DIR <- "plots"
}

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

# Fisher's Z-Test für Korrelationsvergleiche
fisher_z_test <- function(r1, n1, r2, n2) {
  z <- (atanh(r1) - atanh(r2)) / sqrt(1 / (n1 - 3) + 1 / (n2 - 3))
  p <- 2 * (1 - pnorm(abs(z)))
  list(z = z, p = p)
}

# ==============================================================================
# DATEN EINLESEN
# ==============================================================================

print_section("DATEN EINLESEN")

# Daten einlesen
data <- read.csv(CLEAN_DATA_FILE, header = TRUE, sep = ";", dec = ",")
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

# Bildung gruppieren: Niedrig, Mittel, Hoch
# 1=Hauptschule (Niedrig)
# 2=Realschule (Niedrig), 3=Fachhochschulreife (Mittel), 4=Hochschulreife (Mittel)
# 5=Bachelor (Hoch), 6=Master (Hoch), 7=Staatsexamen (Hoch), 8=Andere
data$Bildung_gruppiert <- case_when(
  data$Bildung %in% c("1", "2") ~ "Niedrig",
  data$Bildung %in% c("3", "4") ~ "Mittel",
  data$Bildung %in% c("5", "6", "7") ~ "Hoch",
  TRUE ~ NA_character_
)

# Alter gruppieren: Jung, Mittel, Alt
# Jung: <30, Mittel: 30-45, Alt: >45
data$Alter_gruppiert <- case_when(
  data$Alter < 30 ~ "Jung",
  data$Alter >= 30 & data$Alter <= 45 ~ "Mittel",
  data$Alter > 45 ~ "Alt",
  TRUE ~ NA_character_
)

# Beschäftigung gruppieren (bereits als Beschäftigung vorhanden)
data$Beschäftigung_gruppiert <- data$Beschäftigung

cat("✓ Datenbereinigung abgeschlossen\n")
cat("  - Alter ≥18 Jahre\n")
cat("  - Aufmerksamkeitstest bestanden (SO02_14 == 4)\n")
cat("  - Bildung gruppiert (Niedrig/Mittel/Hoch)\n")
cat("  - Alter gruppiert (Jung/Mittel/Alt)\n\n")

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
# VARIANZANALYSE DER ITEMS
# ==============================================================================
#
# Diese Sektion analysiert die Varianz aller Items, die in die Skalenkonstruktion
# eingehen. Items mit zu geringer Varianz sind problematisch für psychometrische
# Analysen, da sie:
#
# 1. Keine ausreichende Differenzierung zwischen Personen ermöglichen
# 2. Die Reliabilität der Skala verringern können
# 3. Zu Decken- oder Bodeneffekten führen können
# 4. Korrelationen mit anderen Variablen abschwächen (range restriction)
#
# KRITERIEN FÜR AUSREICHENDE VARIANZ:
#
# 1. Standardabweichung (SD)
#    - Mindestkriterium: SD > 0.5 (bei Skalen von 1-7 oder 1-6)
#    - Optimal: SD > 1.0
#    - Items mit SD < 0.5 zeigen sehr geringe Streuung
#
# 2. Varianz (Var = SD²)
#    - Mindestkriterium: Var > 0.25
#    - Optimal: Var > 1.0
#
# 3. Wertebereich (Range)
#    - Mindestkriterium: Range sollte mindestens 50% der theoretischen Range nutzen
#    - Bei 7-Punkte-Skala: Range ≥ 3
#    - Bei 6-Punkte-Skala: Range ≥ 3
#
# 4. Decken- und Bodeneffekte
#    - Deckeneffekt: >15% wählen höchsten Wert
#    - Bodeneffekt: >15% wählen niedrigsten Wert
#    - Beides deutet auf unzureichende Differenzierung hin
#
# WICHTIG: Items mit unzureichender Varianz werden hier nur IDENTIFIZIERT,
# nicht automatisch entfernt. Die Entscheidung über den Umgang sollte
# theoriegeleitet erfolgen.
#
# ==============================================================================

print_section("VARIANZANALYSE DER ITEMS")

# ------------------------------------------------------------------------------
# SCHRITT 1: Alle relevanten Items für die Analyse identifizieren
# ------------------------------------------------------------------------------

cat("Identifiziere alle Items für die Varianzanalyse...\n\n")

# Definiere alle Item-Gruppen nach Skalen
item_gruppen <- list(
  "Big Five (Neurotizismus)" = c("BF01_01", "BF01_02"),
  "Resilienz" = c("RE01_01", "RE01_02", "RE01_03", "RE01_04", "RE01_05", "RE01_06"),
  "Stressbelastung (kurz)" = c("NI06_01", "NI06_02", "NI06_03", "NI06_04", "NI06_05"),
  "Stressbelastung (lang)" = c(
    "SO01_01", "SO01_02", "SO01_03", "SO01_04", "SO01_05",
    "SO01_06", "SO01_07", "SO01_08", "SO01_09", "SO01_10", "SO01_11"
  ),
  "Stresssymptome (kurz)" = c("NI13_01", "NI13_02", "NI13_03", "NI13_04", "NI13_05"),
  "Stresssymptome (lang)" = c(
    "SO02_01", "SO02_02", "SO02_03", "SO02_04", "SO02_05",
    "SO02_06", "SO02_07", "SO02_08", "SO02_09", "SO02_10",
    "SO02_11", "SO02_12", "SO02_13"
  ),
  "Coping (Items)" = c(
    "NI07_01", "NI07_02", "NI07_03", "NI07_04", "NI07_05",
    "SO23_01", "SO23_02", "SO23_04", "SO23_05", "SO23_06",
    "SO23_07", "SO23_09", "SO23_10", "SO23_11", "SO23_12",
    "SO23_13", "SO23_14", "SO23_15", "SO23_16", "SO23_17",
    "SO23_18", "SO23_20"
  ),
  "Zufriedenheit" = c("L101_01")
)

# Erstelle einen Vektor mit allen Items
alle_items <- unlist(item_gruppen, use.names = FALSE)
n_items_gesamt <- length(alle_items)

cat("Anzahl analysierter Items:", n_items_gesamt, "\n")
cat("Verteilung nach Skalen:\n")
for (gruppe in names(item_gruppen)) {
  cat(sprintf("  %-30s: %2d Items\n", gruppe, length(item_gruppen[[gruppe]])))
}
cat("\n")

# ------------------------------------------------------------------------------
# SCHRITT 2: Varianzstatistiken für alle Items berechnen
# ------------------------------------------------------------------------------

print_section("Varianzstatistiken pro Item", 2)

cat("Berechne Varianzstatistiken für alle Items...\n\n")

# Erstelle Dataframe für Ergebnisse
varianz_analyse <- data.frame(
  Item = character(),
  Skala = character(),
  N = integer(),
  Mittelwert = numeric(),
  SD = numeric(),
  Varianz = numeric(),
  Min = numeric(),
  Max = numeric(),
  Range = numeric(),
  Prozent_Min = numeric(),
  Prozent_Max = numeric(),
  SD_Kriterium = logical(),
  Range_Kriterium = logical(),
  Deckeneffekt = logical(),
  Bodeneffekt = logical(),
  stringsAsFactors = FALSE
)

# Schwellenwerte definieren
SD_SCHWELLE <- 0.5
RANGE_SCHWELLE <- 3
DECKE_SCHWELLE <- 15 # Prozent
BODEN_SCHWELLE <- 15 # Prozent

# Analysiere jedes Item
for (skala_name in names(item_gruppen)) {
  items <- item_gruppen[[skala_name]]

  for (item in items) {
    # Hole Werte (ohne NA)
    werte <- data[[item]][!is.na(data[[item]])]
    n <- length(werte)

    if (n > 0) {
      # Basisstatistiken
      m <- mean(werte, na.rm = TRUE)
      s <- sd(werte, na.rm = TRUE)
      v <- var(werte, na.rm = TRUE)
      min_val <- min(werte, na.rm = TRUE)
      max_val <- max(werte, na.rm = TRUE)
      range_val <- max_val - min_val

      # Decken- und Bodeneffekte
      prozent_min <- (sum(werte == min_val) / n) * 100
      prozent_max <- (sum(werte == max_val) / n) * 100

      # Kriterien prüfen
      sd_ok <- s > SD_SCHWELLE
      range_ok <- range_val >= RANGE_SCHWELLE
      deckeneffekt <- prozent_max > DECKE_SCHWELLE
      bodeneffekt <- prozent_min > BODEN_SCHWELLE

      # Füge zur Tabelle hinzu
      varianz_analyse <- rbind(varianz_analyse, data.frame(
        Item = item,
        Skala = skala_name,
        N = n,
        Mittelwert = m,
        SD = s,
        Varianz = v,
        Min = min_val,
        Max = max_val,
        Range = range_val,
        Prozent_Min = prozent_min,
        Prozent_Max = prozent_max,
        SD_Kriterium = sd_ok,
        Range_Kriterium = range_ok,
        Deckeneffekt = deckeneffekt,
        Bodeneffekt = bodeneffekt,
        stringsAsFactors = FALSE
      ))
    }
  }
}

# ------------------------------------------------------------------------------
# SCHRITT 3: Identifiziere problematische Items
# ------------------------------------------------------------------------------

print_section("Identifikation problematischer Items", 2)

# Items mit zu geringer SD
items_geringe_sd <- varianz_analyse[!varianz_analyse$SD_Kriterium, ]
n_geringe_sd <- nrow(items_geringe_sd)

# Items mit zu geringer Range
items_geringe_range <- varianz_analyse[!varianz_analyse$Range_Kriterium, ]
n_geringe_range <- nrow(items_geringe_range)

# Items mit Deckeneffekt
items_deckeneffekt <- varianz_analyse[varianz_analyse$Deckeneffekt, ]
n_deckeneffekt <- nrow(items_deckeneffekt)

# Items mit Bodeneffekt
items_bodeneffekt <- varianz_analyse[varianz_analyse$Bodeneffekt, ]
n_bodeneffekt <- nrow(items_bodeneffekt)

# Kombiniere: Items mit IRGENDEINEM Problem
items_problematisch <- varianz_analyse[
  !varianz_analyse$SD_Kriterium |
    !varianz_analyse$Range_Kriterium |
    varianz_analyse$Deckeneffekt |
    varianz_analyse$Bodeneffekt,
]
n_problematisch <- nrow(items_problematisch)

cat("ZUSAMMENFASSUNG DER PROBLEMATISCHEN ITEMS:\n")
cat(paste(rep("=", 80), collapse = ""), "\n\n")
cat(sprintf(
  "Items mit SD < %.2f:                    %2d (%.1f%%)\n",
  SD_SCHWELLE, n_geringe_sd, 100 * n_geringe_sd / n_items_gesamt
))
cat(sprintf(
  "Items mit Range < %d:                    %2d (%.1f%%)\n",
  RANGE_SCHWELLE, n_geringe_range, 100 * n_geringe_range / n_items_gesamt
))
cat(sprintf(
  "Items mit Deckeneffekt (>%d%%):          %2d (%.1f%%)\n",
  DECKE_SCHWELLE, n_deckeneffekt, 100 * n_deckeneffekt / n_items_gesamt
))
cat(sprintf(
  "Items mit Bodeneffekt (>%d%%):           %2d (%.1f%%)\n",
  BODEN_SCHWELLE, n_bodeneffekt, 100 * n_bodeneffekt / n_items_gesamt
))
cat("\n")
cat(sprintf(
  "Gesamt problematische Items:            %2d (%.1f%%)\n",
  n_problematisch, 100 * n_problematisch / n_items_gesamt
))
cat(sprintf(
  "Items ohne Probleme:                    %2d (%.1f%%)\n",
  n_items_gesamt - n_problematisch,
  100 * (n_items_gesamt - n_problematisch) / n_items_gesamt
))

# ------------------------------------------------------------------------------
# SCHRITT 4: Detaillierte Ausgabe problematischer Items
# ------------------------------------------------------------------------------

if (n_problematisch > 0) {
  print_section("Details zu problematischen Items", 2)

  cat("Die folgenden Items zeigen Auffälligkeiten bei der Varianzanalyse:\n\n")

  for (i in seq_len(nrow(items_problematisch))) {
    item_info <- items_problematisch[i, ]

    cat(sprintf("Item: %s (%s)\n", item_info$Item, item_info$Skala))
    cat(sprintf(
      "  M = %.2f, SD = %.2f, Range = %.1f [%.1f - %.1f]\n",
      item_info$Mittelwert, item_info$SD, item_info$Range,
      item_info$Min, item_info$Max
    ))

    # Identifiziere spezifische Probleme
    probleme <- c()
    if (!item_info$SD_Kriterium) {
      probleme <- c(probleme, sprintf("SD zu gering (%.2f < %.2f)", item_info$SD, SD_SCHWELLE))
    }
    if (!item_info$Range_Kriterium) {
      probleme <- c(probleme, sprintf("Range zu gering (%.1f < %d)", item_info$Range, RANGE_SCHWELLE))
    }
    if (item_info$Deckeneffekt) {
      probleme <- c(probleme, sprintf("Deckeneffekt (%.1f%% wählen Maximum)", item_info$Prozent_Max))
    }
    if (item_info$Bodeneffekt) {
      probleme <- c(probleme, sprintf("Bodeneffekt (%.1f%% wählen Minimum)", item_info$Prozent_Min))
    }

    cat("  Probleme:\n")
    for (problem in probleme) {
      cat(sprintf("    - %s\n", problem))
    }
    cat("\n")
  }
} else {
  print_section("✓ Keine problematischen Items identifiziert", 2)
  cat("Alle Items erfüllen die Mindestkriterien für Varianz und Wertebereich.\n\n")
}

# ------------------------------------------------------------------------------
# SCHRITT 5: Varianzstatistiken nach Skalen gruppiert
# ------------------------------------------------------------------------------

print_section("Varianzstatistiken gruppiert nach Skalen", 2)

for (skala_name in names(item_gruppen)) {
  items_skala <- varianz_analyse[varianz_analyse$Skala == skala_name, ]

  cat(sprintf("\n%s (%d Items):\n", skala_name, nrow(items_skala)))
  cat(paste(rep("-", 80), collapse = ""), "\n")

  # Mittelwerte der Statistiken
  m_sd <- mean(items_skala$SD, na.rm = TRUE)
  m_range <- mean(items_skala$Range, na.rm = TRUE)
  n_probleme <- sum(!items_skala$SD_Kriterium | !items_skala$Range_Kriterium |
    items_skala$Deckeneffekt | items_skala$Bodeneffekt)

  cat(sprintf("  Durchschnittliche SD:    %.2f\n", m_sd))
  cat(sprintf("  Durchschnittliche Range: %.2f\n", m_range))
  cat(sprintf("  Problematische Items:    %d von %d\n", n_probleme, nrow(items_skala)))

  if (n_probleme > 0) {
    cat("  Betroffene Items: ")
    problematische <- items_skala[!items_skala$SD_Kriterium | !items_skala$Range_Kriterium |
      items_skala$Deckeneffekt | items_skala$Bodeneffekt, ]
    cat(paste(problematische$Item, collapse = ", "))
    cat("\n")
  }
}

# ------------------------------------------------------------------------------
# SCHRITT 6: Empfehlungen für den Umgang mit Varianzproblemen
# ------------------------------------------------------------------------------

print_section("Empfehlungen für den Umgang mit Varianzproblemen", 2)

cat("Die Varianzanalyse hat Items mit unzureichender Streuung identifiziert.\n\n")

cat("WICHTIGE HINWEISE:\n")
cat("1. Items wurden NICHT automatisch entfernt\n")
cat("2. Geringe Varianz kann theoretisch bedeutsam sein (z.B. bei Extremgruppen)\n")
cat("3. Die Entscheidung sollte theoriegeleitet und transparent erfolgen\n\n")

cat("MÖGLICHE VORGEHENSWEISEN:\n")
cat("a) BEHALTEN: Wenn geringe Varianz theoretisch erwartet/bedeutsam ist\n")
cat("b) ENTFERNEN: Wenn Items keine Differenzierung ermöglichen\n")
cat("c) ZUSAMMENFASSEN: Items mit ähnlichen Problemen zu Subskalen kombinieren\n")
cat("d) SENSITIVITÄT: Reliabilitätsanalysen mit/ohne problematische Items\n\n")

if (n_problematisch > 0) {
  cat("EMPFEHLUNG FÜR DIESE ANALYSE:\n")
  cat(sprintf(
    "- %d von %d Items (%.1f%%) zeigen Varianzprobleme\n",
    n_problematisch, n_items_gesamt, 100 * n_problematisch / n_items_gesamt
  ))
  cat("- Prüfen Sie bei Reliabilitätsanalysen (03_reliability.R), ob diese Items\n")
  cat("  niedrige Trennschärfen aufweisen\n")
  cat("- Items mit geringer Varianz UND geringer Trennschärfe sollten entfernt werden\n")
  cat("- Dokumentieren Sie Ihre Entscheidung transparent im Methodenteil\n\n")
} else {
  cat("EMPFEHLUNG FÜR DIESE ANALYSE:\n")
  cat("- Keine Varianzprobleme identifiziert\n")
  cat("- Alle Items können in die Skalenkonstruktion einbezogen werden\n\n")
}

cat("✓ Varianzanalyse abgeschlossen\n")

# Speichere Varianzanalyse-Ergebnisse für spätere Verwendung
varianz_problematische_items <- items_problematisch$Item

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
# AUSREISSER-ANALYSE (OUTLIER DETECTION)
# ==============================================================================
#
# Diese Sektion führt eine umfassende Analyse von Ausreissern durch.
# Ausreisser können die statistischen Analysen verzerren und sollten identifiziert
# werden. Wir verwenden mehrere Methoden zur Ausreisser-Identifikation:
#
# 1. Z-Score-Methode (univariat)
#    - Basiert auf Standardabweichungen vom Mittelwert
#    - Schwellenwert: |z| > 3.29 (entspricht p < .001, zweiseitig)
#    - Geeignet für normalverteilte Daten
#
# 2. IQR-Methode (Interquartilsabstand, univariat)
#    - Robuster gegenüber Nicht-Normalverteilung
#    - Schwellenwert: Werte < Q1 - 1.5*IQR oder > Q3 + 1.5*IQR
#    - Basiert auf Boxplot-Konvention nach Tukey (1977)
#
# 3. Mahalanobis-Distanz (multivariat)
#    - Berücksichtigt Korrelationen zwischen Variablen
#    - Schwellenwert: Chi²-Verteilung mit p < .001
#    - Identifiziert multivariate Ausreisser
#
# WICHTIG: Ausreisser werden hier nur IDENTIFIZIERT, nicht automatisch entfernt.
# Die Entscheidung über den Umgang mit Ausreissern (Behalten, Winsorisieren,
# Entfernen) sollte theoriegeleitet und transparent erfolgen.
#
# ==============================================================================

print_section("AUSREISSER-ANALYSE")

# ------------------------------------------------------------------------------
# SCHRITT 1: Relevante Skalen für Ausreisser-Analyse definieren
# ------------------------------------------------------------------------------

# Wähle alle konstruierten Skalen aus (kontinuierliche Variablen)
skalen_namen <- c(
  "Alter",
  "Neurotizismus",
  "Resilienz",
  "Stressbelastung_gesamt",
  "Stressbelastung_kurz",
  "Stressbelastung_lang",
  "Stresssymptome_gesamt",
  "Stresssymptome_kurz",
  "Stresssymptome_lang",
  "Coping_aktiv",
  "Coping_Drogen",
  "Coping_positiv",
  "Coping_sozial",
  "Coping_rel",
  "Zufriedenheit"
)

# Für Mahalanobis-Distanz: Verwende nur Hauptskalen (ohne Subskalen)
# um Multikollinearität zu vermeiden
skalen_namen_mahal <- c(
  "Alter",
  "Neurotizismus",
  "Resilienz",
  "Stressbelastung_gesamt",
  "Stresssymptome_gesamt",
  "Coping_aktiv",
  "Coping_Drogen",
  "Coping_positiv",
  "Coping_sozial",
  "Coping_rel",
  "Zufriedenheit"
)

# Erstelle Dataframe nur mit den relevanten Skalen für die Analyse
skalen_data <- data[, skalen_namen]

cat("Analysierte Variablen:", length(skalen_namen), "\n")
cat("Variablen:", paste(skalen_namen, collapse = ", "), "\n\n")

# ------------------------------------------------------------------------------
# SCHRITT 2: Univariate Ausreisser-Analyse mit Z-Scores
# ------------------------------------------------------------------------------

print_section("2.1 Z-Score-Methode (|z| > 3.29)", 2)

# Z-Score-Schwellenwert (entspricht p < .001, zweiseitig)
z_schwellenwert <- 3.29

cat("Methode: Z-Score-Transformation\n")
cat("Schwellenwert: |z| >", z_schwellenwert, "\n")
cat(
  "Interpretation: Werte, die mehr als", z_schwellenwert,
  "Standardabweichungen vom\n               Mittelwert entfernt liegen\n\n"
)

# Berechne Z-Scores für alle Skalen
z_scores <- as.data.frame(scale(skalen_data))

# Identifiziere Ausreisser pro Variable
z_ausreisser_liste <- list()
z_ausreisser_gesamt <- rep(FALSE, nrow(data))

cat("Univariate Ausreisser pro Variable:\n")
cat(paste(rep("-", 80), collapse = ""), "\n")

for (var in skalen_namen) {
  # Identifiziere Ausreisser für diese Variable
  ausreisser_idx <- abs(z_scores[[var]]) > z_schwellenwert
  n_ausreisser <- sum(ausreisser_idx, na.rm = TRUE)

  # Speichere Ausreisser-Indices
  z_ausreisser_liste[[var]] <- which(ausreisser_idx)

  # Update Gesamt-Ausreisser-Vektor
  z_ausreisser_gesamt <- z_ausreisser_gesamt | ausreisser_idx

  # Ausgabe
  if (n_ausreisser > 0) {
    max_z <- max(abs(z_scores[[var]]), na.rm = TRUE)
    cat(sprintf(
      "%-30s: %2d Ausreisser (max |z| = %.2f)\n",
      var, n_ausreisser, max_z
    ))
  } else {
    cat(sprintf("%-30s: %2d Ausreisser\n", var, n_ausreisser))
  }
}

n_personen_z_ausreisser <- sum(z_ausreisser_gesamt, na.rm = TRUE)
cat(
  "\nGesamtanzahl Personen mit mindestens einem Z-Score-Ausreisser:",
  n_personen_z_ausreisser,
  sprintf("(%.1f%%)\n", 100 * n_personen_z_ausreisser / nrow(data))
)

# ------------------------------------------------------------------------------
# SCHRITT 3: Univariate Ausreisser-Analyse mit IQR-Methode
# ------------------------------------------------------------------------------

print_section("2.2 IQR-Methode (Interquartilsabstand)", 2)

cat("Methode: Interquartilsabstand (IQR = Q3 - Q1)\n")
cat("Schwellenwert: Werte < Q1 - 1.5*IQR oder > Q3 + 1.5*IQR\n")
cat("Interpretation: Werte ausserhalb der 'Whiskers' eines Boxplots\n\n")

# Identifiziere IQR-Ausreisser pro Variable
iqr_ausreisser_liste <- list()
iqr_ausreisser_gesamt <- rep(FALSE, nrow(data))

cat("Univariate Ausreisser pro Variable:\n")
cat(paste(rep("-", 80), collapse = ""), "\n")

for (var in skalen_namen) {
  werte <- skalen_data[[var]]

  # Berechne Quartile und IQR
  Q1 <- quantile(werte, 0.25, na.rm = TRUE)
  Q3 <- quantile(werte, 0.75, na.rm = TRUE)
  IQR_wert <- Q3 - Q1

  # Definiere Grenzen
  untere_grenze <- Q1 - 1.5 * IQR_wert
  obere_grenze <- Q3 + 1.5 * IQR_wert

  # Identifiziere Ausreisser
  ausreisser_idx <- werte < untere_grenze | werte > obere_grenze
  n_ausreisser <- sum(ausreisser_idx, na.rm = TRUE)

  # Speichere Ausreisser-Indices
  iqr_ausreisser_liste[[var]] <- which(ausreisser_idx)

  # Update Gesamt-Ausreisser-Vektor
  iqr_ausreisser_gesamt <- iqr_ausreisser_gesamt | ausreisser_idx

  # Ausgabe
  if (n_ausreisser > 0) {
    cat(sprintf(
      "%-30s: %2d Ausreisser [%.2f, %.2f]\n",
      var, n_ausreisser, untere_grenze, obere_grenze
    ))
  } else {
    cat(sprintf("%-30s: %2d Ausreisser\n", var, n_ausreisser))
  }
}

n_personen_iqr_ausreisser <- sum(iqr_ausreisser_gesamt, na.rm = TRUE)
cat(
  "\nGesamtanzahl Personen mit mindestens einem IQR-Ausreisser:",
  n_personen_iqr_ausreisser,
  sprintf("(%.1f%%)\n", 100 * n_personen_iqr_ausreisser / nrow(data))
)

# ------------------------------------------------------------------------------
# SCHRITT 4: Multivariate Ausreisser-Analyse (Mahalanobis-Distanz)
# ------------------------------------------------------------------------------

print_section("2.3 Mahalanobis-Distanz (multivariat)", 2)

cat("Methode: Mahalanobis-Distanz (berücksichtigt Korrelationen)\n")
cat("Schwellenwert: Chi²-Verteilung mit df = Anzahl Variablen, p < .001\n")
cat("Interpretation: Ungewöhnliche Kombination von Werten über Variablen hinweg\n")
cat("Hinweis: Verwendet nur Hauptskalen um Multikollinearität zu vermeiden\n\n")

# Entferne Zeilen mit fehlenden Werten für Mahalanobis-Berechnung
# Verwende nur Hauptskalen ohne Subskalen
skalen_data_mahal <- data[, skalen_namen_mahal]
skalen_data_komplett <- skalen_data_mahal[complete.cases(skalen_data_mahal), ]
n_komplett <- nrow(skalen_data_komplett)

cat("Verwendete Variablen:", length(skalen_namen_mahal), "\n")
cat("Vollständige Fälle für multivariate Analyse:", n_komplett, "\n")
cat("Ausgeschlossene Fälle (fehlende Werte):", nrow(data) - n_komplett, "\n\n")

# Berechne Mahalanobis-Distanz
if (n_komplett > 0) {
  # Mittelwerte und Kovarianzmatrix
  mittelwerte <- colMeans(skalen_data_komplett, na.rm = TRUE)
  kovarianz <- cov(skalen_data_komplett, use = "complete.obs")

  # Berechne Mahalanobis-Distanz für jeden Fall
  mahal_dist <- mahalanobis(
    x = skalen_data_komplett,
    center = mittelwerte,
    cov = kovarianz
  )

  # Chi²-Schwellenwert (df = Anzahl Variablen, p < .001)
  df <- length(skalen_namen_mahal)
  chi_schwellenwert <- qchisq(p = 0.999, df = df)

  cat("Freiheitsgrade (df):", df, "\n")
  cat("Chi²-Schwellenwert (p < .001):", round(chi_schwellenwert, 2), "\n\n")

  # Identifiziere multivariate Ausreisser
  mahal_ausreisser <- mahal_dist > chi_schwellenwert
  n_mahal_ausreisser <- sum(mahal_ausreisser)

  cat(
    "Anzahl multivariater Ausreisser:", n_mahal_ausreisser,
    sprintf("(%.1f%%)\n", 100 * n_mahal_ausreisser / n_komplett)
  )

  if (n_mahal_ausreisser > 0) {
    cat("\nTop 5 höchste Mahalanobis-Distanzen:\n")
    top_mahal <- sort(mahal_dist, decreasing = TRUE)[seq_len(min(5, length(mahal_dist)))]
    for (i in seq_along(top_mahal)) {
      cat(sprintf(
        "  %d. D² = %.2f %s\n",
        i,
        top_mahal[i],
        ifelse(top_mahal[i] > chi_schwellenwert, "(Ausreisser)", "")
      ))
    }
  }

  # Speichere Mahalanobis-Distanz im Dataframe
  data$Mahalanobis_Distanz <- NA
  data$Mahalanobis_Distanz[complete.cases(skalen_data_mahal)] <- mahal_dist
  data$Mahalanobis_Ausreisser <- data$Mahalanobis_Distanz > chi_schwellenwert
} else {
  cat("WARNUNG: Keine vollständigen Fälle für Mahalanobis-Distanz verfügbar.\n")
  data$Mahalanobis_Distanz <- NA
  data$Mahalanobis_Ausreisser <- FALSE
}

# ------------------------------------------------------------------------------
# SCHRITT 5: Zusammenfassung aller Ausreisser-Methoden
# ------------------------------------------------------------------------------

print_section("2.4 Zusammenfassung der Ausreisser-Identifikation", 2)

# Erstelle Übersichts-Variablen im Hauptdataframe
data$Z_Ausreisser <- z_ausreisser_gesamt
data$IQR_Ausreisser <- iqr_ausreisser_gesamt

# Zähle, wie viele Methoden jeden Fall als Ausreisser identifizieren
data$Anzahl_Ausreisser_Methoden <- (
  as.numeric(data$Z_Ausreisser) +
    as.numeric(data$IQR_Ausreisser) +
    as.numeric(data$Mahalanobis_Ausreisser)
)

# Identifiziere "konsistente" Ausreisser (von mindestens 2 Methoden identifiziert)
data$Konsistenter_Ausreisser <- data$Anzahl_Ausreisser_Methoden >= 2

cat("Übersicht der Ausreisser-Identifikation:\n")
cat(paste(rep("-", 80), collapse = ""), "\n")
cat(sprintf(
  "%-40s: %3d (%.1f%%)\n",
  "Z-Score-Methode",
  n_personen_z_ausreisser,
  100 * n_personen_z_ausreisser / nrow(data)
))
cat(sprintf(
  "%-40s: %3d (%.1f%%)\n",
  "IQR-Methode",
  n_personen_iqr_ausreisser,
  100 * n_personen_iqr_ausreisser / nrow(data)
))
cat(sprintf(
  "%-40s: %3d (%.1f%%)\n",
  "Mahalanobis-Distanz",
  sum(data$Mahalanobis_Ausreisser, na.rm = TRUE),
  100 * sum(data$Mahalanobis_Ausreisser, na.rm = TRUE) / nrow(data)
))

cat("\nKonsistenz der Ausreisser-Identifikation:\n")
cat(paste(rep("-", 80), collapse = ""), "\n")
ausreisser_tabelle <- table(data$Anzahl_Ausreisser_Methoden)
for (i in 0:3) {
  n <- ifelse(as.character(i) %in% names(ausreisser_tabelle),
    ausreisser_tabelle[as.character(i)],
    0
  )
  cat(sprintf(
    "Von %d Methode(n) als Ausreisser identifiziert: %3d (%.1f%%)\n",
    i, n, 100 * n / nrow(data)
  ))
}

n_konsistent <- sum(data$Konsistenter_Ausreisser, na.rm = TRUE)
cat(sprintf(
  "\nKonsistente Ausreisser (≥2 Methoden): %d (%.1f%%)\n",
  n_konsistent,
  100 * n_konsistent / nrow(data)
))

# ------------------------------------------------------------------------------
# SCHRITT 6: Detaillierte Ausreisser-Informationen ausgeben
# ------------------------------------------------------------------------------

print_section("2.5 Detaillierte Ausreisser-Liste", 2)

# Filtere Fälle, die von mindestens einer Methode als Ausreisser identifiziert wurden
ausreisser_faelle <- data[data$Anzahl_Ausreisser_Methoden > 0, ]

if (nrow(ausreisser_faelle) > 0) {
  cat(
    "Anzahl Fälle mit mindestens einer Ausreisser-Identifikation:",
    nrow(ausreisser_faelle), "\n\n"
  )

  cat("Hinweis: Die vollständige Liste wird nicht ausgegeben,\n")
  cat("         aber die Ausreisser-Variablen sind im Dataframe gespeichert:\n")
  cat("         - Z_Ausreisser (logisch)\n")
  cat("         - IQR_Ausreisser (logisch)\n")
  cat("         - Mahalanobis_Ausreisser (logisch)\n")
  cat("         - Mahalanobis_Distanz (numerisch)\n")
  cat("         - Anzahl_Ausreisser_Methoden (0-3)\n")
  cat("         - Konsistenter_Ausreisser (logisch, ≥2 Methoden)\n\n")

  # Zeige exemplarisch die ersten 5 konsistenten Ausreisser
  konsistente_ausreisser <- data[data$Konsistenter_Ausreisser == TRUE, ]
  if (nrow(konsistente_ausreisser) > 0) {
    cat("Beispiel: Erste 5 konsistente Ausreisser (identifiziert von ≥2 Methoden):\n")
    cat(paste(rep("-", 80), collapse = ""), "\n")

    beispiel_df <- head(konsistente_ausreisser[, c(
      "VPN_Code", "Alter",
      "Z_Ausreisser", "IQR_Ausreisser", "Mahalanobis_Ausreisser",
      "Anzahl_Ausreisser_Methoden"
    )], 5)
    print(beispiel_df, row.names = FALSE)
  }
} else {
  cat("Keine Ausreisser identifiziert.\n")
}

# ------------------------------------------------------------------------------
# SCHRITT 7: Empfehlungen für den Umgang mit Ausreissern
# ------------------------------------------------------------------------------

print_section("2.6 Empfehlungen für den Umgang mit Ausreissern", 2)

cat("Die Ausreisser-Analyse hat potenzielle Ausreisser identifiziert.\n\n")

cat("WICHTIGE HINWEISE:\n")
cat("1. Ausreisser wurden NICHT automatisch entfernt\n")
cat("2. Die Entscheidung über den Umgang mit Ausreissern sollte\n")
cat("   theoriegeleitet und transparent dokumentiert werden\n\n")

cat("MÖGLICHE VORGEHENSWEISEN:\n")
cat("a) BEHALTEN: Wenn Ausreisser valide Messungen extremer Ausprägungen sind\n")
cat("b) WINSORISIEREN: Extreme Werte auf einen bestimmten Perzentilwert setzen\n")
cat("c) TRANSFORMIEREN: Log- oder andere Transformationen anwenden\n")
cat("d) ROBUSTE METHODEN: Robuste statistische Verfahren verwenden\n")
cat("e) ENTFERNEN: Nur wenn klare Hinweise auf Messfehler vorliegen\n\n")

cat("EMPFEHLUNG FÜR DIESE ANALYSE:\n")
cat("- Prüfen Sie konsistente Ausreisser (≥2 Methoden) genauer\n")
cat("- Führen Sie Sensitivitätsanalysen durch (mit/ohne Ausreisser)\n")
cat("- Berichten Sie transparent über gefundene Ausreisser\n")
cat("- Dokumentieren Sie Ihre Entscheidung im Methodenteil\n\n")

if (n_konsistent > 0) {
  cat("NÄCHSTE SCHRITTE:\n")
  cat("- Verwenden Sie 'data[data$Konsistenter_Ausreisser == FALSE, ]'\n")
  cat("  um Analysen ohne konsistente Ausreisser durchzuführen\n")
  cat("- Vergleichen Sie Ergebnisse mit und ohne Ausreisser\n\n")
}

cat("✓ Ausreisser-Analyse abgeschlossen\n")
cat("✓ Ausreisser-Variablen im Dataframe 'data' gespeichert\n")

# ==============================================================================
# WORKSPACE SPEICHERN
# ==============================================================================

print_section("WORKSPACE SPEICHERN")

# Speichere Workspace für nachfolgende Skripte
save(
  data,
  print_section, # Hilfsfunktion wird auch gespeichert
  fisher_z_test, # Fisher's Z-Test für Subgruppenanalysen
  file = WORKSPACE_FILE
)

cat("✓ Workspace gespeichert als:", WORKSPACE_FILE, "\n")
cat("\nDieser Workspace wird von allen nachfolgenden Skripten geladen.\n")
cat("Führen Sie als nächstes aus:\n")
cat("  - 02_descriptive_plots.R\n")
cat("  - 03_reliability.R\n")
cat("  - 04_validity_main.R\n")
cat("  - 05_validity_subgroups.R\n\n")
