#!/usr/bin/env Rscript
# ==============================================================================
# VALIDITÄTSANALYSEN: SUBGRUPPEN - STRESSBELASTUNG
# ==============================================================================
#
# Demographische Subgruppenanalysen für Stressbelastung:
# - Nach Geschlecht (Plot 17, Teil 1)
# - Nach Bildung (Plot 18, Teil 1)
# - Nach Alter (Plot 19, Teil 1)
# - Nach Beschäftigung (Plot 20, Teil 1)
#
# Verwendet Fisher's Z-Tests für Gruppenvergleiche
#
# Voraussetzung: 01_setup_and_scales.R wurde ausgeführt
#
# ==============================================================================

# ==============================================================================
# WORKSPACE LADEN
# ==============================================================================

cat("Lade Workspace von 01_setup_and_scales.R...\n")

# Verwende zentrale Konfiguration falls verfügbar (aus run_all.R)
if (!exists("WORKSPACE_FILE")) {
  WORKSPACE_FILE <- "data/workspace.RData"
}

load(WORKSPACE_FILE)
cat("✓ Workspace geladen:", WORKSPACE_FILE, "\n")
cat("  Enthält: data, print_section(), fisher_z_test()\n\n")

print_section("SUBGRUPPENANALYSEN: STRESSBELASTUNG")

# ==============================================================================
# DEFINITIONEN
# ==============================================================================

validitaetskriterien <- c("Zufriedenheit", "Neurotizismus", "Resilienz")
skala <- "Stressbelastung_kurz"

cat("Analysiere Stressbelastung über demographische Subgruppen\n\n")

# ==============================================================================
# ANALYSE NACH GESCHLECHT
# ==============================================================================

cat("### Validität nach Geschlecht\n\n")

data_gender <- subset(data, Geschlecht %in% c("1", "2"))
n_male <- sum(data_gender$Geschlecht == "1")
n_female <- sum(data_gender$Geschlecht == "2")

gender_results <- list()

cat("Stressbelastung:\n\n")
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

  key <- paste(skala, krit, sep = "_")
  gender_results[[key]] <- list(
    male_r = cor_male$estimate,
    female_r = cor_female$estimate,
    z = fisher$z,
    p = fisher$p
  )
}

# ==============================================================================
# ANALYSE NACH BILDUNG
# ==============================================================================

cat("\n### Validität nach Bildungsniveau\n\n")

# Bildung_gruppiert wurde bereits in 01_setup_and_scales.R erstellt
data_bildung <- subset(data, Bildung_gruppiert %in% c("Niedrig", "Mittel", "Hoch"))
n_niedrig <- sum(data_bildung$Bildung_gruppiert == "Niedrig")
n_mittel <- sum(data_bildung$Bildung_gruppiert == "Mittel")
n_hoch <- sum(data_bildung$Bildung_gruppiert == "Hoch")

bildung_results <- list()

cat("Stressbelastung:\n\n")
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

# ==============================================================================
# ANALYSE NACH ALTER
# ==============================================================================

cat("\n### Validität nach Alter\n\n")

# Alter_gruppiert wurde bereits in 01_setup_and_scales.R erstellt
data_alter <- subset(data, !is.na(Alter_gruppiert))
n_jung <- sum(data_alter$Alter_gruppiert == "Jung")
n_mittel_alter <- sum(data_alter$Alter_gruppiert == "Mittel")
n_alt <- sum(data_alter$Alter_gruppiert == "Alt")

alter_results <- list()

cat("Stressbelastung:\n\n")
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
    "  Jung (<30):     r = ", round(cor_jung$estimate, 3),
    ", p = ", format.pval(cor_jung$p.value, digits = 3), "\n"
  ))
  cat(paste0(
    "  Mittel (30-45): r = ", round(cor_mittel_alter$estimate, 3),
    ", p = ", format.pval(cor_mittel_alter$p.value, digits = 3), "\n"
  ))
  cat(paste0(
    "  Alt (>45):      r = ", round(cor_alt$estimate, 3),
    ", p = ", format.pval(cor_alt$p.value, digits = 3), "\n"
  ))

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

# ==============================================================================
# ANALYSE NACH BESCHÄFTIGUNG
# ==============================================================================

cat("\n### Validität nach Beschäftigung\n\n")

# Beschäftigung_gruppiert wurde bereits in 01_setup_and_scales.R erstellt
data_beschaeftigung <- subset(data, Beschäftigung_gruppiert != "Andere" & !is.na(Beschäftigung_gruppiert))
beschaeftigung_gruppen <- unique(data_beschaeftigung$Beschäftigung_gruppiert)
beschaeftigung_gruppen <- beschaeftigung_gruppen[!is.na(beschaeftigung_gruppen)]

for (gruppe in beschaeftigung_gruppen) {
  n <- sum(data_beschaeftigung$Beschäftigung_gruppiert == gruppe)
  cat(paste0("  ", gruppe, ": n = ", n, "\n"))
}
cat("\n")

beschaeftigung_results <- list()

cat("Stressbelastung:\n\n")
for (krit in validitaetskriterien) {
  cat(paste0(krit, ":\n"))
  cors <- list()
  for (gruppe in beschaeftigung_gruppen) {
    subset_data <- data_beschaeftigung[data_beschaeftigung$Beschäftigung_gruppiert == gruppe, ]
    if (nrow(subset_data) >= 10) {
      cor_result <- cor.test(subset_data[[skala]], subset_data[[krit]])
      cors[[gruppe]] <- cor_result
      cat(paste0(
        "  ", gruppe, ": r = ", round(cor_result$estimate, 3),
        ", p = ", format.pval(cor_result$p.value, digits = 3), "\n"
      ))
    }
  }

  if (length(cors) >= 2) {
    gruppe1 <- names(cors)[1]
    gruppe2 <- names(cors)[2]
    n1 <- sum(data_beschaeftigung$Beschäftigung_gruppiert == gruppe1)
    n2 <- sum(data_beschaeftigung$Beschäftigung_gruppiert == gruppe2)
    fisher <- fisher_z_test(cors[[gruppe1]]$estimate, n1, cors[[gruppe2]]$estimate, n2)
    cat(paste0(
      "  ", gruppe1, " vs. ", gruppe2, ": z = ", round(fisher$z, 3),
      ", p = ", format.pval(fisher$p, digits = 3),
      ifelse(fisher$p < 0.05, " *", ""), "\n"
    ))
  }
  cat("\n")

  key <- paste(skala, krit, sep = "_")
  if (length(cors) >= 2) {
    gruppe1 <- names(cors)[1]
    gruppe2 <- names(cors)[2]
    n1 <- sum(data_beschaeftigung$Beschäftigung_gruppiert == gruppe1)
    n2 <- sum(data_beschaeftigung$Beschäftigung_gruppiert == gruppe2)
    fisher <- fisher_z_test(cors[[gruppe1]]$estimate, n1, cors[[gruppe2]]$estimate, n2)
    beschaeftigung_results[[key]] <- list(
      cors = cors,
      fisher_z = fisher$z,
      fisher_p = fisher$p,
      gruppe1 = gruppe1,
      gruppe2 = gruppe2
    )
  } else {
    beschaeftigung_results[[key]] <- list(cors = cors)
  }
}

cat("\n✓ Subgruppenanalysen für Stressbelastung abgeschlossen\n")
cat("  Plots werden in 08_create_subgroup_plots.R erstellt\n\n")
cat("Führen Sie als nächstes aus: 06_validity_subgroups_symptoms.R\n\n")
