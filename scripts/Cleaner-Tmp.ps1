# Cleaner-Tmp.ps1
Add-Type -AssemblyName System.Windows.Forms

$desktop = [Environment]::GetFolderPath("Desktop")
$tmpRoot = "$desktop\tmp"
$script:lifespanMinutes = $null

function Ask-Duration {
    while ($true) {
        $unit = Read-Host "Choose duration unit (m = minutes, h = hours, d = days) [default: d]"
        if ([string]::IsNullOrWhiteSpace($unit)) { $unit = "d" }

        switch ($unit) {
            "m" { $label = "minutes"; $max = 60; $mult = 1 }
            "h" { $label = "hours"; $max = 24; $mult = 60 }
            "d" { $label = "days"; $max = 60; $mult = 1440 }
            Default {
                Write-Host "Invalid unit. Try again." -ForegroundColor Yellow
                continue
            }
        }

        $duration = Read-Host "Enter duration (${label}: 1-$max)"
        if ($duration -match '^\d+$' -and [int]$duration -ge 1 -and [int]$duration -le $max) {
            $mins = [int]$duration * $mult
            Write-Host "Duration set to $duration $label(s)."
            $confirm = Read-Host "Confirm? (y = yes, n = no)"
            if ($confirm -eq 'y') {
                $script:lifespanMinutes = $mins
                break
            }
        } else {
            Write-Host "Invalid input. Try again." -ForegroundColor Yellow
        }
    }
}

function Show-Notification($title, $message) {
    $notify = New-Object System.Windows.Forms.NotifyIcon
    $notify.Icon = [System.Drawing.SystemIcons]::Information
    $notify.BalloonTipTitle = $title
    $notify.BalloonTipText = $message
    $notify.Visible = $true
    $notify.ShowBalloonTip(3000)
    Start-Sleep -Milliseconds 500
    $notify.Dispose()
}

function Clean-Files {
    $now = Get-Date
    $deleted = @()
    $trash = "$tmpRoot\.trash"
    if (-Not (Test-Path $tmpRoot)) { return }
    if (-Not (Test-Path $trash)) { New-Item -Path $trash -ItemType Directory -Force | Out-Null }

    Get-ChildItem -Path $tmpRoot -Recurse -File | ForEach-Object {
        # Ignorer les fichiers déjà dans .trash
        if ($_.FullName -like "$trash*") { return }

        $age = ($now - $_.CreationTime).TotalMinutes
        if ($age -gt $script:lifespanMinutes) {
            try {
                $timestamp = Get-Date -Format "yyyy-MM-dd_HHmmss"
                $newName = "$($trash)\$($_.BaseName)_$timestamp$($_.Extension)"
                Move-Item $_.FullName -Destination $newName -Force
                $deleted += Get-Item $newName
            } catch {}
        }
    }

    if ($deleted.Count -eq 1) {
        $f = $deleted[0]
        Show-Notification "1 file moved to trash" "Name: $($f.Name)`nCreated: $($f.CreationTime)"
    } elseif ($deleted.Count -gt 1) {
        $oldest = ($deleted | Sort-Object CreationTime)[0]
        $msg = "$($deleted.Count) files moved to trash.`nOldest: $($oldest.Name)`nCreated: $($oldest.CreationTime)"
        Show-Notification "$($deleted.Count) files moved" $msg
    }
}

function Watch-Loop {
    while ($true) {
        Clean-Files
        Start-Sleep -Seconds 30
    }
}

function Init-TmpFolders {
    $paths = @(
        "$tmpRoot\Word",
        "$tmpRoot\Presentation-PPT",
        "$tmpRoot\Code\c",
        "$tmpRoot\Code\js",
        "$tmpRoot\Code\java",
        "$tmpRoot\Pictures",
        "$tmpRoot\Others",
        "$tmpRoot\.trash"
    )
    foreach ($p in $paths) {
        if (-not (Test-Path $p)) { New-Item -Path $p -ItemType Directory -Force | Out-Null }
    }
    Write-Host "Screenshot folder set to: $tmpRoot\Pictures"
}

Ask-Duration
Init-TmpFolders
Watch-Loop
