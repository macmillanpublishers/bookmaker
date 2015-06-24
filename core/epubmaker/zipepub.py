from sys import argv

filename = argv[1]
filepath = argv[2]

import os
import zipfile

def zipdirs(paths, zip, compressFile = True):
    def zipdir(path, zipf, compressFile = True):
        print('zipdir: ', path)
        for root, dirs, files in os.walk(path):
            for file in files:
                path = os.path.join(root, file)
                print(path)
                if compressFile:
                    zipf.write(path, compress_type = zipfile.ZIP_DEFLATED)
                else:
                    zipf.write(path, compress_type = zipfile.ZIP_STORED)
    def zipafile(path, zipf, compressFile = True):
        print('zipafile:', path)
        if compressFile:
            zipf.write(path, compress_type = zipfile.ZIP_DEFLATED)
        else:
            zipf.write(path, compress_type = zipfile.ZIP_STORED)    
                        
    if os.path.isfile(zip):
        zipf = zipfile.ZipFile(zip, 'a')
    else:
        zipf = zipfile.ZipFile(zip, 'w')
    
    if type(paths) is str:
        print('str')
        if not os.path.isdir(paths):
            print('file')
            zipafile(paths, zipf, compressFile)
        else:
            print('dir')
            zipdir(paths, zipf, compressFile)
    if type(paths) is list:
        for path in paths:
            zipdir(path, zipf, compressFile) 

def make_epub(epubname, epubpath):

    if __name__ == '__main__':
        path = epubpath
        os.chdir(path)
        fileName = epubname
        if os.path.isfile(fileName):
            os.remove(fileName)
        zipdirs('mimetype', fileName, False)
        zipdirs(['META-INF', 'OEBPS'], fileName)

make_epub( filename, filepath )

# attribution: http://sw32.com/use-python-to-generate-epub-standard-zip-file/