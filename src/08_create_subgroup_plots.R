#!/usr/bin/env Rscript
# ==============================================================================
# SUBGRUPPEN-VISUALISIERUNGEN
# ==============================================================================
#
# Erstellt Scatter-Plots mit Regressionslinien für demographische Subgruppen:
# - Plots 20-24: Korrelationen nach Geschlecht
# - Plots 25-29: Korrelationen nach Bildung
# - Plots 30-34: Korrelationen nach Alter
# - Plots 35-39: Korrelationen nach Beschäftigung
#
# Jede Gruppe hat 5 Plots:
#   a: Stressbelastung × 3 Validitätskriterien
#   b: Stresssymptome × 3 Validitätskriterien
#   c: 5 Coping-Skalen × Zufriedenheit
#   d: 5 Coping-Skalen × Neurotizismus
#   e: 5 Coping-Skalen × Resilienz
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
# PAKETE LADEN
# ==============================================================================

library(ggplot2)
library(gridExtra)

# ==============================================================================
# WORKSPACE LADEN
# ==============================================================================

cat("Lade Workspace von 01_setup_and_scales.R...\n")
load(WORKSPACE_FILE)
cat("✓ Workspace geladen:", WORKSPACE_FILE, "\n\n")

print_section("SUBGRUPPEN-VISUALISIERUNGEN")

# ==============================================================================
# HILFSFUNKTIONEN
# ==============================================================================

# Erstellt einen Scatter-Plot mit Regressionslinien für Subgruppen
create_subgroup_scatterplot <- function(data, x_var, y_var, group_var,
                                        x_label, y_label, group_label,
                                        colors, title) {
  # Entferne fehlende Werte
  plot_data <- data[!is.na(data[[x_var]]) &
    !is.na(data[[y_var]]) &
    !is.na(data[[group_var]]), ]

  # Plot erstellen
  p <- ggplot(plot_data, aes(x = .data[[x_var]], y = .data[[y_var]], color = .data[[group_var]])) +
    geom_point(alpha = 0.3, size = 2) +
    geom_smooth(method = "lm", se = TRUE, linewidth = 1.5, alpha = 0.2) +
    scale_color_manual(values = colors) +
    labs(
      title = title,
      x = x_label,
      y = y_label,
      color = group_label
    ) +
    theme_minimal(base_size = 12) +
    theme(
      plot.title = element_text(face = "bold", size = 13),
      legend.position = "bottom",
      panel.grid.minor = element_blank(),
      legend.title = element_text(face = "bold")
    )

  p
}

# Erstellt Plots für Stress/Symptome (alle 3 Validitätskriterien)
create_stress_plots <- function(data, skala, skala_label, validitaet,
                                group_var, group_label, colors) {
  plot_list <- list()

  for (valid in validitaet) {
    p <- create_subgroup_scatterplot(
      data = data,
      x_var = skala,
      y_var = valid,
      group_var = group_var,
      x_label = skala_label,
      y_label = valid,
      group_label = group_label,
      colors = colors,
      title = paste0(skala_label, " × ", valid)
    )
    plot_list[[length(plot_list) + 1]] <- p
  }

  plot_list
}

# Erstellt Plots für Coping-Skalen (ein Validitätskriterium)
create_coping_plots <- function(data, coping_skalen, coping_labels, validitaet_var,
                                validitaet_label, group_var, group_label, colors) {
  plot_list <- list()

  for (i in seq_along(coping_skalen)) {
    p <- create_subgroup_scatterplot(
      data = data,
      x_var = coping_skalen[i],
      y_var = validitaet_var,
      group_var = group_var,
      x_label = coping_labels[i],
      y_label = validitaet_label,
      group_label = group_label,
      colors = colors,
      title = paste0(coping_labels[i], " × ", validitaet_label)
    )
    plot_list[[length(plot_list) + 1]] <- p
  }

  plot_list
}

# ==============================================================================
# SKALEN UND VALIDITÄTSKRITERIEN
# ==============================================================================

validitaet <- c("Zufriedenheit", "Neurotizismus", "Resilienz")

