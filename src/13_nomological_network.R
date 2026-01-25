#!/usr/bin/env Rscript
# ==============================================================================
# NOMOLOGISCHES NETZWERK - THEORETISCH & EMPIRISCH
# ==============================================================================
#
# Dieses Skript erstellt zwei Netzwerk-Grafiken:
# 1. Theoretisch erwartete Beziehungen zwischen Konstrukten
# 2. Empirisch beobachtete Korrelationen
#
# Konstrukte:
# - Stresssymptome
# - Stressbelastung
# - Coping-Strategien (5 Arten)
# - Validitätskriterien (Lebenszufriedenheit, Neurotizismus, Resilienz)
#
# ==============================================================================

# ==============================================================================
# KONFIGURATION
# ==============================================================================

WORKSPACE_FILE <- "data/workspace.RData"
PLOTS_DIR <- "manual/plots"

# ==============================================================================
# WORKSPACE LADEN
# ==============================================================================

cat("Lade Workspace...\n")
load(WORKSPACE_FILE)
cat("✓ Workspace geladen\n\n")

# ==============================================================================
# PAKETE LADEN
# ==============================================================================

suppressPackageStartupMessages({
  library(tidyverse)
  library(igraph)
})

# ==============================================================================
# 1. THEORETISCHES NETZWERK (ERWARTETE BEZIEHUNGEN)
# ==============================================================================

cat("Erstelle theoretisches nomologisches Netzwerk...\n")

# Definiere Knoten (identisch für beide Grafiken)
# Mit Zeilenumbrüchen für lange Namen
nodes_theory <- data.frame(
  name = c(
    "Stress-\nsymptome",
    "Stress-\nbelastung",
    "Coping:\nDrogen",
    "Coping:\nReligiös",
    "Coping:\nSozial",
    "Coping:\nPositiv",
    "Coping:\nAktiv",
    "Lebens-\nzufriedenheit",
    "Neurotizismus",
    "Resilienz"
  ),
  type = c(
    "Stress", "Stress",
    "Coping", "Coping", "Coping", "Coping", "Coping",
    "Validität", "Validität", "Validität"
  )
)

# Erstelle manuelle Positionen für konsistentes Layout
# Sehr breites Layout mit maximalem horizontalem Abstand
layout_fixed <- matrix(c(
  # x,    y     (Knoten-Positionen)
  0,     1,    # Stresssymptome (Mitte oben)
  0,    -1,    # Stressbelastung (Mitte unten)
  -5,    2,    # Coping: Drogen (links oben) - maximal links
  -5,    0,    # Coping: Religiös (links mitte)
  -5,   -2,    # Coping: Sozial (links unten)
  -3,    1,    # Coping: Positiv (links oben-mitte)
  -3,   -1,    # Coping: Aktiv (links unten-mitte)
  5,     2,    # Lebenszufriedenheit (rechts oben) - maximal rechts
  5,     0,    # Neurotizismus (rechts mitte)
  5,    -2     # Resilienz (rechts unten)
), ncol = 2, byrow = TRUE)

