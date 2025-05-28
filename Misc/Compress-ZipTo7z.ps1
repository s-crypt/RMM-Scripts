<#
 .SYNOPSIS
  Recompresses Zip files to 7z archives, recursively

 .DESCRIPTION
  Recompresses all Zip files recursivly within a directory to 7z archives, and optionally does not delete the original Zip files.

 .PARAMETER Path
  The path of the directory containing the Zip files to be recompressed.

 .PARAMETER Recurse
  Whether or not to recurse into subdirectories. Default is $true.

 .PARAMETER KeepOld
  Whether or not to keep the old Zip files after recompression. Default is $false.

 .EXAMPLE
  Recompress all Zip files in the directory to 7z archives, recursively, and deleting the old Zip files.
  Compress-ZipTo7z C:\Path\To\Directory -KeepOld 0

 .EXAMPLE
  Recompress all Zip files in the directory to 7z archives, in ONLY the current folder, and deleting the old Zip files.
  Compress-ZipTo7z C:\Path\To\Directory -Recurse 0 -KeepOld 0
#>

param(
  [Parameter(Position = 0, Mandatory = $true)]
  [String]$Path,
  [Parameter(Position = 1, Mandatory = $false)]
  [Boolean]$Recurse = $true,
  [Parameter(Position = 2, Mandatory = $false)]
  [Boolean]$KeepOld = $true
)
if (Test-Path "C:\Program Files\7-Zip\7z.exe") {
  $7zPath = "C:\Program Files\7-Zip\7z.exe"

  if ($Recurse) {
    $Zips = Get-ChildItem -Path "$Path" -Filter *.zip -Recurse
  }
  else {
    $Zips = Get-ChildItem -Path "$Path" -Filter *.zip
  }

  Read-Host The following Files will be recompressed:`n$Zips.FullName

  foreach ($Zip in $Zips) {
    # Create the temporary directory
    New-Item -Path "$ENV:Temp" -Name "RecompressScript" -ItemType "Directory"

    # Extract file contents into the temporary folder
    & $7zPath e $Zip.FullName -o"$ENV:Temp/RecompressScript" -r

    # Get the file path without the extension
    $NewFilePath = Join-Path -Path $Zip.DirectoryName -ChildPath $Zip.BaseName

    # Compress the contents of the temporary folder 
    & $7zPath a "$NewFilePath`.7z" "$ENV:Temp/RecompressScript/*"

    # Delete the temporary folder if it exists
    Remove-Item "$ENV:Temp/RecompressScript" -Recurse

    if ($KeepOld -eq $false) {
      Remove-Item $Zip.FullName
    }
  }
}

else {
  Write-Host "Error: 7zip is not installed. Please make sure it is installed system-wide."
}
