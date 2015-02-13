# Converts all Word files in $folderpath directory to .xml files
# If that xml file already exists it is replaced
# original Word file remains in directory also

$SaveFormat = "microsoft.office.interop.word.WdSaveFormat" -as [type]
$word = New-Object -ComObject word.application
$word.visible = $false

# Converts all Word docs in this directory
$folderpath = "C:\Users\erica.warren\Documents\Test\*" 
$fileType = "*doc*" #converts both .doc and .docx


Get-ChildItem -path $folderpath -include $fileType |
ForEach-Object `
{
# $path gets file name without file extension, even if name includes dots
$path = ($_.FullName).substring(0,($_.FullName).lastindexOf("."))
echo "Converting $path to xml from $fileType..."
$doc = $word.documents.open($_.FullName)
$wdFormatXML = 11  # XML format is 11
$doc.saveas($path, $wdFormatXML)
$doc.close()
}

$word.Quit()
$word = $null

[gc]::collect()
[gc]::WaitForPendingFinalizers()