import csv
import re
import xml.etree.ElementTree as ET
from datetime import datetime

# Mapping von CSV-Spalten zu TEI-Elementen für Locations
FIELD_MAPPING = {
    'location': 'placeName',
    'ort': 'placeName',
    'place': 'placeName',
    'internal_id': 'internal_id',
    'gnd-nummer': 'gnd',
    'gndnummer': 'gnd',
    'gnd_nummer': 'gnd',
    'gnd-link': 'gnd_link',
    'gndlink': 'gnd_link',
    'gnd_link': 'gnd_link',
    'notes': 'note',
    'notizen': 'note',
    'comment': 'note',
    'anmerkungen': 'note'
}

def normalize_field_name(field_name):
    """Normalisiert Feldnamen für das Mapping"""
    return field_name.lower().strip().replace(' ', '').replace('_', '').replace('-', '')

def extract_gnd_id(gnd_value):
    """Extrahiert GND-ID aus verschiedenen Formaten"""
    if not gnd_value:
        return None
    
    # Wenn es bereits eine reine Nummer ist
    if re.match(r'^\d+(-[\dX])?$', gnd_value):
        return gnd_value
    
    # Aus URL extrahieren
    match = re.search(r'(\d+(?:-[\dX])?)', gnd_value)
    return match.group(1) if match else None

# Root <TEI> mit korrektem Namespace
tei = ET.Element("TEI")
tei.set("xmlns", "http://www.tei-c.org/ns/1.0")

# TEI-Header
teiHeader = ET.SubElement(tei, "teiHeader")
fileDesc = ET.SubElement(teiHeader, "fileDesc")

# titleStmt
titleStmt = ET.SubElement(fileDesc, "titleStmt")
ET.SubElement(titleStmt, "title").text = "Index of Locations mentioned in texts from project Digimus"

# publicationStmt
publicationStmt = ET.SubElement(fileDesc, "publicationStmt")
ET.SubElement(publicationStmt, "publisher")

# sourceDesc
sourceDesc = ET.SubElement(fileDesc, "sourceDesc")
bibl = ET.SubElement(sourceDesc, "bibl")
ET.SubElement(bibl, "publisher")

# standOff für strukturierte Daten
standOff = ET.SubElement(tei, "standOff")
listPlace = ET.SubElement(standOff, "listPlace")

# CSV lesen und verarbeiten
try:
    with open("location.csv", newline="", encoding="latin-1") as csvfile:
        reader = csv.DictReader(csvfile, delimiter=";")
        
        location_count = 0
        
        for idx, row in enumerate(reader, start=1):
            # Nur Zeilen mit Location-Daten verarbeiten
            location_name = None
            for field, value in row.items():
                if value and normalize_field_name(field) in ['location', 'ort', 'place']:
                    location_name = value.strip()
                    break
            
            if not location_name:
                continue
            
            location_count += 1
            place = ET.SubElement(listPlace, "place")
            
            # XML-ID setzen (entweder internal_ID oder generierte ID)
            place_id = None
            for field, value in row.items():
                if value and normalize_field_name(field) == 'internalid':
                    place_id = value.strip()
                    break
            
            if not place_id:
                place_id = f"L{location_count:05d}"
            
            place.set("xml:id", place_id)
            
            # Ortsname
            placeName = ET.SubElement(place, "placeName")
            placeName.text = location_name
            
            # GND-Nummer verarbeiten
            gnd_id = None
            gnd_link = None
            
            for field, value in row.items():
                if not value:
                    continue
                    
                normalized_field = normalize_field_name(field)
                
                if normalized_field in ['gndnummer', 'gnd-nummer', 'gnd_nummer']:
                    gnd_id = extract_gnd_id(value.strip())
                elif normalized_field in ['gndlink', 'gnd-link', 'gnd_link']:
                    gnd_link = value.strip()
            
            # GND als idno hinzufügen
            if gnd_id or gnd_link:
                idno = ET.SubElement(place, "idno")
                idno.set("type", "GND")
                
                # Wenn wir einen Link haben, diesen verwenden
                if gnd_link:
                    idno.set("subtype", "uri")
                    idno.text = gnd_link
                # Sonst nur die ID
                elif gnd_id:
                    idno.text = gnd_id
            
            # Weitere Felder verarbeiten (z.B. Notizen)
            for field, value in row.items():
                if not value:
                    continue
                    
                # KORRIGIERTE EINRÜCKUNG: Dies muss in der for-Schleife sein
                normalized_field = normalize_field_name(field)
                
                if normalized_field in ['notes', 'notizen', 'comment', 'anmerkungen']:
                    note = ET.SubElement(place, "note")
                    note.text = value.strip()

except FileNotFoundError:
    print("Error: location.csv file not found!")
    exit(1)
except Exception as e:
    print(f"Error processing CSV: {e}")
    exit(1)

# XML formatieren
try:
    ET.indent(tei, space="\t", level=0)
except AttributeError:
    # Fallback für ältere Python-Versionen
    pass

# XML speichern mit korrektem Encoding und Declaration
tree = ET.ElementTree(tei)
tree.write("locations-tei.xml", encoding="utf-8", xml_declaration=True)

print(f"TEI-compliant file created: locations-tei.xml")
print(f"Processed {location_count} location entries")
print("File structure follows TEI Guidelines with standOff organization")