# Definiere Kanten (erwartete Beziehungen)
# Wir verwenden kategoriale Stärken: stark, mittel, schwach
# WICHTIG: Verwende Namen MIT Zeilenumbrüchen wie in nodes_theory
edges_theory <- data.frame(
  from = c(
    # Stresssymptome
    "Stress-\nsymptome", "Stress-\nsymptome", "Stress-\nsymptome",
    "Stress-\nsymptome", "Stress-\nsymptome", "Stress-\nsymptome",
    "Stress-\nsymptome", "Stress-\nsymptome",
    # Stressbelastung
    "Stress-\nbelastung", "Stress-\nbelastung", "Stress-\nbelastung",
    "Stress-\nbelastung", "Stress-\nbelastung", "Stress-\nbelastung",
    "Stress-\nbelastung", "Stress-\nbelastung",
    # Zusammenhang Stress-Symptome
    "Stress-\nsymptome"
  ),
  to = c(
    # Stresssymptome
    "Lebens-\nzufriedenheit", "Neurotizismus", "Resilienz",
    "Coping:\nDrogen", "Coping:\nSozial", "Coping:\nPositiv",
    "Coping:\nAktiv", "Coping:\nReligiös",
    # Stressbelastung
    "Lebens-\nzufriedenheit", "Neurotizismus", "Resilienz",
    "Coping:\nDrogen", "Coping:\nSozial", "Coping:\nPositiv",
    "Coping:\nAktiv", "Coping:\nReligiös",
    # Zusammenhang Stress-Symptome
    "Stress-\nbelastung"
  ),
  sign = c(
    # Stresssymptome
    "negativ", "positiv", "negativ",
    "positiv", "negativ", "negativ",
    "negativ", "negativ",
    # Stressbelastung
    "negativ", "positiv", "negativ",
    "positiv", "negativ", "negativ",
    "negativ", "negativ",
    # Zusammenhang
    "positiv"
  ),
  strength = c(
    # Stresssymptome (basierend auf Theorie)
    "stark", "stark", "stark",  # Validitätskriterien
    "mittel", "mittel", "mittel", "mittel", "schwach",  # Coping
    # Stressbelastung
    "mittel", "mittel", "mittel",  # Validitätskriterien
    "mittel", "mittel", "mittel", "mittel", "schwach",  # Coping
    # Zusammenhang
    "stark"
  )
)

# Erstelle Graph
g_theory <- graph_from_data_frame(edges_theory, directed = FALSE, vertices = nodes_theory)

# Farben für Kantentypen (NEGATIV = ROT gestrichelt, POSITIV = HELLGRÜN durchgezogen)
edge_colors_theory <- ifelse(edges_theory$sign == "positiv", "#A5D6A7", "#EF9A9A")  # Noch helleres Grün und noch helleres Rot
edge_lty_theory <- ifelse(edges_theory$sign == "positiv", 1, 2)  # 1=solid, 2=dashed
# Alle Linien gleich breit - etwas dicker
edge_widths_theory <- rep(3, nrow(edges_theory))

# Farben für Knotentypen - verschiedene Schattierungen
# Stress: Rottöne, Coping: Blautöne, Validität: Grautöne
node_colors_theory <- c(
  "#D32F2F",  # Stresssymptome - dunkelrot
  "#EF5350",  # Stressbelastung - hellrot
  "#1976D2",  # Coping: Drogen - dunkelblau
  "#42A5F5",  # Coping: Religiös - mittelblau
  "#90CAF9",  # Coping: Sozial - hellblau
  "#64B5F6",  # Coping: Positiv - mittelblau-hell
  "#2196F3",  # Coping: Aktiv - blau
  "#757575",  # Lebenszufriedenheit - grau
  "#9E9E9E",  # Neurotizismus - mittelgrau
  "#BDBDBD"   # Resilienz - hellgrau
)

# Plot mit Sans-Serif Font (breiteres Format)
png(file.path(PLOTS_DIR, "nomological_network_theory.png"), width = 3000, height = 1800, res = 150)

par(family = "sans")  # Sans-serif Font

plot(g_theory,
  layout = layout_fixed,  # Fixiertes Layout
  vertex.size = 40,  # Kleinere Kreise
  vertex.color = node_colors_theory,
  vertex.label.color = "white",
  vertex.label.cex = 1.2,  # Größerer Text in den Knoten
  vertex.label.font = 2,
  vertex.label.family = "sans",
  vertex.frame.color = NA,
  edge.color = edge_colors_theory,
  edge.width = edge_widths_theory,
  edge.lty = edge_lty_theory,  # Gestrichelt für negative
  edge.curved = 0,  # Gerade Linien
  main = NULL  # Kein Titel
)

