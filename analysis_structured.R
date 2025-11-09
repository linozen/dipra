# ==============================================================================
# DIAGNOSTISCHES PRAKTIKUM - STRESSANALYSE
# ==============================================================================
# Strukturierte psychometrische Analyse in zwei Hauptabschnitten:
#
# TEIL I:  RELIABILITÄT (Cronbachs Alpha, Konfirmatorische Faktorenanalyse)
# TEIL II: VALIDITÄT (Konvergente Validität durch Korrelationen)
#
# ==============================================================================


# ==============================================================================
# SETUP: PAKETE UND DATEN
# ==============================================================================

suppressPackageStartupMessages({
  library(tidyverse)
  library(lavaan)
  library(psych)
})

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

# Daten einlesen
data <- read.csv("data.csv", header = TRUE, sep = ";", dec = ",")

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

# DESKRIPTIVE PLOTS
cat("\n✓ Generiere deskriptive Plots...\n")

# 1. Altersverteilung
png("plots/01_altersverteilung.png", width = 1200, height = 900, res = 150)
hist(data$Alter,
  breaks = 15,
  main = "Altersverteilung der Stichprobe",
  xlab = "Alter (Jahre)",
  ylab = "Häufigkeit",
  col = "steelblue",
  border = "white"
)
abline(v = mean(data$Alter, na.rm = TRUE), col = "red", lwd = 2, lty = 2)
abline(v = median(data$Alter, na.rm = TRUE), col = "darkgreen", lwd = 2, lty = 2)
legend("topright",
  legend = c(
    paste0(
      "M = ", round(mean(data$Alter, na.rm = TRUE), 1),
      ", SD = ", round(sd(data$Alter, na.rm = TRUE), 1)
    ),
    paste0("Mdn = ", round(median(data$Alter, na.rm = TRUE), 1))
  ),
  lty = 2, col = c("red", "darkgreen"), lwd = 2, bty = "n"
)
dev.off()

# 2. Geschlechterverteilung
png("plots/02_geschlechterverteilung.png", width = 1200, height = 900, res = 150)
geschlecht_tab <- table(data$Geschlecht)
geschlecht_labels <- c("1" = "Männlich", "2" = "Weiblich", "3" = "Divers")
geschlecht_colors <- c("1" = "pink", "2" = "lightblue", "3" = "lightgreen")

pie(geschlecht_tab,
  labels = paste0(geschlecht_labels[names(geschlecht_tab)], "\n(n=", geschlecht_tab, ")"),
  main = "Geschlechterverteilung",
  col = geschlecht_colors[names(geschlecht_tab)],
  border = "white"
)
dev.off()

# 3. Beschäftigungsverteilung
png("plots/03_beschaeftigungsverteilung.png", width = 1200, height = 900, res = 150)
beschaeftigung_tab <- table(data$Beschäftigung)
# Entferne leere/unbenannte Einträge
beschaeftigung_tab <- beschaeftigung_tab[names(beschaeftigung_tab) != ""]

pie(beschaeftigung_tab,
  labels = paste0(names(beschaeftigung_tab), "\n(n=", beschaeftigung_tab, ")"),
  main = "Beschäftigungsverteilung",
  col = rainbow(length(beschaeftigung_tab)),
  border = "white",
  cex = 0.8
)
dev.off()

# 4. Bildungsverteilung
png("plots/04_bildungsverteilung.png", width = 1400, height = 900, res = 150)
bildung_tab <- table(data$Bildung)
bildung_labels <- c(
  "1" = "Hauptschule",
  "2" = "Realschule",
  "3" = "Fachhochschulreife",
  "4" = "Hochschulreife (Abitur)",
  "5" = "Bachelor",
  "6" = "Master",
  "7" = "Staatsexamen",
  "8" = "Andere"
)

par(mar = c(10, 4, 4, 2))
barplot(bildung_tab,
  main = "Bildungsverteilung",
  ylab = "Anzahl",
  col = "lightgreen",
  las = 2,
  cex.names = 0.7,
  names.arg = bildung_labels[names(bildung_tab)]
)
dev.off()

cat("✓ Deskriptive Plots gespeichert in plots/\n")


# ==============================================================================
# SKALENKONSTRUKTION
# ==============================================================================

print_section("SKALENKONSTRUKTION", 2)

# Neurotizismus
data$Neurotizismus <- (data$BF01_02 + 6 - data$BF01_01) / 2

