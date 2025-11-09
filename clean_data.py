#!/usr/bin/env python3
"""
Datenbereinigungsskript für Stressskala-Daten

Funktionen:
1. Liest CSV-Datei im ISO-8859-1 Format ein
2. Entfernt Anführungszeichen aus Feldern
3. Konvertiert nach UTF-8
4. Bereinigt Beschäftigungsangaben in drei Kategorien:
   - Studenten: Alle Personen in Studium
   - Angestellte: Alle Erwerbstätigen (angestellt, selbstständig, beamte, etc.)
   - Andere: Arbeitslose, Rentner, Schüler, Auszubildende, etc.
5. Speichert bereinigte Daten als data.csv (UTF-8)
"""

import csv
import sys

# Konfiguration
INPUT_FILE = "data_stressskala_2025-11-09_17-36.csv"
OUTPUT_FILE = "data.csv"
INPUT_ENCODING = "iso-8859-1"
OUTPUT_ENCODING = "utf-8"


def clean_occupation(value):
    """
    Bereinigt Beschäftigungsangaben in drei Kategorien.

    Args:
        value: Rohe Beschäftigungsangabe

    Returns:
        Bereinigte Kategorie: "Studenten", "Angestellte", "Andere", oder ""
    """
    if not value or value in ["", "-", "/", "1", "DE07_01"]:
        return ""

    val_lower = value.lower()

    # STUDENTEN: Alle Studierenden
    studenten_keywords = ["student", "studium", "studier"]
    if any(x in val_lower for x in studenten_keywords):
        return "Studenten"

    # ANGESTELLTE: Alle Erwerbstätigen (angestellt, selbstständig, beamte, etc.)
    angestellte_keywords = [
        "angestellt",
        "vollzeit",
        "teilzeit",
        "werkstudent",
        "minijob",
        "arbeiten",
        "kaufmann",
        "kauffrau",
        "mitarbeit",
        "assistent",
        "referent",
        "manager",
        "erzieher",
        "lehrer",
        "pfleger",
        "therapeut",
        "buchhalter",
        "controller",
        "informatiker",
        "chemikant",
        "dachdecker",
        "soldat",
        "psycholog",
        "sozialarbeit",
        "wissenschaft",
        "sachbearbeit",
        "teamleitung",
        "projekt",
        "hotellerie",
        "immobilien",
        "shipping",
        "ingeneur",
        "kinderbetreuung",
        "postzusteller",
        "büto",
        "sozpäd",
        "adult",
        "assistenz",
        "studienrätin",
        "psycholgin",
        "technischer",
        "selbst",
        "freelance",
        "privatier",
        "beamt",
    ]
    if any(x in val_lower for x in angestellte_keywords):
        return "Angestellte"

    # ANDERE: Arbeitslose, Rentner, Schüler, Auszubildende, etc.
    andere_keywords = [
        "arbeitslos",
        "erwerbsminderung",
        "krank",
        "behinderten werkstatt",
        "ausbildung",
        "rente",
        "früh",
        "schule",
    ]
    if any(x in val_lower for x in andere_keywords):
        return "Andere"

    # Fallback - alle unbekannten Werte werden als "Andere" kategorisiert
    return "Andere"


def main():
    """Hauptfunktion zur Datenbereinigung"""

    print("Starte Datenbereinigung...")
    print(f"Input:  {INPUT_FILE} ({INPUT_ENCODING})")
    print(f"Output: {OUTPUT_FILE} ({OUTPUT_ENCODING})\n")

    try:
        # Lese Input-Datei (ISO-8859-1, mit Anführungszeichen)
        with open(INPUT_FILE, "r", encoding=INPUT_ENCODING) as infile:
            # CSV-Reader entfernt automatisch Anführungszeichen
            reader = csv.reader(infile, delimiter=";")

            # Alle Zeilen einlesen
            rows = list(reader)

        if not rows:
            print("FEHLER: Input-Datei ist leer!")
            sys.exit(1)

        # Header extrahieren
        header = rows[0]
        data_rows = rows[1:]

        # Finde Index der Beschäftigungsspalte (DE07_01)
        try:
            occupation_idx = header.index("DE07_01")
        except ValueError:
            print("FEHLER: Spalte 'DE07_01' nicht gefunden!")
            print(f"Verfügbare Spalten: {', '.join(header[:20])}...")
            sys.exit(1)

        # Bereinige Beschäftigungsangaben
        cleaned_count = 0
        for row in data_rows:
            if len(row) > occupation_idx:
                original = row[occupation_idx]
                cleaned = clean_occupation(original)
                if original != cleaned:
                    cleaned_count += 1
                row[occupation_idx] = cleaned

        # Schreibe Output-Datei (UTF-8, ohne Anführungszeichen)
        with open(OUTPUT_FILE, "w", encoding=OUTPUT_ENCODING, newline="") as outfile:
            writer = csv.writer(outfile, delimiter=";")
            writer.writerow(header)
            writer.writerows(data_rows)

        # Statistiken
        print("✓ Bereinigung erfolgreich abgeschlossen!\n")
        print("Statistiken:")
        print(f"  - Zeilen verarbeitet: {len(data_rows)}")
        print(f"  - Beschäftigungen bereinigt: {cleaned_count}")

        # Beschäftigungsverteilung
        occupation_counts = {}
        for row in data_rows:
            if len(row) > occupation_idx:
                occ = row[occupation_idx]
                occupation_counts[occ] = occupation_counts.get(occ, 0) + 1

        print("\n  Beschäftigungsverteilung:")
        for occ in ["Studenten", "Angestellte", "Andere", ""]:
            if occ in occupation_counts:
                label = occ if occ else "(leer)"
                print(f"    - {label}: {occupation_counts[occ]}")

        print(f"\n✓ Datei gespeichert als: {OUTPUT_FILE}")

    except FileNotFoundError:
        print(f"FEHLER: Input-Datei '{INPUT_FILE}' nicht gefunden!")
        print("Bitte stelle sicher, dass die Datei im aktuellen Verzeichnis liegt.")
        sys.exit(1)
    except Exception as e:
        print(f"FEHLER beim Verarbeiten der Daten: {e}")
        import traceback

        traceback.print_exc()
        sys.exit(1)


if __name__ == "__main__":
    main()
