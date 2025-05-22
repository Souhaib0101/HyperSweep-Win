Clear-Host

Write-Host "=== Testing Main-Cleaner.ps1 Program ==="
Write-Host "Choose a test scenario:"
Write-Host "1 - Light scenario: clean (subshell)"
Write-Host "2 - Medium scenario: newFile + listTrash (fork)"
Write-Host "3 - Heavy scenario: emptyInstant (thread)"

[int]$choice = 0

while ($choice -notin 1,2,3) {
    $choice = Read-Host "Enter 1, 2, or 3"
}

$confirm = Read-Host "Confirm execution of scenario $choice? (y/n)"
if ($confirm -ne 'y' -and $confirm -ne 'Y') {
    Write-Host "Test cancelled."
    exit
}

switch ($choice) {
    1 {
        Write-Host "Running light scenario: clean (subshell)"
        powershell.exe -NoProfile -File .\Main-Cleaner.ps1 -a clean -s
    }
    2 {
        Write-Host "Running medium scenario: newFile + listTrash (fork)"
        powershell.exe -NoProfile -File .\Main-Cleaner.ps1 -a newFile -n "testfile.txt" -f
        Start-Sleep -Seconds 1
        powershell.exe -NoProfile -File .\Main-Cleaner.ps1 -a listTrash -f
    }
    3 {
        Write-Host "Running heavy scenario: emptyInstant (thread)"
        powershell.exe -NoProfile -File .\Main-Cleaner.ps1 -a emptyInstant -t
    }
}
Write-Host "Test scenario $choice completed."