coping_skalen <- c(
  "Coping_aktiv", "Coping_Drogen", "Coping_positiv",
  "Coping_sozial", "Coping_rel"
)
coping_labels <- c(
  "Coping aktiv", "Coping Drogen", "Coping positiv",
  "Coping sozial", "Coping religiös"
)

# ==============================================================================
# PLOTS 20-24: KORRELATIONEN NACH GESCHLECHT
# ==============================================================================

cat("Erstelle Plots 20-24: Korrelationen nach Geschlecht...\n")

# Vorbereitung der Daten
data_gender <- subset(data, Geschlecht %in% c("1", "2"))
data_gender$Geschlecht_label <- factor(
  ifelse(data_gender$Geschlecht == "1", "Männlich", "Weiblich"),
  levels = c("Männlich", "Weiblich")
)

# Farben für Geschlecht
gender_colors <- c("Männlich" = "#3498db", "Weiblich" = "#e74c3c")

# 20: Stressbelastung
plots_20 <- create_stress_plots(
  data = data_gender,
  skala = "Stressbelastung_kurz",
  skala_label = "Stressbelastung",
  validitaet = validitaet,
  group_var = "Geschlecht_label",
  group_label = "Geschlecht",
  colors = gender_colors
)

png("manual/plots/20_geschlecht_stress.png", width = 1800, height = 600, res = 150)
grid.arrange(
  grobs = plots_20, ncol = 3,
  top = grid::textGrob("Stressbelastung × Validität nach Geschlecht",
    gp = grid::gpar(fontsize = 16, fontface = "bold")
  )
)
dev.off()

# 21: Stresssymptome
plots_21 <- create_stress_plots(
  data = data_gender,
  skala = "Stresssymptome_kurz",
  skala_label = "Stresssymptome",
  validitaet = validitaet,
  group_var = "Geschlecht_label",
  group_label = "Geschlecht",
  colors = gender_colors
)

png("manual/plots/21_geschlecht_symptome.png", width = 1800, height = 600, res = 150)
grid.arrange(
  grobs = plots_21, ncol = 3,
  top = grid::textGrob("Stresssymptome × Validität nach Geschlecht",
    gp = grid::gpar(fontsize = 16, fontface = "bold")
  )
)
dev.off()

# 22: Coping × Zufriedenheit
plots_22 <- create_coping_plots(
  data = data_gender,
  coping_skalen = coping_skalen,
  coping_labels = coping_labels,
  validitaet_var = "Zufriedenheit",
  validitaet_label = "Zufriedenheit",
  group_var = "Geschlecht_label",
  group_label = "Geschlecht",
  colors = gender_colors
)

png("manual/plots/22_geschlecht_coping_zufriedenheit.png", width = 1800, height = 1200, res = 150)
grid.arrange(
  grobs = plots_22, ncol = 3,
  top = grid::textGrob("Coping-Skalen × Zufriedenheit nach Geschlecht",
    gp = grid::gpar(fontsize = 16, fontface = "bold")
  )
)
dev.off()

# 23: Coping × Neurotizismus
plots_23 <- create_coping_plots(
  data = data_gender,
  coping_skalen = coping_skalen,
  coping_labels = coping_labels,
  validitaet_var = "Neurotizismus",
  validitaet_label = "Neurotizismus",
  group_var = "Geschlecht_label",
  group_label = "Geschlecht",
  colors = gender_colors
)

png("manual/plots/23_geschlecht_coping_neurotizismus.png", width = 1800, height = 1200, res = 150)
grid.arrange(
  grobs = plots_23, ncol = 3,
  top = grid::textGrob("Coping-Skalen × Neurotizismus nach Geschlecht",
    gp = grid::gpar(fontsize = 16, fontface = "bold")
  )
)
dev.off()

# 24: Coping × Resilienz
plots_24 <- create_coping_plots(
  data = data_gender,
  coping_skalen = coping_skalen,
  coping_labels = coping_labels,
  validitaet_var = "Resilienz",
  validitaet_label = "Resilienz",
  group_var = "Geschlecht_label",
  group_label = "Geschlecht",
  colors = gender_colors
)

