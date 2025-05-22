# Extrait du bloc à intégrer dans Cleaner-Tmp.ps1
$trash = "$tmpPath\.trash"
New-Item -ItemType Directory -Force -Path $trash | Out-Null

Get-ChildItem -Path $tmpPath -Recurse -File | ForEach-Object {
    $age = (Get-Date) - $_.LastWriteTime
    if ($age.TotalDays -ge $delaiMax -and $_.FullName -notlike "*\.trash*") {
        $timestamp = Get-Date -Format "yyyy-MM-dd_HHmmss"
        $newName = "$($_.BaseName)_$timestamp$($_.Extension)"
        Move-Item $_.FullName -Destination "$trash\$newName"
    }
}
