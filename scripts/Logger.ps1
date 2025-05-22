param(
    [string]$a,         # action
    [string]$n,         # filename (name)
    [string]$l = "$PSScriptRoot\logs",  # logs dans dossier projet
    [switch]$h,         # help
    [switch]$f,         # fork
    [switch]$t,         # thread
    [switch]$s,         # subshell
    [switch]$r          # restore/reset
)

function Show-Help {
    Write-Host @"
Usage: Main-Cleaner.ps1 -a <action> [-n <name>] [-l <logDir>] [-f] [-t] [-s] [-r]

Actions:
  clean         : Run automatic cleaning
  empty         : Empty trash older than 30 days
  emptyInstant  : Empty trash immediately
  listTrash     : List files in trash
  restore       : Restore file from trash (-n required)
  newFile       : Create new tmp file (-n required)
  help          : Show this help

Options:
  -n <name>     : File name (required for newFile, restore)
  -l <dir>      : Log directory (default: $l)
  -f            : Fork (child process)
  -t            : Thread (background job)
  -s            : Subshell
  -r            : Reset settings (admin only)
  -h            : Display help

Examples:
  .\Main-Cleaner.ps1 -a clean
  .\Main-Cleaner.ps1 -a listTrash
  .\Main-Cleaner.ps1 -a emptyInstant
  .\Main-Cleaner.ps1 -a newFile -n test.txt
  .\Main-Cleaner.ps1 -a restore -n test.docx
"@
}

if ($h -or -not $a) {
    Show-Help
    exit
}

if (-not (Test-Path $l)) {
    try {
        New-Item -ItemType Directory -Path $l | Out-Null
    } catch {
        & "$PSScriptRoot\scripts\Erreur.ps1" -code 102
        exit 102
    }
}

if ($r) {
    if (-not ([bool](net session 2>$null))) {
        & "$PSScriptRoot\scripts\Erreur.ps1" -code 103
        exit 103
    }
}

function Run-Cmd($scriptPath, $paramName, $paramValue) {
    if ([string]::IsNullOrEmpty($paramName)) {
        if ($f) {
            Start-Process powershell.exe -ArgumentList "-NoProfile -File `"$scriptPath`"" -NoNewWindow
        }
        elseif ($t) {
            Start-Job -ScriptBlock { param($p) & powershell.exe -NoProfile -File $p } -ArgumentList $scriptPath | Out-Null
            Write-Host "Background job started for $scriptPath"
        }
        elseif ($s) {
            powershell.exe -NoProfile -Command "& `"$scriptPath`""
        }
        else {
            & $scriptPath
        }
    }
    else {
        $argString = "$paramName `"$paramValue`""
        if ($f) {
            Start-Process powershell.exe -ArgumentList "-NoProfile -File `"$scriptPath`" $argString" -NoNewWindow
        }
        elseif ($t) {
            Start-Job -ScriptBlock { param($p, $a) & powershell.exe -NoProfile -File $p $a } -ArgumentList $scriptPath, $argString | Out-Null
            Write-Host "Background job started for $scriptPath"
        }
        elseif ($s) {
            powershell.exe -NoProfile -Command "& `"$scriptPath`" $argString"
        }
        else {
            & $scriptPath $paramName $paramValue
        }
    }
}

switch ($a.ToLower()) {
    "clean" {
        Run-Cmd "$PSScriptRoot\scripts\Cleaner-Tmp.ps1" "" ""
    }
    "empty" {
        Run-Cmd "$PSScriptRoot\scripts\Empty-Trash.ps1" "" ""
    }
    "emptyinstant" {
        Run-Cmd "$PSScriptRoot\scripts\Empty-Trash-Instant.ps1" "" ""
    }
    "listtrash" {
        Run-Cmd "$PSScriptRoot\scripts\List-Trash.ps1" "" ""
    }
    "restore" {
        if (-not $n) {
            & "$PSScriptRoot\scripts\Erreur.ps1" -code 101
            exit 101
        }
        Run-Cmd "$PSScriptRoot\scripts\Restore-FromTrash.ps1" "-name" $n
    }
    "newfile" {
        if (-not $n) {
            & "$PSScriptRoot\scripts\Erreur.ps1" -code 101
            exit 101
        }
        Run-Cmd "$PSScriptRoot\scripts\New-TmpFile.ps1" "-name" $n
    }
    "help" {
        Show-Help
    }
    default {
        & "$PSScriptRoot\scripts\Erreur.ps1" -code 100
        exit 100
    }
}