png("manual/plots/24_geschlecht_coping_resilienz.png", width = 1800, height = 1200, res = 150)
grid.arrange(
  grobs = plots_24, ncol = 3,
  top = grid::textGrob("Coping-Skalen × Resilienz nach Geschlecht",
    gp = grid::gpar(fontsize = 16, fontface = "bold")
  )
)
dev.off()

cat("✓ Plots 20-24 gespeichert\n\n")

# ==============================================================================
# PLOTS 25-29: KORRELATIONEN NACH BILDUNG
# ==============================================================================

cat("Erstelle Plots 25-29: Korrelationen nach Bildung...\n")

# Bildungsgruppierung
data$Bildung_gruppiert <- cut(as.numeric(data$Bildung),
  breaks = c(0, 3, 4, 7, 8),
  labels = c("Niedrig", "Mittel", "Hoch", "Andere"),
  include.lowest = TRUE
)

data_bildung <- subset(data, Bildung_gruppiert %in% c("Niedrig", "Mittel", "Hoch"))
data_bildung$Bildung_gruppiert <- factor(data_bildung$Bildung_gruppiert,
  levels = c("Niedrig", "Mittel", "Hoch")
)

# Farben für Bildung
bildung_colors <- c("Niedrig" = "#e74c3c", "Mittel" = "#f39c12", "Hoch" = "#27ae60")

# 25: Stressbelastung
plots_25 <- create_stress_plots(
  data = data_bildung,
  skala = "Stressbelastung_kurz",
  skala_label = "Stressbelastung",
  validitaet = validitaet,
  group_var = "Bildung_gruppiert",
  group_label = "Bildung",
  colors = bildung_colors
)

png("manual/plots/25_bildung_stress.png", width = 1800, height = 600, res = 150)
grid.arrange(
  grobs = plots_25, ncol = 3,
  top = grid::textGrob("Stressbelastung × Validität nach Bildungsniveau",
    gp = grid::gpar(fontsize = 16, fontface = "bold")
  )
)
dev.off()

# 26: Stresssymptome
plots_26 <- create_stress_plots(
  data = data_bildung,
  skala = "Stresssymptome_kurz",
  skala_label = "Stresssymptome",
  validitaet = validitaet,
  group_var = "Bildung_gruppiert",
  group_label = "Bildung",
  colors = bildung_colors
)

png("manual/plots/26_bildung_symptome.png", width = 1800, height = 600, res = 150)
grid.arrange(
  grobs = plots_26, ncol = 3,
  top = grid::textGrob("Stresssymptome × Validität nach Bildungsniveau",
    gp = grid::gpar(fontsize = 16, fontface = "bold")
  )
)
dev.off()

# 27-29: Coping
plots_27 <- create_coping_plots(
  data = data_bildung, coping_skalen = coping_skalen, coping_labels = coping_labels,
  validitaet_var = "Zufriedenheit", validitaet_label = "Zufriedenheit",
  group_var = "Bildung_gruppiert", group_label = "Bildung", colors = bildung_colors
)

png("manual/plots/27_bildung_coping_zufriedenheit.png", width = 1800, height = 1200, res = 150)
grid.arrange(
  grobs = plots_27, ncol = 3,
  top = grid::textGrob("Coping-Skalen × Zufriedenheit nach Bildungsniveau",
    gp = grid::gpar(fontsize = 16, fontface = "bold")
  )
)
dev.off()

plots_28 <- create_coping_plots(
  data = data_bildung, coping_skalen = coping_skalen, coping_labels = coping_labels,
  validitaet_var = "Neurotizismus", validitaet_label = "Neurotizismus",
  group_var = "Bildung_gruppiert", group_label = "Bildung", colors = bildung_colors
)

png("manual/plots/28_bildung_coping_neurotizismus.png", width = 1800, height = 1200, res = 150)
grid.arrange(
  grobs = plots_28, ncol = 3,
  top = grid::textGrob("Coping-Skalen × Neurotizismus nach Bildungsniveau",
    gp = grid::gpar(fontsize = 16, fontface = "bold")
  )
)
dev.off()

plots_29 <- create_coping_plots(
  data = data_bildung, coping_skalen = coping_skalen, coping_labels = coping_labels,
  validitaet_var = "Resilienz", validitaet_label = "Resilienz",
  group_var = "Bildung_gruppiert", group_label = "Bildung", colors = bildung_colors
)

