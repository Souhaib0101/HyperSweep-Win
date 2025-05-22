$trash = "$env:USERPROFILE\Desktop\tmp\.trash"
if (Test-Path $trash) {
    $items = Get-ChildItem $trash -File
    if ($items.Count -eq 0) {
        Write-Host "Trash is empty."
    } else {
        $items | Select-Object Name, LastWriteTime,
        @{Name="DaysLeft";Expression={30 - ((Get-Date) - $_.LastWriteTime).Days}} |
        Sort-Object LastWriteTime
    }
} else {
    Write-Host "Trash folder not found."
}
