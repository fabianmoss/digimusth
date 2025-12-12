import xml.etree.ElementTree as ET
import csv
import os
import argparse
from pathlib import Path

def load_tsv_mapping(tsv_file, location_column='location', id_column='internal_ID'):
    """Lädt die TSV-Datei und erstellt ein Dictionary mit String->ID Mapping inkl. alternativer Schreibweisen"""
    mapping = {}
    alternative_columns = ['alternativespellings', 'alternativespellings2', 
                          'alternativespellings3', 'alternativespellings4']
    
    with open(tsv_file, 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f, delimiter='\t')
        
        # Prüfe ob die angegebene ID-Spalte existiert
        if id_column not in reader.fieldnames:
            print(f"Warnung: Spalte '{id_column}' nicht gefunden. Verfügbare Spalten: {reader.fieldnames}")
            # Fallback zur zweiten Spalte falls vorhanden
            if len(reader.fieldnames) >= 2:
                id_column = reader.fieldnames[1]
                print(f"Verwende stattdessen: '{id_column}'")
            else:
                raise ValueError(f"Spalte '{id_column}' nicht gefunden und kein Fallback verfügbar")
        
        # Lese die Daten
        for row in reader:
            if location_column in row and id_column in row:
                id_value = row[id_column].strip()
                
                if id_value:  # Nur wenn ID vorhanden
                    # Hauptname
                    main_name = row[location_column].strip()
                    if main_name:
                        mapping[main_name] = id_value
                    
                    # Alternative Schreibweisen
                    for alt_col in alternative_columns:
                        if alt_col in row and row[alt_col].strip():
                            alt_name = row[alt_col].strip()
                            mapping[alt_name] = id_value
                
    return mapping

def process_xml_file(xml_file, mapping, attribute_name='ref', show_matches=True):
    """Verarbeitet eine einzelne XML-Datei und fügt Attribute zu placeName Tags hinzu"""
    try:
        # Parse XML
        tree = ET.parse(xml_file)
        root = tree.getroot()
        
        changes_made = 0
        placename_count = 0
        matches_detail = []
        
        # Suche alle Elemente
        for elem in root.iter():
            # Prüfe ob es ein placeName Tag ist
            if elem.tag.endswith('placeName') or 'placeName' in elem.tag:
                placename_count += 1
                
                if elem.text and elem.text.strip():
                    text_content = elem.text.strip()
                    
                    # Prüfe ob der Text in unserem Mapping vorhanden ist
                    if text_content in mapping:
                        elem.set(attribute_name, mapping[text_content])
                        changes_made += 1
                        matches_detail.append(f"'{text_content}' -> {attribute_name}='{mapping[text_content]}'")
        
        print(f"\n{xml_file}:")
        print(f"  Gefundene placeName Tags: {placename_count}")
        print(f"  Vorgenommene Änderungen: {changes_made}")
        
        if show_matches and matches_detail:
            print("  Matches:")
            for match in matches_detail[:10]:  # Zeige max. 10 Matches
                print(f"    ✓ {match}")
            if len(matches_detail) > 10:
                print(f"    ... und {len(matches_detail) - 10} weitere")
        
        if changes_made > 0:
            output_file = xml_file.replace('.xml', '_modified.xml')
            tree.write(output_file, encoding='utf-8', xml_declaration=True)
            print(f"  ✓ Ausgabe gespeichert: {output_file}")
        
    except Exception as e:
        print(f"✗ Fehler bei {xml_file}: {str(e)}")

def analyze_mapping(mapping):
    """Analysiert das geladene Mapping und zeigt Statistiken"""
    print("\n=== MAPPING-ANALYSE ===")
    print(f"Gesamtanzahl Einträge: {len(mapping)}")
    
    # Finde IDs mit mehreren Namen
    id_to_names = {}
    for name, id_val in mapping.items():
        if id_val not in id_to_names:
            id_to_names[id_val] = []
        id_to_names[id_val].append(name)
    
    print(f"Anzahl eindeutiger IDs: {len(id_to_names)}")
    
    # Zeige Beispiele mit alternativen Schreibweisen
    print("\nBeispiele mit alternativen Schreibweisen:")
    count = 0
    for id_val, names in id_to_names.items():
        if len(names) > 1:
            count += 1
            if count <= 5:
                print(f"  ID {id_val}:")
                for name in names:
                    print(f"    - {name}")
    
    if count > 5:
        print(f"  ... und {count - 5} weitere IDs mit alternativen Schreibweisen")

def main():
    parser = argparse.ArgumentParser(description='Fügt placeName Tags Attribute basierend auf TSV-Mapping hinzu')
    parser.add_argument('tsv_file', help='Pfad zur TSV-Datei mit Ortsname->ID Mapping')
    parser.add_argument('xml_files', nargs='+', help='Pfad zu einer oder mehreren XML-Dateien')
    parser.add_argument('-a', '--attribute', choices=['ref', 'key'], default='ref',
                        help='Name des hinzuzufügenden Attributs (Standard: ref)')
    parser.add_argument('-l', '--location-column', default='location',
                        help='Name der Spalte mit Ortsnamen in der TSV (Standard: location)')
    parser.add_argument('-c', '--id-column', default='internal_ID',
                        help='Name der Spalte mit IDs in der TSV (Standard: internal_ID)')
    parser.add_argument('-i', '--inplace', action='store_true',
                        help='Originaldateien überschreiben statt _modified.xml zu erstellen')
    parser.add_argument('--analyze', action='store_true',
                        help='Zeige Analyse des Mappings')
    parser.add_argument('--no-matches', action='store_true',
                        help='Zeige keine Details zu einzelnen Matches')
    
    args = parser.parse_args()
    
    # Lade TSV-Mapping
    print(f"Lade TSV-Datei: {args.tsv_file}")
    mapping = load_tsv_mapping(args.tsv_file, 
                             location_column=args.location_column,
                             id_column=args.id_column)
    print(f"Gefundene Mappings: {len(mapping)} (inkl. alternativer Schreibweisen)\n")
    
    if args.analyze:
        analyze_mapping(mapping)
        return
    
    # Verarbeite XML-Dateien
    for xml_file in args.xml_files:
        if '*' in xml_file:
            for file in Path('.').glob(xml_file):
                process_xml_file(str(file), mapping, args.attribute, 
                               show_matches=not args.no_matches)
        else:
            process_xml_file(xml_file, mapping, args.attribute, 
                           show_matches=not args.no_matches)

if __name__ == "__main__":
    main()