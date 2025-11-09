# Diagnostisches Praktikum - Stressanalyse

Psychometrische Analyse von Stressskalen (Reliabilität und Validität)

## Dateien

### Daten
- `data_stressskala_2025-11-09_17-36.csv` - Rohdaten (ISO-8859-1, mit Anführungszeichen)
- `data.csv` - Bereinigte Daten (UTF-8, ohne Anführungszeichen)

### Skripte
- `clean_data.py` - Datenbereinigungsskript (Python 3)
- `analysis_structured.R` - Strukturierte psychometrische Analyse (R)

### Ergebnisse
- `analysis_output.txt` - Vollständiger Analyse-Output
- `plots/` - Grafiken und Plots

## Workflow

### 1. Datenbereinigung

```bash
python3 clean_data.py
```

**Was das Skript macht:**
- Liest Rohdaten (ISO-8859-1) ein
- Konvertiert nach UTF-8
- Entfernt Anführungszeichen
- Bereinigt Beschäftigungsangaben in 3 Kategorien:
  - **Studenten** (86 Personen)
  - **Angestellte** (63 Personen)
  - **Andere** (10 Personen)
- Speichert als `data.csv`

### 2. Psychometrische Analyse

```bash
Rscript analysis_structured.R > analysis_output.txt
```
