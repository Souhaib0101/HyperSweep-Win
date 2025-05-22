$trash = "$env:USERPROFILE\Desktop\tmp\.trash"
$limite = (Get-Date).AddDays(-30)

if (Test-Path $trash) {
    Get-ChildItem $trash -File | Where-Object { $_.LastWriteTime -lt $limite } | Remove-Item -Force
}
