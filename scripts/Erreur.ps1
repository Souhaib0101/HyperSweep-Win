param(
    [int]$code
)

switch ($code) {
    100 { Write-Host "Error ${code}: Unknown action specified." -ForegroundColor Red }
    101 { Write-Host "Error ${code}: Filename (-n) is required for this action." -ForegroundColor Red }
    102 { Write-Host "Error ${code}: Failed to create log directory." -ForegroundColor Red }
    103 { Write-Host "Error ${code}: Administrator privileges are required for this option." -ForegroundColor Red }
    default { Write-Host "Error ${code}: Unknown error code." -ForegroundColor Red }
}
