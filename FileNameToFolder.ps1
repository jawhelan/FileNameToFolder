[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# Accept folder path from .bat file
$sourceFolder = if ($args.Count -gt 0) { $args[0] } else { "." }

# Validate folder exists
try {
    $resolvedPath = Resolve-Path -Path $sourceFolder -ErrorAction Stop
    $sourceFolder = $resolvedPath.Path
} catch {
    Write-Error "Folder '$sourceFolder' does not exist."
    exit 1
}

# Settings
$maxTotalPathLength = 250
$maxFolderNameLength = 100
$logPath = Join-Path $PSScriptRoot "FileNameToFolder.log"

# Clear previous log
"" | Out-File -FilePath $logPath -Encoding UTF8

Write-Host "Processing folder: $sourceFolder" -ForegroundColor Cyan
Add-Content -Path $logPath -Value "Processing folder: $sourceFolder`n"

# Get all relevant files
$files = Get-ChildItem -Path $sourceFolder -File | Where-Object {
    $_.Extension.ToLowerInvariant() -in ".mp3", ".m4b", ".pdf"
}

if (-not $files) {
    Write-Host "No .mp3, .m4b, or .pdf files found in '$sourceFolder'."
    exit 0
}

# Group by base name (case-insensitive)
$grouped = $files | Group-Object { $_.BaseName.ToLowerInvariant() }

foreach ($group in $grouped) {
    $extensions = $group.Group | ForEach-Object { $_.Extension.ToLowerInvariant() }

    # Only create a folder if:
    # - .pdf + .mp3 OR
    # - .pdf + .m4b
    $hasPDF = $extensions -contains ".pdf"
    $hasMP3 = $extensions -contains ".mp3"
    $hasM4B = $extensions -contains ".m4b"

    if (-not ($hasPDF -and ($hasMP3 -or $hasM4B))) {
        continue
    }

    # Use original casing for folder name from first file
    $originalName = $group.Group[0].BaseName
    $safeFolderName = if ($originalName.Length -gt $maxFolderNameLength) {
        Write-Warning "Truncating folder name: '$originalName'"
        Add-Content -Path $logPath -Value "Truncated folder name: $originalName"
        $originalName.Substring(0, $maxFolderNameLength)
    } else {
        $originalName
    }

    $folderPath = Join-Path $sourceFolder $safeFolderName

    if (-not (Test-Path $folderPath)) {
        Write-Host "Creating folder: $folderPath" -ForegroundColor Green
        New-Item -Path $folderPath -ItemType Directory | Out-Null
    }

    foreach ($file in $group.Group) {
        $originalFileName = $file.Name
        $destPath = Join-Path $folderPath $originalFileName

        # Truncate file name if full path too long
        if ($destPath.Length -gt $maxTotalPathLength) {
            $baseName = [System.IO.Path]::GetFileNameWithoutExtension($file.Name)
            $ext = $file.Extension
            $allowedLength = $maxTotalPathLength - ($folderPath.Length + 1 + $ext.Length)
            $safeFileName = if ($baseName.Length -gt $allowedLength) {
                Write-Warning "Truncating file name: '$originalFileName'"
                Add-Content -Path $logPath -Value "Truncated file name: $originalFileName"
                $baseName.Substring(0, $allowedLength) + $ext
            } else {
                $baseName + $ext
            }
            $destPath = Join-Path $folderPath $safeFileName
        }

        Write-Host "Moving '$($file.Name)' → '$folderPath'" -ForegroundColor Yellow
        Add-Content -Path $logPath -Value "Moved: $($file.Name) => $folderPath"

        try {
            Move-Item -Path $file.FullName -Destination $destPath -Force
        } catch {
            Write-Warning "❌ Failed to move '$($file.FullName)': $_"
            Add-Content -Path $logPath -Value "❌ Failed to move: $($file.FullName) => $destPath"
        }
    }
}

Write-Host "`n✅ Done: Only .pdf files paired with .mp3 or .m4b were moved into folders." -ForegroundColor Cyan
Add-Content -Path $logPath -Value "`n✅ Finished at $(Get-Date)"