# Legende für Knotentypen
legend("bottomright",
  legend = c("Stress-Konstrukte", "Coping-Strategien", "Validitätskriterien"),
  fill = c("#D32F2F", "#1976D2", "#757575"),  # Repräsentative Farben aus jeder Kategorie
  border = NA,
  bty = "n",
  cex = 1.2
)

legend("bottomleft",
  legend = c("Positive Beziehung", "Negative Beziehung"),
  col = c("#A5D6A7", "#EF9A9A"),  # Noch helleres Grün und noch helleres Rot
  lty = c(1, 2),  # durchgezogen vs gestrichelt
  lwd = c(2, 2),
  bty = "n",
  cex = 1.1
)

dev.off()
cat("✓ Theoretisches Netzwerk gespeichert\n")

# ==============================================================================
# 2. EMPIRISCHES NETZWERK (BEOBACHTETE KORRELATIONEN)
# ==============================================================================

cat("Erstelle empirisches nomologisches Netzwerk...\n")

# Berechne alle relevanten Korrelationen
# Verwende Namen MIT Zeilenumbrüchen für Konsistenz
constructs <- data.frame(
  `Stress-\nsymptome` = data$Stresssymptome_kurz,
  `Stress-\nbelastung` = data$Stressbelastung_kurz,
  `Coping:\nDrogen` = data$Coping_Drogen,
  `Coping:\nReligiös` = data$Coping_rel,
  `Coping:\nSozial` = data$Coping_sozial,
  `Coping:\nPositiv` = data$Coping_positiv,
  `Coping:\nAktiv` = data$Coping_aktiv,
  `Lebens-\nzufriedenheit` = data$Zufriedenheit,
  Neurotizismus = data$Neurotizismus,
  Resilienz = data$Resilienz,
  check.names = FALSE
)

# Korrelationsmatrix
cor_matrix <- cor(constructs, use = "pairwise.complete.obs")

# Erstelle Edge-Liste aus Korrelationsmatrix
# Führe Signifikanztests durch und behalte nur signifikante + starke Korrelationen
edges_empirical <- data.frame()

# Mapping von Spaltennamen zu Originalvariablen für Signifikanztests
var_mapping <- list(
  `Stress-\nsymptome` = data$Stresssymptome_kurz,
  `Stress-\nbelastung` = data$Stressbelastung_kurz,
  `Coping:\nDrogen` = data$Coping_Drogen,
  `Coping:\nReligiös` = data$Coping_rel,
  `Coping:\nSozial` = data$Coping_sozial,
  `Coping:\nPositiv` = data$Coping_positiv,
  `Coping:\nAktiv` = data$Coping_aktiv,
  `Lebens-\nzufriedenheit` = data$Zufriedenheit,
  Neurotizismus = data$Neurotizismus,
  Resilienz = data$Resilienz
)

# Durchlaufe nur die Kanten aus dem theoretischen Graph
for (i in 1:nrow(edges_theory)) {
  var1 <- edges_theory$from[i]
  var2 <- edges_theory$to[i]

  # Finde Korrelation in der Matrix
  r <- cor_matrix[var1, var2]

  if (!is.na(r)) {
    # Führe Signifikanztest durch
    test_result <- cor.test(var_mapping[[var1]], var_mapping[[var2]])

    # Füge ALLE theoretischen Kanten hinzu (unabhängig von Signifikanz)
    # Dies zeigt, welche theoretischen Annahmen empirisch bestätigt wurden
    edges_empirical <- rbind(edges_empirical, data.frame(
      from = var1,
      to = var2,
      correlation = r,
      abs_correlation = abs(r),
      sign = ifelse(r > 0, "positiv", "negativ"),
      p_value = test_result$p.value,
      label = sprintf("%.2f", r),  # Nur Korrelationswert ohne "r=" und ohne Sterne
      stringsAsFactors = FALSE
    ))
  }
}

