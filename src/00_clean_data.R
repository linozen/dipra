#!/usr/bin/env Rscript
# ==============================================================================
# Datenbereinigungsskript für Stressskala-Daten
# ==============================================================================
#
# Funktionen:
# 1. Liest CSV-Datei im ISO-8859-1 Format ein
# 2. Entfernt Anführungszeichen aus Feldern
# 3. Konvertiert nach UTF-8
# 4. Bereinigt Beschäftigungsangaben in drei Kategorien:
#    - Studenten: Alle Personen in Studium
#    - Angestellte: Alle Erwerbstätigen (angestellt, selbstständig, beamte, etc.)
#    - Andere: Arbeitslose, Rentner, Schüler, Auszubildende, etc.
# 5. Speichert bereinigte Daten als data.csv (UTF-8)
#
# ==============================================================================

# Konfiguration
# Diese Variablen werden von run_all.R gesetzt, falls nicht vorhanden verwende Defaults
if (!exists("RAW_DATA_FILE")) {
  RAW_DATA_FILE <- "data/data_stressskala_2025-12-18_10-13.csv"
}
if (!exists("CLEAN_DATA_FILE")) {
  CLEAN_DATA_FILE <- "data/data.csv"
}

input_file <- RAW_DATA_FILE
output_file <- CLEAN_DATA_FILE
input_encoding <- "ISO-8859-1"
output_encoding <- "UTF-8"


# Funktion zur Bereinigung der Beschäftigungsangaben
clean_occupation <- function(value) {
  # Leere oder ungültige Werte
  if (is.na(value) || value == "" || value %in% c("-", "/", "1", "DE07_01")) {
    return("")
  }

  val_lower <- tolower(value)

  # STUDENTEN: Alle Studierenden
  studenten_keywords <- c("student", "studium", "studier")
  if (any(grepl(paste(studenten_keywords, collapse = "|"), val_lower))) {
    return("Studenten")
  }

  # ANGESTELLTE: Alle Erwerbstätigen
  angestellte_keywords <- c(
    "angestellt", "vollzeit", "teilzeit", "werkstudent", "minijob",
    "arbeiten", "kaufmann", "kauffrau", "mitarbeit", "assistent",
    "referent", "manager", "erzieher", "lehrer", "pfleger",
    "therapeut", "buchhalter", "controller", "informatiker",
    "chemikant", "dachdecker", "soldat", "psycholog", "sozialarbeit",
    "wissenschaft", "sachbearbeit", "teamleitung", "projekt",
    "hotellerie", "immobilien", "shipping", "ingeneur",
    "kinderbetreuung", "postzusteller", "büto", "sozpäd",
    "adult", "assistenz", "studienrätin", "psycholgin",
    "technischer", "selbst", "freelance", "privatier", "beamt"
  )
  if (any(grepl(paste(angestellte_keywords, collapse = "|"), val_lower))) {
    return("Angestellte")
  }

  # ANDERE: Arbeitslose, Rentner, Schüler, Auszubildende
  andere_keywords <- c(
    "arbeitslos", "erwerbsminderung", "krank",
    "behinderten werkstatt", "ausbildung", "rente",
    "früh", "schule"
  )
  if (any(grepl(paste(andere_keywords, collapse = "|"), val_lower))) {
    return("Andere")
  }

  # Fallback - alle unbekannten Werte werden als "Andere" kategorisiert
  return("Andere")
}


