# Converts all Word files in $folderpath directory to .xml files
# If that xml file already exists it is replaced
# original Word file remains in directory also
param([string]$inputFile)
$currVolPath=Get-Location
$currVol=split-path $currVolPath -Qualifier			#C: or S:	
$filenameSplit=split-path $inputFile -Leaf			#file name without path
$filename=$filenameSplit.SubString(0, $filenameSplit.LastIndexOf('.')).replace(' ','')	#filename w/out extension or spaces
$Logfile =echo $("S:\resources\logs\" + $filename + ".txt")

Function LogWrite
{
   Param ([string]$logstring)
   Add-content $Logfile -value "$logstring"
}

# Converts all Word docs in this directory
$folderpath=echo $($currVol + "\bookmaker_tmp\" + $filename + "\*")
$fileType = "*doc*" #converts both .doc and .docx
$SaveFormat = "microsoft.office.interop.word.WdSaveFormat" -as [type]
$word = New-Object -ComObject word.application
$word.visible = $false

Get-ChildItem -path $folderpath -include $fileType |
ForEach-Object `
{
# $path gets file name without file extension, even if name includes dots
$path = ($_.FullName).substring(0,($_.FullName).lastindexOf("."))
echo "Converting $path to xml from $fileType..."
write-host $path
$doc = $word.documents.open($_.FullName)
$wdFormatXML = 11  # XML format is 11
#originally next line read:  $doc.saveas($path, $wdFormatXML)
#Had to add [ref]s for certain versions of powershell (2.0), we'll see which way works on server
#https://richardspowershellblog.wordpress.com/2012/10/15/powershell-3-and-word/
$doc.saveas([ref]$path, [ref]$wdFormatXML)
$doc.close()
}

$word.Quit()
$word = $null

# TESTING

LogWrite "----- DOCX-TO-XML PROCESSES"

#verify filename is not null
if ($filenameSplit) {LogWrite "pass: filename is not null"}
Else {LogWrite "FAIL: filename is not null"}

#filename.xml should exist in tmp conversion dir
$ChkFile = $($currVol + "\bookmaker_tmp\" + $filename + "\" + $filename + ".xml")
$FileExists = Test-Path $ChkFile 
If ($FileExists -eq $True) {LogWrite "pass: inputFile.xml exists in $($currVol)\bookmaker_tmp\inputFile\."}
Else {LogWrite "FAIL: inputFile.xml exists in $($currVol)\bookmaker_tmp\inputFile\."}

#if input file was not an .xml the orig should still exist in bookmaker_tmp\inputFile\
$fileExt = $filenameSplit.SubString(1, $filenameSplit.LastIndexOf('.'))
$DocExists = Test-Path $folderpath -include *.doc, *.docx 
If (($fileExt -ne "xml") -And ($DocExists -eq $True)) {"pass: if orig input file was .doc or .docx, it still exists in $($currVol)\bookmaker_tmp\inputFile\."}
Else {LogWrite "FAIL: if orig input file was .doc or .docx, it still exists in $($currVol)\bookmaker_tmp\inputFile\."}

[gc]::collect()
[gc]::WaitForPendingFinalizers()