# Nodes gleich wie vorher
nodes_empirical <- nodes_theory

# Erstelle Graph
g_empirical <- graph_from_data_frame(edges_empirical, directed = FALSE, vertices = nodes_empirical)

# Farben für Kantentypen (NEGATIV = ROT gestrichelt, POSITIV = HELLGRÜN durchgezogen)
edge_colors_empirical <- ifelse(edges_empirical$sign == "positiv", "#A5D6A7", "#EF9A9A")  # Noch helleres Grün und noch helleres Rot
edge_lty_empirical <- ifelse(edges_empirical$sign == "positiv", 1, 2)  # 1=solid, 2=dashed

# Kantenstärke basierend auf absoluter Korrelation - etwas dicker
edge_widths_empirical <- abs(edges_empirical$correlation) * 8

# Plot mit Sans-Serif Font und gleichem Layout (breiteres Format)
png(file.path(PLOTS_DIR, "nomological_network_empirical.png"), width = 3000, height = 1800, res = 150)

par(family = "sans")  # Sans-serif Font

plot(g_empirical,
  layout = layout_fixed,  # GLEICHES fixiertes Layout wie Theory
  vertex.size = 40,  # Kleinere Kreise
  vertex.color = node_colors_theory,
  vertex.label.color = "white",
  vertex.label.cex = 1.2,  # Größerer Text in den Knoten
  vertex.label.font = 2,
  vertex.label.family = "sans",
  vertex.frame.color = NA,
  edge.color = edge_colors_empirical,
  edge.width = edge_widths_empirical,
  edge.lty = edge_lty_empirical,  # Gestrichelt für negative
  edge.curved = 0,  # Gerade Linien
  edge.label = edges_empirical$label,  # Korrelationswerte als Labels (ohne r= und Sterne)
  edge.label.cex = 1.2,  # Größere Labels
  edge.label.color = "black",
  edge.label.family = "sans",
  edge.label.font = 2,  # Fettgedruckt
  main = NULL  # Kein Titel
)

# Legende für Knotentypen
legend("bottomright",
  legend = c("Stress-Konstrukte", "Coping-Strategien", "Validitätskriterien"),
  fill = c("#D32F2F", "#1976D2", "#757575"),  # Repräsentative Farben aus jeder Kategorie
  border = NA,
  bty = "n",
  cex = 1.2
)

# Legende für Kantentypen
legend("bottomleft",
  legend = c("Positive Korrelation", "Negative Korrelation"),
  col = c("#A5D6A7", "#EF9A9A"),  # Noch helleres Grün und noch helleres Rot
  lty = c(1, 2),  # durchgezogen vs gestrichelt
  lwd = c(2, 2),
  bty = "n",
  cex = 1.1
)

dev.off()
cat("✓ Empirisches Netzwerk gespeichert\n")

# ==============================================================================
# 3. KORRELATIONSTABELLE FÜR MANUAL
# ==============================================================================

cat("\nErstelle Korrelationstabelle...\n")

# Relevante Korrelationen extrahieren
key_correlations <- data.frame(
  Konstrukt1 = character(),
  Konstrukt2 = character(),
  r = numeric(),
  p = numeric(),
  stringsAsFactors = FALSE
)

# Stress-Konstrukte mit Validitätskriterien
# Verwende Namen MIT Zeilenumbrüchen
for (stress_var in c("Stress-\nsymptome", "Stress-\nbelastung")) {
  for (valid_var in c("Lebens-\nzufriedenheit", "Neurotizismus", "Resilienz")) {
    cor_test <- cor.test(
      constructs[[stress_var]],
      constructs[[valid_var]]
    )
    key_correlations <- rbind(key_correlations, data.frame(
      Konstrukt1 = gsub("\n", "", stress_var),  # Remove newlines for CSV
      Konstrukt2 = gsub("\n", "", valid_var),
      r = cor_test$estimate,
      p = cor_test$p.value
    ))
  }
}