png("manual/plots/29_bildung_coping_resilienz.png", width = 1800, height = 1200, res = 150)
grid.arrange(
  grobs = plots_29, ncol = 3,
  top = grid::textGrob("Coping-Skalen × Resilienz nach Bildungsniveau",
    gp = grid::gpar(fontsize = 16, fontface = "bold")
  )
)
dev.off()

cat("✓ Plots 25-29 gespeichert\n\n")

# ==============================================================================
# PLOTS 30-34: KORRELATIONEN NACH ALTER
# ==============================================================================

cat("Erstelle Plots 30-34: Korrelationen nach Alter...\n")

# Altersgruppierung
data$Alter_gruppiert <- cut(data$Alter,
  breaks = c(0, 30, 45, 100),
  labels = c("Jung (<30)", "Mittel (30-45)", "Alt (>45)"),
  include.lowest = TRUE
)

data_alter <- subset(data, !is.na(Alter_gruppiert))
data_alter$Alter_gruppiert <- factor(data_alter$Alter_gruppiert,
  levels = c("Jung (<30)", "Mittel (30-45)", "Alt (>45)")
)

# Farben für Alter
alter_colors <- c(
  "Jung (<30)" = "#3498db",
  "Mittel (30-45)" = "#9b59b6",
  "Alt (>45)" = "#e67e22"
)

# 30: Stressbelastung
plots_30 <- create_stress_plots(
  data = data_alter,
  skala = "Stressbelastung_kurz",
  skala_label = "Stressbelastung",
  validitaet = validitaet,
  group_var = "Alter_gruppiert",
  group_label = "Altersgruppe",
  colors = alter_colors
)

png("manual/plots/30_alter_stress.png", width = 1800, height = 600, res = 150)
grid.arrange(
  grobs = plots_30, ncol = 3,
  top = grid::textGrob("Stressbelastung × Validität nach Altersgruppe",
    gp = grid::gpar(fontsize = 16, fontface = "bold")
  )
)
dev.off()

# 31: Stresssymptome
plots_31 <- create_stress_plots(
  data = data_alter,
  skala = "Stresssymptome_kurz",
  skala_label = "Stresssymptome",
  validitaet = validitaet,
  group_var = "Alter_gruppiert",
  group_label = "Altersgruppe",
  colors = alter_colors
)

png("manual/plots/31_alter_symptome.png", width = 1800, height = 600, res = 150)
grid.arrange(
  grobs = plots_31, ncol = 3,
  top = grid::textGrob("Stresssymptome × Validität nach Altersgruppe",
    gp = grid::gpar(fontsize = 16, fontface = "bold")
  )
)
dev.off()

# 32-34: Coping
plots_32 <- create_coping_plots(
  data = data_alter, coping_skalen = coping_skalen, coping_labels = coping_labels,
  validitaet_var = "Zufriedenheit", validitaet_label = "Zufriedenheit",
  group_var = "Alter_gruppiert", group_label = "Altersgruppe", colors = alter_colors
)

png("manual/plots/32_alter_coping_zufriedenheit.png", width = 1800, height = 1200, res = 150)
grid.arrange(
  grobs = plots_32, ncol = 3,
  top = grid::textGrob("Coping-Skalen × Zufriedenheit nach Altersgruppe",
    gp = grid::gpar(fontsize = 16, fontface = "bold")
  )
)
dev.off()

plots_33 <- create_coping_plots(
  data = data_alter, coping_skalen = coping_skalen, coping_labels = coping_labels,
  validitaet_var = "Neurotizismus", validitaet_label = "Neurotizismus",
  group_var = "Alter_gruppiert", group_label = "Altersgruppe", colors = alter_colors
)

png("manual/plots/33_alter_coping_neurotizismus.png", width = 1800, height = 1200, res = 150)
grid.arrange(
  grobs = plots_33, ncol = 3,
  top = grid::textGrob("Coping-Skalen × Neurotizismus nach Altersgruppe",
    gp = grid::gpar(fontsize = 16, fontface = "bold")
  )
)
dev.off()