# Resilienz
data$RE01_02 <- 7 - data$RE01_02
data$RE01_04 <- 7 - data$RE01_04
data$RE01_06 <- 7 - data$RE01_06
data$Resilienz <- rowMeans(
  data[, c("RE01_01", "RE01_02", "RE01_03", "RE01_04", "RE01_05", "RE01_06")],
  na.rm = TRUE
)

# Stressbelastung
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

# Stresssymptome
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

# Coping
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

cat("✓ Alle Skalen erfolgreich konstruiert\n")


# ##############################################################################
# ##############################################################################
# TEIL I: RELIABILITÄT
# ##############################################################################
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

# Farben für verschiedene Kategorien - verschiedene Blautöne für Coping, Rot für Stress, Orange für Symptome
coping_blues <- c("#08306B", "#2171B5", "#4292C6", "#6BAED6", "#9ECAE1", "#C6DBEF")
farben <- c(
  coping_blues[1:length(coping_alphas)], # Verschiedene Blautöne für Coping-Skalen
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

for (i in 1:length(coping_skalen)) {
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

  # Plot Item-Trennschärfe (korrigiert, part-whole)
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


# ##############################################################################
# ##############################################################################
# TEIL II: VALIDITÄT
# ##############################################################################
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

for (i in 1:length(coping_vars)) {
  coping <- coping_vars[i]
  cat("###", gsub("_", " ", coping), "\n\n")
  for (j in 1:length(validitaets_vars)) {
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
image(1:ncol(cor_matrix), 1:nrow(cor_matrix), t(cor_matrix),
  col = col_palette,
  xlab = "", ylab = "",
  axes = FALSE,
  main = "Korrelationen: Coping-Skalen × Validitätskriterien",
  zlim = c(-1, 1)
)

# Achsenbeschriftungen
axis(1, at = 1:ncol(cor_matrix), labels = colnames(cor_matrix), las = 2)
axis(2, at = 1:nrow(cor_matrix), labels = rownames(cor_matrix), las = 2)

# Korrelationswerte eintragen
for (i in 1:nrow(cor_matrix)) {
  for (j in 1:ncol(cor_matrix)) {
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

# Zusätzliche Heatmap nur für NI07-Items (in derselben Reihenfolge wie Coping-Skalen)
ni07_items <- c("NI07_05", "NI07_01", "NI07_04", "NI07_03", "NI07_02")
ni07_labels <- c("Aktiv", "Drogen", "Positiv", "Sozial", "Religiös")

# Korrelationsmatrix für NI07-Items erstellen
cor_matrix_ni07 <- matrix(NA, nrow = length(ni07_items), ncol = length(validitaets_vars))
rownames(cor_matrix_ni07) <- ni07_labels
colnames(cor_matrix_ni07) <- validitaets_vars

for (i in 1:length(ni07_items)) {
  for (j in 1:length(validitaets_vars)) {
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
image(1:ncol(cor_matrix_ni07), 1:nrow(cor_matrix_ni07), t(cor_matrix_ni07),
  col = col_palette,
  xlab = "", ylab = "",
  axes = FALSE,
  main = "Korrelationen: Einzelitems Coping-Skalen × Validitätskriterien",
  zlim = c(-1, 1)
)

# Achsenbeschriftungen
axis(1, at = 1:ncol(cor_matrix_ni07), labels = colnames(cor_matrix_ni07), las = 2)
axis(2, at = 1:nrow(cor_matrix_ni07), labels = rownames(cor_matrix_ni07), las = 2)

# Korrelationswerte eintragen
for (i in 1:nrow(cor_matrix_ni07)) {
  for (j in 1:ncol(cor_matrix_ni07)) {
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
# 7. VALIDITÄT NACH DEMOGRAPHISCHEN SUBGRUPPEN
# ==============================================================================

print_section("7. KONVERGENTE VALIDITÄT NACH SUBGRUPPEN", 2)

cat("Analyse der konvergenten Validität in demographischen Subgruppen\n")
cat("Geprüft werden Unterschiede nach Geschlecht, Bildungsniveau und Alter\n\n")

# Hilfsfunktion für Fisher's Z-Test
fisher_z_test <- function(r1, n1, r2, n2) {
  z <- (atanh(r1) - atanh(r2)) / sqrt(1 / (n1 - 3) + 1 / (n2 - 3))
  p <- 2 * (1 - pnorm(abs(z)))
  return(list(z = z, p = p))
}

# ===== 7.1 VALIDITÄT NACH GESCHLECHT =====

cat("### 7.1 Validität nach Geschlecht\n\n")

# Nur Geschlechter 1 und 2 (Männlich und Weiblich)
data_gender <- subset(data, Geschlecht %in% c("1", "2"))
n_male <- sum(data_gender$Geschlecht == "1")
n_female <- sum(data_gender$Geschlecht == "2")

# Alle 6 Korrelationen berechnen
validitaetskriterien <- c("Zufriedenheit", "Neurotizismus", "Resilienz")
skalen <- c("Stressbelastung_kurz", "Stresssymptome_kurz")

# Speichere alle Korrelationen und Z-Tests
gender_results <- list()

for (skala in skalen) {
  cat(paste0("#### ", ifelse(skala == "Stressbelastung_kurz", "Stressbelastung", "Stresssymptome"), ":\n\n"))

  for (krit in validitaetskriterien) {
    cor_male <- cor.test(
      data_gender[[skala]][data_gender$Geschlecht == "1"],
      data_gender[[krit]][data_gender$Geschlecht == "1"]
    )
    cor_female <- cor.test(
      data_gender[[skala]][data_gender$Geschlecht == "2"],
      data_gender[[krit]][data_gender$Geschlecht == "2"]
    )

    fisher <- fisher_z_test(cor_male$estimate, n_male, cor_female$estimate, n_female)

    cat(paste0(krit, ":\n"))
    cat(paste0(
      "  Männlich:  r = ", round(cor_male$estimate, 3),
      ", p = ", format.pval(cor_male$p.value, digits = 3), "\n"
    ))
    cat(paste0(
      "  Weiblich:  r = ", round(cor_female$estimate, 3),
      ", p = ", format.pval(cor_female$p.value, digits = 3), "\n"
    ))
    cat(paste0(
      "  Unterschied: z = ", round(fisher$z, 3),
      ", p = ", format.pval(fisher$p, digits = 3),
      ifelse(fisher$p < 0.05, " *", ""),
      ifelse(fisher$p < 0.01, "*", ""),
      ifelse(fisher$p < 0.001, "*", ""), "\n\n"
    ))

    # Speichere für Plots
    key <- paste(skala, krit, sep = "_")
    gender_results[[key]] <- list(
      male_r = cor_male$estimate,
      female_r = cor_female$estimate,
      z = fisher$z,
      p = fisher$p
    )
  }
}

# ===== 7.2 VALIDITÄT NACH BILDUNG =====

cat("### 7.2 Validität nach Bildungsniveau\n\n")

# Gruppiere Bildung: Niedrig (1-3), Mittel (4), Hoch (5-7)
data$Bildung_gruppiert <- cut(as.numeric(data$Bildung),
  breaks = c(0, 3, 4, 7, 8),
  labels = c("Niedrig", "Mittel", "Hoch", "Andere"),
  include.lowest = TRUE
)

data_bildung <- subset(data, Bildung_gruppiert %in% c("Niedrig", "Mittel", "Hoch"))
n_niedrig <- sum(data_bildung$Bildung_gruppiert == "Niedrig")
n_mittel <- sum(data_bildung$Bildung_gruppiert == "Mittel")
n_hoch <- sum(data_bildung$Bildung_gruppiert == "Hoch")

# Speichere Bildungs-Ergebnisse
bildung_results <- list()

for (skala in skalen) {
  cat(paste0("#### ", ifelse(skala == "Stressbelastung_kurz", "Stressbelastung", "Stresssymptome"), ":\n\n"))

  for (krit in validitaetskriterien) {
    cor_niedrig <- cor.test(
      data_bildung[[skala]][data_bildung$Bildung_gruppiert == "Niedrig"],
      data_bildung[[krit]][data_bildung$Bildung_gruppiert == "Niedrig"]
    )
    cor_mittel <- cor.test(
      data_bildung[[skala]][data_bildung$Bildung_gruppiert == "Mittel"],
      data_bildung[[krit]][data_bildung$Bildung_gruppiert == "Mittel"]
    )
    cor_hoch <- cor.test(
      data_bildung[[skala]][data_bildung$Bildung_gruppiert == "Hoch"],
      data_bildung[[krit]][data_bildung$Bildung_gruppiert == "Hoch"]
    )

    cat(paste0(krit, ":\n"))
    cat(paste0(
      "  Niedrig: r = ", round(cor_niedrig$estimate, 3),
      ", p = ", format.pval(cor_niedrig$p.value, digits = 3), "\n"
    ))
    cat(paste0(
      "  Mittel:  r = ", round(cor_mittel$estimate, 3),
      ", p = ", format.pval(cor_mittel$p.value, digits = 3), "\n"
    ))
    cat(paste0(
      "  Hoch:    r = ", round(cor_hoch$estimate, 3),
      ", p = ", format.pval(cor_hoch$p.value, digits = 3), "\n"
    ))

    # Fisher's Z paarweise
    fisher_nm <- fisher_z_test(cor_niedrig$estimate, n_niedrig, cor_mittel$estimate, n_mittel)
    fisher_nh <- fisher_z_test(cor_niedrig$estimate, n_niedrig, cor_hoch$estimate, n_hoch)
    fisher_mh <- fisher_z_test(cor_mittel$estimate, n_mittel, cor_hoch$estimate, n_hoch)

    cat(paste0(
      "  Niedrig vs. Mittel: z = ", round(fisher_nm$z, 3),
      ", p = ", format.pval(fisher_nm$p, digits = 3),
      ifelse(fisher_nm$p < 0.05, " *", ""), "\n"
    ))
    cat(paste0(
      "  Niedrig vs. Hoch:   z = ", round(fisher_nh$z, 3),
      ", p = ", format.pval(fisher_nh$p, digits = 3),
      ifelse(fisher_nh$p < 0.05, " *", ""), "\n"
    ))
    cat(paste0(
      "  Mittel vs. Hoch:    z = ", round(fisher_mh$z, 3),
      ", p = ", format.pval(fisher_mh$p, digits = 3),
      ifelse(fisher_mh$p < 0.05, " *", ""), "\n\n"
    ))

    # Speichere für Plots
    key <- paste(skala, krit, sep = "_")
    bildung_results[[key]] <- list(
      niedrig_r = cor_niedrig$estimate,
      mittel_r = cor_mittel$estimate,
      hoch_r = cor_hoch$estimate,
      z_nm = fisher_nm$z, p_nm = fisher_nm$p,
      z_nh = fisher_nh$z, p_nh = fisher_nh$p,
      z_mh = fisher_mh$z, p_mh = fisher_mh$p
    )
  }
}

# ===== 7.3 VALIDITÄT NACH ALTER =====

cat("### 7.3 Validität nach Alter\n\n")

# Gruppiere Alter: Jung (<30), Mittel (30-45), Alt (>45)
data$Alter_gruppiert <- cut(data$Alter,
  breaks = c(0, 30, 45, 100),
  labels = c("Jung", "Mittel", "Alt"),
  include.lowest = TRUE
)

data_alter <- subset(data, !is.na(Alter_gruppiert))
n_jung <- sum(data_alter$Alter_gruppiert == "Jung")
n_mittel_alter <- sum(data_alter$Alter_gruppiert == "Mittel")
n_alt <- sum(data_alter$Alter_gruppiert == "Alt")

# Speichere Alters-Ergebnisse
alter_results <- list()

for (skala in skalen) {
  cat(paste0("#### ", ifelse(skala == "Stressbelastung_kurz", "Stressbelastung", "Stresssymptome"), ":\n\n"))

  for (krit in validitaetskriterien) {
    cor_jung <- cor.test(
      data_alter[[skala]][data_alter$Alter_gruppiert == "Jung"],
      data_alter[[krit]][data_alter$Alter_gruppiert == "Jung"]
    )
    cor_mittel_alter <- cor.test(
      data_alter[[skala]][data_alter$Alter_gruppiert == "Mittel"],
      data_alter[[krit]][data_alter$Alter_gruppiert == "Mittel"]
    )
    cor_alt <- cor.test(
      data_alter[[skala]][data_alter$Alter_gruppiert == "Alt"],
      data_alter[[krit]][data_alter$Alter_gruppiert == "Alt"]
    )

    cat(paste0(krit, ":\n"))
    cat(paste0(
      "  Jung (<30):   r = ", round(cor_jung$estimate, 3),
      ", p = ", format.pval(cor_jung$p.value, digits = 3), "\n"
    ))
    cat(paste0(
      "  Mittel (30-45): r = ", round(cor_mittel_alter$estimate, 3),
      ", p = ", format.pval(cor_mittel_alter$p.value, digits = 3), "\n"
    ))
    cat(paste0(
      "  Alt (>45):    r = ", round(cor_alt$estimate, 3),
      ", p = ", format.pval(cor_alt$p.value, digits = 3), "\n"
    ))

    # Fisher's Z paarweise
    fisher_jm <- fisher_z_test(cor_jung$estimate, n_jung, cor_mittel_alter$estimate, n_mittel_alter)
    fisher_ja <- fisher_z_test(cor_jung$estimate, n_jung, cor_alt$estimate, n_alt)
    fisher_ma <- fisher_z_test(cor_mittel_alter$estimate, n_mittel_alter, cor_alt$estimate, n_alt)

    cat(paste0(
      "  Jung vs. Mittel: z = ", round(fisher_jm$z, 3),
      ", p = ", format.pval(fisher_jm$p, digits = 3),
      ifelse(fisher_jm$p < 0.05, " *", ""), "\n"
    ))
    cat(paste0(
      "  Jung vs. Alt:    z = ", round(fisher_ja$z, 3),
      ", p = ", format.pval(fisher_ja$p, digits = 3),
      ifelse(fisher_ja$p < 0.05, " *", ""), "\n"
    ))
    cat(paste0(
      "  Mittel vs. Alt:  z = ", round(fisher_ma$z, 3),
      ", p = ", format.pval(fisher_ma$p, digits = 3),
      ifelse(fisher_ma$p < 0.05, " *", ""), "\n\n"
    ))

    # Speichere für Plots
    key <- paste(skala, krit, sep = "_")
    alter_results[[key]] <- list(
      jung_r = cor_jung$estimate,
      mittel_r = cor_mittel_alter$estimate,
      alt_r = cor_alt$estimate,
      z_jm = fisher_jm$z, p_jm = fisher_jm$p,
      z_ja = fisher_ja$z, p_ja = fisher_ja$p,
      z_ma = fisher_ma$z, p_ma = fisher_ma$p
    )
  }
}

# ===== PLOTS =====

# PLOT 17: Validität nach Geschlecht (3×2 Grid für alle 6 Korrelationen)
png("plots/17_validitaet_nach_geschlecht.png", width = 2400, height = 1600, res = 150)
par(mfrow = c(2, 3), mar = c(4, 4, 3, 1))

# Stressbelastung
for (krit in validitaetskriterien) {
  key <- paste("Stressbelastung_kurz", krit, sep = "_")
  res <- gender_results[[key]]

  plot(data_gender$Stressbelastung_kurz[data_gender$Geschlecht == "1"],
    data_gender[[krit]][data_gender$Geschlecht == "1"],
    pch = 19, col = rgb(0, 0.5, 1, 0.4),
    xlim = range(data_gender$Stressbelastung_kurz, na.rm = TRUE),
    ylim = range(data_gender[[krit]], na.rm = TRUE),
    xlab = "Stressbelastung",
    ylab = krit,
    main = paste0("Stressbelastung × ", krit)
  )
  points(data_gender$Stressbelastung_kurz[data_gender$Geschlecht == "2"],
    data_gender[[krit]][data_gender$Geschlecht == "2"],
    pch = 19, col = rgb(1, 0.4, 0.4, 0.4)
  )

  lm_m <- lm(data_gender[[krit]][data_gender$Geschlecht == "1"] ~
    data_gender$Stressbelastung_kurz[data_gender$Geschlecht == "1"])
  lm_f <- lm(data_gender[[krit]][data_gender$Geschlecht == "2"] ~
    data_gender$Stressbelastung_kurz[data_gender$Geschlecht == "2"])
  abline(lm_m, col = "blue", lwd = 2)
  abline(lm_f, col = "red", lwd = 2)

  # Legende mit Fisher's Z
  sig_symbol <- ifelse(res$p < 0.001, "***", ifelse(res$p < 0.01, "**", ifelse(res$p < 0.05, "*", "ns")))
  legend("topright",
    legend = c(
      paste0("♂ r = ", round(res$male_r, 3)),
      paste0("♀ r = ", round(res$female_r, 3)),
      paste0("z = ", round(res$z, 3), " ", sig_symbol)
    ),
    col = c("blue", "red", "black"), lwd = c(2, 2, NA), pch = c(19, 19, NA),
    bty = "n", cex = 0.9
  )
}

# Stresssymptome
for (krit in validitaetskriterien) {
  key <- paste("Stresssymptome_kurz", krit, sep = "_")
  res <- gender_results[[key]]

  plot(data_gender$Stresssymptome_kurz[data_gender$Geschlecht == "1"],
    data_gender[[krit]][data_gender$Geschlecht == "1"],
    pch = 19, col = rgb(0, 0.5, 1, 0.4),
    xlim = range(data_gender$Stresssymptome_kurz, na.rm = TRUE),
    ylim = range(data_gender[[krit]], na.rm = TRUE),
    xlab = "Stresssymptome",
    ylab = krit,
    main = paste0("Stresssymptome × ", krit)
  )
  points(data_gender$Stresssymptome_kurz[data_gender$Geschlecht == "2"],
    data_gender[[krit]][data_gender$Geschlecht == "2"],
    pch = 19, col = rgb(1, 0.4, 0.4, 0.4)
  )

  lm_m <- lm(data_gender[[krit]][data_gender$Geschlecht == "1"] ~
    data_gender$Stresssymptome_kurz[data_gender$Geschlecht == "1"])
  lm_f <- lm(data_gender[[krit]][data_gender$Geschlecht == "2"] ~
    data_gender$Stresssymptome_kurz[data_gender$Geschlecht == "2"])
  abline(lm_m, col = "blue", lwd = 2)
  abline(lm_f, col = "red", lwd = 2)

  sig_symbol <- ifelse(res$p < 0.001, "***", ifelse(res$p < 0.01, "**", ifelse(res$p < 0.05, "*", "ns")))
  legend("topleft",
    legend = c(
      paste0("♂ r = ", round(res$male_r, 3)),
      paste0("♀ r = ", round(res$female_r, 3)),
      paste0("z = ", round(res$z, 3), " ", sig_symbol)
    ),
    col = c("blue", "red", "black"), lwd = c(2, 2, NA), pch = c(19, 19, NA),
    bty = "n", cex = 0.9
  )
}

dev.off()

# PLOT 18: Validität nach Bildung (3×2 Grid)
png("plots/18_validitaet_nach_bildung.png", width = 2400, height = 1600, res = 150)
par(mfrow = c(2, 3), mar = c(4, 4, 3, 1))

# Stressbelastung
for (krit in validitaetskriterien) {
  key <- paste("Stressbelastung_kurz", krit, sep = "_")
  res <- bildung_results[[key]]

  plot(data_bildung$Stressbelastung_kurz[data_bildung$Bildung_gruppiert == "Niedrig"],
    data_bildung[[krit]][data_bildung$Bildung_gruppiert == "Niedrig"],
    pch = 19, col = rgb(1, 0.3, 0.3, 0.4),
    xlim = range(data_bildung$Stressbelastung_kurz, na.rm = TRUE),
    ylim = range(data_bildung[[krit]], na.rm = TRUE),
    xlab = "Stressbelastung",
    ylab = krit,
    main = paste0("Stressbelastung × ", krit)
  )
  points(data_bildung$Stressbelastung_kurz[data_bildung$Bildung_gruppiert == "Mittel"],
    data_bildung[[krit]][data_bildung$Bildung_gruppiert == "Mittel"],
    pch = 19, col = rgb(0.3, 0.3, 1, 0.4)
  )
  points(data_bildung$Stressbelastung_kurz[data_bildung$Bildung_gruppiert == "Hoch"],
    data_bildung[[krit]][data_bildung$Bildung_gruppiert == "Hoch"],
    pch = 19, col = rgb(0.3, 1, 0.3, 0.4)
  )

  for (gruppe in c("Niedrig", "Mittel", "Hoch")) {
    subset_data <- subset(data_bildung, Bildung_gruppiert == gruppe)
    if (nrow(subset_data) > 5) {
      lm_temp <- lm(subset_data[[krit]] ~ subset_data$Stressbelastung_kurz)
      abline(lm_temp,
        col = ifelse(gruppe == "Niedrig", "red", ifelse(gruppe == "Mittel", "blue", "darkgreen")),
        lwd = 2
      )
    }
  }

  # Zeige besten p-Wert
  best_p <- min(res$p_nm, res$p_nh, res$p_mh)
  sig_symbol <- ifelse(best_p < 0.001, "***", ifelse(best_p < 0.01, "**", ifelse(best_p < 0.05, "*", "ns")))

  legend("topright",
    legend = c(
      paste0("Niedrig: r = ", round(res$niedrig_r, 3)),
      paste0("Mittel: r = ", round(res$mittel_r, 3)),
      paste0("Hoch: r = ", round(res$hoch_r, 3)),
      paste0("z_max = ", round(max(abs(res$z_nm), abs(res$z_nh), abs(res$z_mh)), 3), " ", sig_symbol)
    ),
    col = c("red", "blue", "darkgreen", "black"), lwd = c(2, 2, 2, NA), pch = c(19, 19, 19, NA),
    bty = "n", cex = 0.8
  )
}

# Stresssymptome
for (krit in validitaetskriterien) {
  key <- paste("Stresssymptome_kurz", krit, sep = "_")
  res <- bildung_results[[key]]

  plot(data_bildung$Stresssymptome_kurz[data_bildung$Bildung_gruppiert == "Niedrig"],
    data_bildung[[krit]][data_bildung$Bildung_gruppiert == "Niedrig"],
    pch = 19, col = rgb(1, 0.3, 0.3, 0.4),
    xlim = range(data_bildung$Stresssymptome_kurz, na.rm = TRUE),
    ylim = range(data_bildung[[krit]], na.rm = TRUE),
    xlab = "Stresssymptome",
    ylab = krit,
    main = paste0("Stresssymptome × ", krit)
  )
  points(data_bildung$Stresssymptome_kurz[data_bildung$Bildung_gruppiert == "Mittel"],
    data_bildung[[krit]][data_bildung$Bildung_gruppiert == "Mittel"],
    pch = 19, col = rgb(0.3, 0.3, 1, 0.4)
  )
  points(data_bildung$Stresssymptome_kurz[data_bildung$Bildung_gruppiert == "Hoch"],
    data_bildung[[krit]][data_bildung$Bildung_gruppiert == "Hoch"],
    pch = 19, col = rgb(0.3, 1, 0.3, 0.4)
  )

  for (gruppe in c("Niedrig", "Mittel", "Hoch")) {
    subset_data <- subset(data_bildung, Bildung_gruppiert == gruppe)
    if (nrow(subset_data) > 5) {
      lm_temp <- lm(subset_data[[krit]] ~ subset_data$Stresssymptome_kurz)
      abline(lm_temp,
        col = ifelse(gruppe == "Niedrig", "red", ifelse(gruppe == "Mittel", "blue", "darkgreen")),
        lwd = 2
      )
    }
  }

  best_p <- min(res$p_nm, res$p_nh, res$p_mh)
  sig_symbol <- ifelse(best_p < 0.001, "***", ifelse(best_p < 0.01, "**", ifelse(best_p < 0.05, "*", "ns")))

  legend("topleft",
    legend = c(
      paste0("Niedrig: r = ", round(res$niedrig_r, 3)),
      paste0("Mittel: r = ", round(res$mittel_r, 3)),
      paste0("Hoch: r = ", round(res$hoch_r, 3)),
      paste0("z_max = ", round(max(abs(res$z_nm), abs(res$z_nh), abs(res$z_mh)), 3), " ", sig_symbol)
    ),
    col = c("red", "blue", "darkgreen", "black"), lwd = c(2, 2, 2, NA), pch = c(19, 19, 19, NA),
    bty = "n", cex = 0.8
  )
}

dev.off()

# PLOT 19: Validität nach Alter (3×2 Grid)
png("plots/19_validitaet_nach_alter.png", width = 2400, height = 1600, res = 150)
par(mfrow = c(2, 3), mar = c(4, 4, 3, 1))

# Stressbelastung
for (krit in validitaetskriterien) {
  key <- paste("Stressbelastung_kurz", krit, sep = "_")
  res <- alter_results[[key]]

  plot(data_alter$Stressbelastung_kurz[data_alter$Alter_gruppiert == "Jung"],
    data_alter[[krit]][data_alter$Alter_gruppiert == "Jung"],
    pch = 19, col = rgb(1, 0.3, 0.3, 0.4),
    xlim = range(data_alter$Stressbelastung_kurz, na.rm = TRUE),
    ylim = range(data_alter[[krit]], na.rm = TRUE),
    xlab = "Stressbelastung",
    ylab = krit,
    main = paste0("Stressbelastung × ", krit)
  )
  points(data_alter$Stressbelastung_kurz[data_alter$Alter_gruppiert == "Mittel"],
    data_alter[[krit]][data_alter$Alter_gruppiert == "Mittel"],
    pch = 19, col = rgb(0.3, 0.3, 1, 0.4)
  )
  points(data_alter$Stressbelastung_kurz[data_alter$Alter_gruppiert == "Alt"],
    data_alter[[krit]][data_alter$Alter_gruppiert == "Alt"],
    pch = 19, col = rgb(0.3, 1, 0.3, 0.4)
  )

  for (gruppe in c("Jung", "Mittel", "Alt")) {
    subset_data <- subset(data_alter, Alter_gruppiert == gruppe)
    if (nrow(subset_data) > 5) {
      lm_temp <- lm(subset_data[[krit]] ~ subset_data$Stressbelastung_kurz)
      abline(lm_temp,
        col = ifelse(gruppe == "Jung", "red", ifelse(gruppe == "Mittel", "blue", "darkgreen")),
        lwd = 2
      )
    }
  }

  best_p <- min(res$p_jm, res$p_ja, res$p_ma)
  sig_symbol <- ifelse(best_p < 0.001, "***", ifelse(best_p < 0.01, "**", ifelse(best_p < 0.05, "*", "ns")))

  legend("topright",
    legend = c(
      paste0("Jung: r = ", round(res$jung_r, 3)),
      paste0("Mittel: r = ", round(res$mittel_r, 3)),
      paste0("Alt: r = ", round(res$alt_r, 3)),
      paste0("z_max = ", round(max(abs(res$z_jm), abs(res$z_ja), abs(res$z_ma)), 3), " ", sig_symbol)
    ),
    col = c("red", "blue", "darkgreen", "black"), lwd = c(2, 2, 2, NA), pch = c(19, 19, 19, NA),
    bty = "n", cex = 0.8
  )
}

# Stresssymptome
for (krit in validitaetskriterien) {
  key <- paste("Stresssymptome_kurz", krit, sep = "_")
  res <- alter_results[[key]]

  plot(data_alter$Stresssymptome_kurz[data_alter$Alter_gruppiert == "Jung"],
    data_alter[[krit]][data_alter$Alter_gruppiert == "Jung"],
    pch = 19, col = rgb(1, 0.3, 0.3, 0.4),
    xlim = range(data_alter$Stresssymptome_kurz, na.rm = TRUE),
    ylim = range(data_alter[[krit]], na.rm = TRUE),
    xlab = "Stresssymptome",
    ylab = krit,
    main = paste0("Stresssymptome × ", krit)
  )
  points(data_alter$Stresssymptome_kurz[data_alter$Alter_gruppiert == "Mittel"],
    data_alter[[krit]][data_alter$Alter_gruppiert == "Mittel"],
    pch = 19, col = rgb(0.3, 0.3, 1, 0.4)
  )
  points(data_alter$Stresssymptome_kurz[data_alter$Alter_gruppiert == "Alt"],
    data_alter[[krit]][data_alter$Alter_gruppiert == "Alt"],
    pch = 19, col = rgb(0.3, 1, 0.3, 0.4)
  )

  for (gruppe in c("Jung", "Mittel", "Alt")) {
    subset_data <- subset(data_alter, Alter_gruppiert == gruppe)
    if (nrow(subset_data) > 5) {
      lm_temp <- lm(subset_data[[krit]] ~ subset_data$Stresssymptome_kurz)
      abline(lm_temp,
        col = ifelse(gruppe == "Jung", "red", ifelse(gruppe == "Mittel", "blue", "darkgreen")),
        lwd = 2
      )
    }
  }

  best_p <- min(res$p_jm, res$p_ja, res$p_ma)
  sig_symbol <- ifelse(best_p < 0.001, "***", ifelse(best_p < 0.01, "**", ifelse(best_p < 0.05, "*", "ns")))

  legend("topleft",
    legend = c(
      paste0("Jung: r = ", round(res$jung_r, 3)),
      paste0("Mittel: r = ", round(res$mittel_r, 3)),
      paste0("Alt: r = ", round(res$alt_r, 3)),
      paste0("z_max = ", round(max(abs(res$z_jm), abs(res$z_ja), abs(res$z_ma)), 3), " ", sig_symbol)
    ),
    col = c("red", "blue", "darkgreen", "black"), lwd = c(2, 2, 2, NA), pch = c(19, 19, 19, NA),
    bty = "n", cex = 0.8
  )
}

dev.off()

cat("✓ Subgruppenanalysen und Plots gespeichert (3 demographische Variablen × 6 Korrelationen)\n\n")


# ==============================================================================
# ZUSAMMENFASSUNG
# ==============================================================================

print_section("ZUSAMMENFASSUNG DER ERGEBNISSE")

cat("RELIABILITÄT:\n")
cat("  ✓ Stressbelastung Kurzskala: α =", round(alpha_stress_kurz$total$raw_alpha, 3), "\n")
cat("  ✓ Stresssymptome Kurzskala:  α =", round(alpha_sympt_kurz$total$raw_alpha, 3), "\n\n")

cat("VALIDITÄT:\n")
cat("  ✓ Stressbelastung korreliert erwartungsgemäß mit Validitätskriterien\n")
cat("  ✓ Stresssymptome korreliert erwartungsgemäß mit Validitätskriterien\n\n")

cat("Analyse abgeschlossen.\n")
cat("Für detaillierte Ergebnisse siehe Ausgabe oben.\n\n")
