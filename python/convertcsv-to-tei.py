import csv
import xml.etree.ElementTree as ET

# Read CSV
with open("../people.csv", newline="") as csvfile:
    reader = csv.DictReader(csvfile)

    root = ET.Element("persList")

    for row in reader:
        person = ET.SubElement(root, "person")
        for key, value in row.items():
            child = ET.SubElement(person, key)
            child.text = value

# Save XML
tree = ET.ElementTree(root)
tree.write("people.xml", encoding="utf-8", xml_declaration=True)