plots_34 <- create_coping_plots(
  data = data_alter, coping_skalen = coping_skalen, coping_labels = coping_labels,
  validitaet_var = "Resilienz", validitaet_label = "Resilienz",
  group_var = "Alter_gruppiert", group_label = "Altersgruppe", colors = alter_colors
)

png("manual/plots/34_alter_coping_resilienz.png", width = 1800, height = 1200, res = 150)
grid.arrange(
  grobs = plots_34, ncol = 3,
  top = grid::textGrob("Coping-Skalen × Resilienz nach Altersgruppe",
    gp = grid::gpar(fontsize = 16, fontface = "bold")
  )
)
dev.off()

cat("✓ Plots 30-34 gespeichert\n\n")

# ==============================================================================
# PLOTS 35-39: KORRELATIONEN NACH BESCHÄFTIGUNG
# ==============================================================================

cat("Erstelle Plots 35-39: Korrelationen nach Beschäftigung...\n")

# Beschäftigungsgruppen (nur häufigste Kategorien mit n >= 20)
beschaeftigung_freq <- table(data$Beschäftigung)
beschaeftigung_freq <- beschaeftigung_freq[beschaeftigung_freq >= 20]

data$Beschäftigung_gruppiert <- ifelse(data$Beschäftigung %in% names(beschaeftigung_freq),
  data$Beschäftigung, "Andere"
)

data_beschaeftigung <- subset(data, Beschäftigung_gruppiert != "Andere" &
  !is.na(Beschäftigung_gruppiert))

# Sortiere nach Häufigkeit für konsistente Darstellung
beschaeftigung_gruppen <- names(sort(table(data_beschaeftigung$Beschäftigung_gruppiert),
  decreasing = TRUE
))
data_beschaeftigung$Beschäftigung_gruppiert <- factor(
  data_beschaeftigung$Beschäftigung_gruppiert,
  levels = beschaeftigung_gruppen
)

# Farben für Beschäftigung (erstelle automatisch basierend auf Anzahl)
n_gruppen <- length(beschaeftigung_gruppen)
beschaeftigung_colors <- setNames(
  rainbow(n_gruppen, s = 0.6, v = 0.8),
  beschaeftigung_gruppen
)

# 35: Stressbelastung
plots_35 <- create_stress_plots(
  data = data_beschaeftigung,
  skala = "Stressbelastung_kurz",
  skala_label = "Stressbelastung",
  validitaet = validitaet,
  group_var = "Beschäftigung_gruppiert",
  group_label = "Beschäftigung",
  colors = beschaeftigung_colors
)

png("manual/plots/35_beschaeftigung_stress.png", width = 1800, height = 600, res = 150)
grid.arrange(
  grobs = plots_35, ncol = 3,
  top = grid::textGrob("Stressbelastung × Validität nach Beschäftigung",
    gp = grid::gpar(fontsize = 16, fontface = "bold")
  )
)
dev.off()

# 36: Stresssymptome
plots_36 <- create_stress_plots(
  data = data_beschaeftigung,
  skala = "Stresssymptome_kurz",
  skala_label = "Stresssymptome",
  validitaet = validitaet,
  group_var = "Beschäftigung_gruppiert",
  group_label = "Beschäftigung",
  colors = beschaeftigung_colors
)

png("manual/plots/36_beschaeftigung_symptome.png", width = 1800, height = 600, res = 150)
grid.arrange(
  grobs = plots_36, ncol = 3,
  top = grid::textGrob("Stresssymptome × Validität nach Beschäftigung",
    gp = grid::gpar(fontsize = 16, fontface = "bold")
  )
)
dev.off()

# 37-39: Coping
plots_37 <- create_coping_plots(
  data = data_beschaeftigung, coping_skalen = coping_skalen, coping_labels = coping_labels,
  validitaet_var = "Zufriedenheit", validitaet_label = "Zufriedenheit",
  group_var = "Beschäftigung_gruppiert", group_label = "Beschäftigung", colors = beschaeftigung_colors
)

