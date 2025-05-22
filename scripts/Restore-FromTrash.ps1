$trash = "$env:USERPROFILE\Desktop\tmp\.trash"
$tmp = "$env:USERPROFILE\Desktop\tmp"

$fichier = Read-Host "Enter the exact name of the file (copy from .trash)"
$source = Join-Path $trash $fichier

if (Test-Path $source) {
    Move-Item $source -Destination $tmp
    Write-Host "File restaured in tmp"
} else {
    Write-Host "File not found .trash"
}
