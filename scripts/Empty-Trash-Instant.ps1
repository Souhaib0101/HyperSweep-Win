$trash = "$env:USERPROFILE\Desktop\tmp\.trash"

if (Test-Path $trash) {
    Get-ChildItem $trash -File | Remove-Item -Force
    Write-Host "Trash is now empty."
} else {
    Write-Host "Trash not found !"
}