png("manual/plots/37_beschaeftigung_coping_zufriedenheit.png", width = 1800, height = 1200, res = 150)
grid.arrange(
  grobs = plots_37, ncol = 3,
  top = grid::textGrob("Coping-Skalen × Zufriedenheit nach Beschäftigung",
    gp = grid::gpar(fontsize = 16, fontface = "bold")
  )
)
dev.off()

plots_38 <- create_coping_plots(
  data = data_beschaeftigung, coping_skalen = coping_skalen, coping_labels = coping_labels,
  validitaet_var = "Neurotizismus", validitaet_label = "Neurotizismus",
  group_var = "Beschäftigung_gruppiert", group_label = "Beschäftigung", colors = beschaeftigung_colors
)

png("manual/plots/38_beschaeftigung_coping_neurotizismus.png", width = 1800, height = 1200, res = 150)
grid.arrange(
  grobs = plots_38, ncol = 3,
  top = grid::textGrob("Coping-Skalen × Neurotizismus nach Beschäftigung",
    gp = grid::gpar(fontsize = 16, fontface = "bold")
  )
)
dev.off()

plots_39 <- create_coping_plots(
  data = data_beschaeftigung, coping_skalen = coping_skalen, coping_labels = coping_labels,
  validitaet_var = "Resilienz", validitaet_label = "Resilienz",
  group_var = "Beschäftigung_gruppiert", group_label = "Beschäftigung", colors = beschaeftigung_colors
)

png("manual/plots/39_beschaeftigung_coping_resilienz.png", width = 1800, height = 1200, res = 150)
grid.arrange(
  grobs = plots_39, ncol = 3,
  top = grid::textGrob("Coping-Skalen × Resilienz nach Beschäftigung",
    gp = grid::gpar(fontsize = 16, fontface = "bold")
  )
)
dev.off()

cat("✓ Plots 35-39 gespeichert\n\n")

# ==============================================================================
# ZUSAMMENFASSUNG
# ==============================================================================

cat("\n")
print_section("SUBGRUPPEN-PLOTS ABGESCHLOSSEN")

cat("✓ Alle Subgruppen-Visualisierungen erstellt!\n\n")
cat("Gespeicherte Plots (20 Plots total):\n\n")
cat("  GESCHLECHT (20-24):\n")
cat("    - 20: Stressbelastung × 3 Validitätskriterien\n")
cat("    - 21: Stresssymptome × 3 Validitätskriterien\n")
cat("    - 22: 5 Coping-Skalen × Zufriedenheit\n")
cat("    - 23: 5 Coping-Skalen × Neurotizismus\n")
cat("    - 24: 5 Coping-Skalen × Resilienz\n\n")
cat("  BILDUNG (25-29):\n")
cat("    - 25: Stressbelastung × 3 Validitätskriterien\n")
cat("    - 26: Stresssymptome × 3 Validitätskriterien\n")
cat("    - 27: 5 Coping-Skalen × Zufriedenheit\n")
cat("    - 28: 5 Coping-Skalen × Neurotizismus\n")
cat("    - 29: 5 Coping-Skalen × Resilienz\n\n")
cat("  ALTER (30-34):\n")
cat("    - 30: Stressbelastung × 3 Validitätskriterien\n")
cat("    - 31: Stresssymptome × 3 Validitätskriterien\n")
cat("    - 32: 5 Coping-Skalen × Zufriedenheit\n")
cat("    - 33: 5 Coping-Skalen × Neurotizismus\n")
cat("    - 34: 5 Coping-Skalen × Resilienz\n\n")
cat("  BESCHÄFTIGUNG (35-39):\n")
cat("    - 35: Stressbelastung × 3 Validitätskriterien\n")
cat("    - 36: Stresssymptome × 3 Validitätskriterien\n")
cat("    - 37: 5 Coping-Skalen × Zufriedenheit\n")
cat("    - 38: 5 Coping-Skalen × Neurotizismus\n")
cat("    - 39: 5 Coping-Skalen × Resilienz\n\n")
cat("Format:\n")
cat("  - Scatter-Plots mit Regressionslinien für jede Subgruppe\n")
cat("  - 95%-Konfidenzintervalle als Bänder um Regressionslinien\n")
cat("  - Größere, klarere Darstellung durch Aufteilung nach Validitätskriterium\n\n")
