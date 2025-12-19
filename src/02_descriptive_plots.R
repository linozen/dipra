#!/usr/bin/env Rscript
# ==============================================================================
# DESKRIPTIVE PLOTS
# ==============================================================================
#
# Dieses Skript erstellt alle deskriptiven Visualisierungen:
# - Plot 01: Altersverteilung
# - Plot 02: Geschlechterverteilung
# - Plot 03: Beschäftigungsverteilung
# - Plot 04: Bildungsverteilung
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
# DESKRIPTIVE PLOTS
# ==============================================================================

print_section("DESKRIPTIVE PLOTS")

cat("Generiere deskriptive Plots...\n\n")

# ------------------------------------------------------------------------------
# Plot 01: Altersverteilung
# ------------------------------------------------------------------------------

png(file.path(PLOTS_DIR, "01_altersverteilung.png"), width = 1200, height = 900, res = 150)
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

cat("✓ Plot 01: Altersverteilung\n")

# ------------------------------------------------------------------------------
# Plot 02: Geschlechterverteilung
# ------------------------------------------------------------------------------

png(file.path(PLOTS_DIR, "02_geschlechterverteilung.png"), width = 1200, height = 900, res = 150)
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

cat("✓ Plot 02: Geschlechterverteilung\n")

# ------------------------------------------------------------------------------
# Plot 03: Beschäftigungsverteilung
# ------------------------------------------------------------------------------

png(file.path(PLOTS_DIR, "03_beschaeftigungsverteilung.png"), width = 1200, height = 900, res = 150)
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

cat("✓ Plot 03: Beschäftigungsverteilung\n")

# ------------------------------------------------------------------------------
# Plot 04: Bildungsverteilung
# ------------------------------------------------------------------------------

png(file.path(PLOTS_DIR, "04_bildungsverteilung.png"), width = 1400, height = 900, res = 150)
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

cat("✓ Plot 04: Bildungsverteilung\n")

# ==============================================================================
# ZUSAMMENFASSUNG
# ==============================================================================

print_section("FERTIG")

cat("Alle deskriptiven Plots wurden erfolgreich erstellt und in plots/ gespeichert.\n\n")
cat("Führen Sie als nächstes aus: 03_reliability.R\n\n")
