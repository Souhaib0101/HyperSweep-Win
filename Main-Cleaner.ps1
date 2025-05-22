param(
    [string]$a,         # action
    [string]$n,         # filename (name)
    [string]$l = "$PSScriptRoot\logs",  # log directory
    [switch]$h,         # help
    [switch]$f,         # fork
    [switch]$t,         # thread
    [switch]$s,         # subshell
    [switch]$r          # restore/reset (admin only)
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

function Write-Log {
    param (
        [string]$Message,
        [string]$Type = "INFO",   # INFO or ERROR
        [string]$LogDir
    )
    $logFile = Join-Path $LogDir "history.log"
    $timestamp = Get-Date -Format "yyyy-MM-dd-HH-mm-ss"
    $username = $env:USERNAME
    $entry = "$timestamp : $username : $Type : $Message"

    if ($Type -eq "ERROR") {
        Write-Error $Message
    } else {
        Write-Host $Message
    }

    try {
        Add-Content -Path $logFile -Value $entry
    } catch {
        Write-Warning "Unable to write to log file $logFile"
    }
}

# Show help if -h or no action provided
if ($h -or -not $a) {
    Show-Help
    exit
}

# Create log directory if missing
if (-not (Test-Path $l)) {
    try {
        New-Item -ItemType Directory -Path $l | Out-Null
        Write-Log -Message "Log directory created: $l" -LogDir $l
    } catch {
        Write-Log -Message "Error creating log directory: $($_.Exception.Message)" -Type "ERROR" -LogDir $l
        exit 102
    }
}

# Check admin rights for -r
if ($r) {
    if (-not ([bool](net session 2>$null))) {
        Write-Log -Message "Administrator privileges required for -r" -Type "ERROR" -LogDir $l
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
            Write-Log -Message "Background job started for $scriptPath" -LogDir $l
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
            Write-Log -Message "Background job started for $scriptPath with args: $argString" -LogDir $l
        }
        elseif ($s) {
            powershell.exe -NoProfile -Command "& `"$scriptPath`" $argString"
        }
        else {
            & $scriptPath -name $paramValue
        }
    }
}

Write-Log -Message "Requested action: $a" -LogDir $l
if ($n) { Write-Log -Message "Parameter name: $n" -LogDir $l }

switch ($a.ToLower()) {
    "clean" {
        Write-Log -Message "Starting automatic cleaning" -LogDir $l
        Run-Cmd "$PSScriptRoot\scripts\Cleaner-Tmp.ps1" "" ""
        Write-Log -Message "Finished automatic cleaning" -LogDir $l
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
            Write-Log -Message "Error: filename required for restore (-n)" -Type "ERROR" -LogDir $l
            exit 101
        }
        Run-Cmd "$PSScriptRoot\scripts\Restore-FromTrash.ps1" "-name" $n
    }
    "newfile" {
        if (-not $n) {
            Write-Log -Message "Error: filename required for newFile (-n)" -Type "ERROR" -LogDir $l
            exit 101
        }
        Run-Cmd "$PSScriptRoot\scripts\New-TmpFile.ps1" "-name" $n
    }
    "help" {
        Show-Help
    }
    default {
        Write-Log -Message "Unknown action: $a" -Type "ERROR" -LogDir $l
        exit 100
    }
}
