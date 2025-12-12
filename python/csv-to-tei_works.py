import csv
import re
import xml.etree.ElementTree as ET
from xml.dom import minidom

def load_persons_from_xml(filename):
    """Lädt Personendaten aus einer TEI-XML Datei"""
    persons = {}
    try:
        tree = ET.parse(filename)
        root = tree.getroot()
        ns = {'tei': 'http://www.tei-c.org/ns/1.0'}

        list_person = (root.find('.//tei:standOff/tei:listPerson', ns)
                       or root.find('.//tei:text/tei:body/tei:listPerson', ns)
                       or root.find('.//tei:listPerson', ns))

        if list_person is not None:
            for person in list_person.findall('tei:person', ns):
                person_id = person.get('{http://www.w3.org/XML/1998/namespace}id') or person.get('xml:id')
                if person_id:
                    person_data = {'surname': '', 'forename': ''}
                    pers_name = person.find('.//tei:persName', ns)
                    if pers_name is not None:
                        forename = pers_name.find('tei:forename', ns)
                        if forename is not None and forename.text:
                            person_data['forename'] = forename.text.strip()
                        surname = pers_name.find('tei:surname', ns)
                        if surname is not None and surname.text:
                            person_data['surname'] = surname.text.strip()
                    persons[person_id] = person_data

        print(f"Loaded {len(persons)} persons from {filename}")
        return persons
    except FileNotFoundError:
        print(f"Warning: {filename} not found. Using empty person list.")
        return {}
    except Exception as e:
        print(f"Error loading persons from {filename}: {e}")
        return {}

def determine_title_level(title, comment_field):
    """Bestimmt den Publikationstyp"""
    if comment_field and 'journal' in comment_field.lower():
        return 'j'  # Journal
    elif any(k in title.lower() for k in ['symphony', 'quintet', 'concerto']):
        return 'u'  # Musikwerk/unspezifiziert
    else:
        return 'm'  # Monographie

# Personendaten aus people.xml laden
PERSON_DATA = load_persons_from_xml("people.xml")

# Root <TEI> mit korrektem Namespace
tei = ET.Element("TEI")
tei.set("xmlns", "http://www.tei-c.org/ns/1.0")

# TEI-Header
teiHeader = ET.SubElement(tei, "teiHeader")
fileDesc = ET.SubElement(teiHeader, "fileDesc")

titleStmt = ET.SubElement(fileDesc, "titleStmt")
ET.SubElement(titleStmt, "title").text = "Index of Works mentioned in texts from project Digimus"

publicationStmt = ET.SubElement(fileDesc, "publicationStmt")
ET.SubElement(publicationStmt, "publisher")

sourceDesc = ET.SubElement(fileDesc, "sourceDesc")
bibl_hdr = ET.SubElement(sourceDesc, "bibl")
ET.SubElement(bibl_hdr, "publisher")

# standOff / listBibl
standOff = ET.SubElement(tei, "standOff")
listBibl = ET.SubElement(standOff, "listBibl")

# CSV lesen und verarbeiten
try:
    with open("works.csv", newline="", encoding="utf-8-sig") as csvfile:
        reader = csv.DictReader(csvfile, delimiter=";")
        
        for row in reader:
            # Internal ID verwenden
            internal_id = row.get('internal ID', '').strip()
            if not internal_id:
                continue
                
            bibl = ET.SubElement(listBibl, "bibl")
            # xml:id mit der internal ID
            bibl.set("{http://www.w3.org/XML/1998/namespace}id", internal_id)

            # Title
            title_text = row.get('title', '').strip()
            if title_text:
                title_elem = ET.SubElement(bibl, "title")
                comment_field = row.get('comment', '').strip()
                level = determine_title_level(title_text, comment_field)
                title_elem.set("level", level)
                title_elem.text = title_text

            # Author ohne n-Attribut
            author_id = row.get('Author ID', '').strip()
            if author_id:
                author_elem = ET.SubElement(bibl, "author")
                
                # Erstelle name Element mit ref
                name_elem = ET.SubElement(author_elem, "name")
                name_elem.set("ref", f"./people.xml#{author_id}")
                name_elem.set("type", "person")
                
                # Optional: Name aus PERSON_DATA einfügen, falls vorhanden
                if author_id in PERSON_DATA:
                    person = PERSON_DATA[author_id]
                    name_parts = []
                    if person.get('forename'):
                        name_parts.append(person['forename'])
                    if person.get('surname'):
                        name_parts.append(person['surname'])
                    if name_parts:
                        name_elem.text = ' '.join(name_parts)

            # URL (Wikidata) - nur wenn vorhanden
            url = row.get('URL', '').strip()
            if url:
                idno_elem = ET.SubElement(bibl, "idno")
                idno_elem.set("type", "wikidata")
                idno_elem.text = url

            # Comment als note (wenn vorhanden)
            comment = row.get('comment', '').strip()
            if comment:
                ET.SubElement(bibl, "note").text = comment

except FileNotFoundError:
    print("Error: works.csv file not found!")
    raise SystemExit(1)
except Exception as e:
    print(f"Error processing CSV: {e}")
    raise SystemExit(1)

# Personenverzeichnis hinzufügen 
if PERSON_DATA:
    listPerson = ET.SubElement(standOff, "listPerson")
    for person_id, person_data in PERSON_DATA.items():
        person_elem = ET.SubElement(listPerson, "person")
        person_elem.set("{http://www.w3.org/XML/1998/namespace}id", person_id)
        persName = ET.SubElement(person_elem, "persName")
        if person_data.get("forename"):
            ET.SubElement(persName, "forename").text = person_data["forename"]
        if person_data.get("surname"):
            ET.SubElement(persName, "surname").text = person_data["surname"]

xml_str = ET.tostring(tei, encoding="utf-8")
parsed = minidom.parseString(xml_str)
pretty_xml = parsed.toprettyxml(indent="  ", encoding="utf-8")
pretty_xml_clean = b"\n".join([line for line in pretty_xml.splitlines() if line.strip()])

try:
    with open("works.xml", "wb") as f:
        f.write(pretty_xml_clean)
    print("TEI-Datei works.xml erfolgreich erstellt.")
except Exception as e:
    print(f"Fehler beim Schreiben der TEI-Datei: {e}")