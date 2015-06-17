from sys import argv

script, filename = argv

import os
import zipfile

def convert_manuscript(self):

    # must be .docx or .docm
    path_to_xml_file = self.replace("docx", "xml").replace('docm', 'xml')
    extension = os.path.splitext(self)[1]

    if extension in ('.docx', '.docm', '.doc'):
        # convert to xml
        document = zipfile.ZipFile(self)
        xml_content = document.read('word/document.xml')
        document.close()
        
        file = open(path_to_xml_file, "w")
        file.write(xml_content)
        file.close()

        return 
        
convert_manuscript( filename )