# Hauptfunktion
main <- function() {
  cat("Starte Datenbereinigung...\n")
  cat(sprintf("Input:  %s (%s)\n", input_file, input_encoding))
  cat(sprintf("Output: %s (%s)\n\n", output_file, output_encoding))

  # Prüfe ob Input-Datei existiert
  if (!file.exists(input_file)) {
    cat(sprintf("FEHLER: Input-Datei '%s' nicht gefunden!\n", input_file))
    cat("Bitte stelle sicher, dass die Datei im aktuellen Verzeichnis liegt.\n")
    quit(status = 1)
  }

  # Lese Input-Datei (ISO-8859-1)
  # read.csv entfernt automatisch Anführungszeichen
  data <- tryCatch(
    {
      read.csv(input_file,
        header = TRUE,
        sep = ";",
        fileEncoding = input_encoding,
        stringsAsFactors = FALSE,
        na.strings = c("", "NA"),
        check.names = FALSE
      )
    },
    error = function(e) {
      cat(sprintf("FEHLER beim Lesen der Datei: %s\n", e$message))
      quit(status = 1)
    }
  )

  if (nrow(data) == 0) {
    cat("FEHLER: Input-Datei ist leer!\n")
    quit(status = 1)
  }

  # Filtere nur QUESTNNR = A1 (ursprüngliche Tests, keine Retests)
  if (!"QUESTNNR" %in% colnames(data)) {
    cat("WARNUNG: Spalte 'QUESTNNR' nicht gefunden!\n")
    cat("Alle Daten werden behalten (kein Filter angewendet).\n\n")
  } else {
    n_vor_filter <- nrow(data)
    data <- data[data$QUESTNNR == "A1", ]
    n_nach_filter <- nrow(data)
    n_retest_entfernt <- n_vor_filter - n_nach_filter

    cat(sprintf("✓ QUESTNNR-Filter angewendet:\n"))
    cat(sprintf("  - Vor Filter: %d Zeilen\n", n_vor_filter))
    cat(sprintf("  - Nach Filter (nur QUESTNNR=A1): %d Zeilen\n", n_nach_filter))
    cat(sprintf("  - Entfernte Retest-Fälle (QUESTNNR=B): %d\n\n", n_retest_entfernt))
  }

  # Prüfe ob Spalte DE07_01 existiert
  if (!"DE07_01" %in% colnames(data)) {
    cat("FEHLER: Spalte 'DE07_01' nicht gefunden!\n")
    cat(sprintf(
      "Verfügbare Spalten: %s...\n",
      paste(head(colnames(data), 20), collapse = ", ")
    ))
    quit(status = 1)
  }

  # Bereinige Beschäftigungsangaben
  cleaned_count <- 0
  original_values <- data$DE07_01

  # Ersetze NA durch leeren String für die Verarbeitung
  original_values[is.na(original_values)] <- ""

  # Bereinige alle Werte
  data$DE07_01 <- sapply(original_values, clean_occupation)

  # Zähle bereinigte Einträge
  cleaned_count <- sum(original_values != data$DE07_01)

  # Schreibe Output-Datei (UTF-8, ohne Anführungszeichen)
  tryCatch(
    {
      write.table(data,
        file = output_file,
        sep = ";",
        row.names = FALSE,
        col.names = TRUE,
        quote = FALSE,
        fileEncoding = output_encoding,
        na = ""
      )
    },
    error = function(e) {
      cat(sprintf("FEHLER beim Schreiben der Datei: %s\n", e$message))
      quit(status = 1)
    }
  )

  # Statistiken
  cat("✓ Bereinigung erfolgreich abgeschlossen!\n\n")
  cat("Statistiken:\n")
  cat(sprintf("  - Zeilen verarbeitet: %d\n", nrow(data)))
  cat(sprintf("  - Beschäftigungen bereinigt: %d\n", cleaned_count))

  # Beschäftigungsverteilung
  occupation_counts <- table(data$DE07_01)

  cat("\n  Beschäftigungsverteilung:\n")
  for (occ in c("Studenten", "Angestellte", "Andere", "")) {
    if (occ %in% names(occupation_counts)) {
      label <- ifelse(occ == "", "(leer)", occ)
      cat(sprintf("    - %s: %d\n", label, occupation_counts[occ]))
    }
  }

  cat(sprintf("\n✓ Datei gespeichert als: %s\n", output_file))
}

# Skript ausführen
main()
