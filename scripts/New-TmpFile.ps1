param([string]$name)

$desktop = [Environment]::GetFolderPath("Desktop")
$tmp = "$desktop\tmp"

Write-Host "Received name in New-TmpFile.ps1: [$name]"  # Debug output

function Get-TargetPath($name) {
    if (-not $name -or $name -notmatch '\.\w+$') {
        Write-Host "Invalid filename format. Must include an extension (e.g., .txt, .docx)." -ForegroundColor Red
        return $null
    }

    $ext = $name.Split('.')[-1].ToLower()

    switch ($ext) {
        "doc" { return "$tmp\Word\$name" }
        "docx" { return "$tmp\Word\$name" }
        "odt" { return "$tmp\Word\$name" }

        "ppt" { return "$tmp\Presentation-PPT\$name" }
        "pptx" { return "$tmp\Presentation-PPT\$name" }

        "c" { return "$tmp\Code\c\$name" }
        "js" { return "$tmp\Code\js\$name" }
        "java" { return "$tmp\Code\java\$name" }

        "png" { return "$tmp\Pictures\$name" }
        "jpg" { return "$tmp\Pictures\$name" }
        "jpeg" { return "$tmp\Pictures\$name" }
        "bmp" { return "$tmp\Pictures\$name" }
        "gif" { return "$tmp\Pictures\$name" }

        default { return "$tmp\Others\$name" }
    }
}

$target = Get-TargetPath $name
if ($target) {
    $dir = [System.IO.Path]::GetDirectoryName($target)
    if (-not (Test-Path $dir)) {
        New-Item -Path $dir -ItemType Directory -Force | Out-Null
    }
    New-Item -Path $target -ItemType File -Force | Out-Null
    Start-Process $target
    Write-Host "File created at: $target"
}