# Coping-Strategien mit Stress
coping_vars <- c("Coping:\nDrogen", "Coping:\nReligiös", "Coping:\nSozial", "Coping:\nPositiv", "Coping:\nAktiv")
for (coping_var in coping_vars) {
  for (stress_var in c("Stress-\nsymptome", "Stress-\nbelastung")) {
    cor_test <- cor.test(
      constructs[[coping_var]],
      constructs[[stress_var]]
    )
    key_correlations <- rbind(key_correlations, data.frame(
      Konstrukt1 = gsub("\n", "", coping_var),
      Konstrukt2 = gsub("\n", "", stress_var),
      r = cor_test$estimate,
      p = cor_test$p.value
    ))
  }
}

# Speichere Tabelle
write.csv(key_correlations,
          file.path("manual/output", "nomological_network_correlations.csv"),
          row.names = FALSE)

cat("✓ Korrelationstabelle gespeichert\n")

# Ausgabe wichtiger Korrelationen
cat("\n" %+% strrep("=", 80) %+% "\n")
cat("WICHTIGE KORRELATIONEN FÜR DAS NOMOLOGISCHE NETZWERK\n")
cat(strrep("=", 80) %+% "\n\n")

cat("Stresssymptome:\n")
cat("  mit Lebenszufriedenheit: r =",
    round(cor_matrix["Stress-\nsymptome", "Lebens-\nzufriedenheit"], 3), "\n")
cat("  mit Neurotizismus: r =",
    round(cor_matrix["Stress-\nsymptome", "Neurotizismus"], 3), "\n")
cat("  mit Resilienz: r =",
    round(cor_matrix["Stress-\nsymptome", "Resilienz"], 3), "\n\n")

cat("Stressbelastung:\n")
cat("  mit Lebenszufriedenheit: r =",
    round(cor_matrix["Stress-\nbelastung", "Lebens-\nzufriedenheit"], 3), "\n")
cat("  mit Neurotizismus: r =",
    round(cor_matrix["Stress-\nbelastung", "Neurotizismus"], 3), "\n")
cat("  mit Resilienz: r =",
    round(cor_matrix["Stress-\nbelastung", "Resilienz"], 3), "\n\n")

cat("Stresssymptome <-> Stressbelastung: r =",
    round(cor_matrix["Stress-\nsymptome", "Stress-\nbelastung"], 3), "\n\n")

cat("Adaptive Coping-Strategien (sollten negativ mit Stress korrelieren):\n")
cat("  Coping: Positiv mit Stresssymptome: r =",
    round(cor_matrix["Coping:\nPositiv", "Stress-\nsymptome"], 3), "\n")
cat("  Coping: Sozial mit Stresssymptome: r =",
    round(cor_matrix["Coping:\nSozial", "Stress-\nsymptome"], 3), "\n")
cat("  Coping: Aktiv mit Stresssymptome: r =",
    round(cor_matrix["Coping:\nAktiv", "Stress-\nsymptome"], 3), "\n\n")

cat("Maladaptive Coping-Strategie (sollte positiv mit Stress korrelieren):\n")
cat("  Coping: Drogen mit Stresssymptome: r =",
    round(cor_matrix["Coping:\nDrogen", "Stress-\nsymptome"], 3), "\n")
cat("  Coping: Drogen mit Stressbelastung: r =",
    round(cor_matrix["Coping:\nDrogen", "Stress-\nbelastung"], 3), "\n\n")

cat(strrep("=", 80) %+% "\n")
cat("FERTIG\n")
cat(strrep("=", 80) %+% "\n\n")

cat("Beide nomologischen Netzwerke wurden erfolgreich erstellt:\n")
cat("  - plots/nomological_network_theory.png\n")
cat("  - plots/nomological_network_empirical.png\n")
cat("  - manual/output/nomological_network_correlations.csv\n\n")
