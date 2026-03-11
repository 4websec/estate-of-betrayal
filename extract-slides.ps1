# extract-slides.ps1
# Extracts slide images directly from the PPTX ZIP archive.
# No PowerPoint installation required.
# Usage: .\extract-slides.ps1

param(
    [string]$PptxPath = "C:\Users\lando\Downloads\Anatomy_of_Systematic_Exploitation.pptx",
    [string]$OutDir   = ".\slides"
)

$ErrorActionPreference = 'Stop'

if (-not (Test-Path $PptxPath)) {
    Write-Host "ERROR: File not found: $PptxPath" -ForegroundColor Red
    exit 1
}

if (-not (Test-Path $OutDir)) {
    New-Item -ItemType Directory -Path $OutDir | Out-Null
}
$OutDir = (Resolve-Path $OutDir).Path

# Copy PPTX to a temp ZIP so we can open it
$zipPath = [System.IO.Path]::GetTempFileName() + ".zip"
Copy-Item -Path $PptxPath -Destination $zipPath

Write-Host "Extracting media from PPTX archive..." -ForegroundColor Cyan

Add-Type -AssemblyName System.IO.Compression.FileSystem
$zip = [System.IO.Compression.ZipFile]::OpenRead($zipPath)

try {
    # Get all image entries from ppt/media/ sorted by name
    $mediaEntries = $zip.Entries |
        Where-Object { $_.FullName -match '^ppt/media/image\d+\.(jpg|jpeg|png|emf|wmf)$' } |
        Sort-Object { [regex]::Match($_.Name, '\d+').Value -as [int] }

    if ($mediaEntries.Count -eq 0) {
        Write-Host "No images found in ppt/media/. Trying all media files..." -ForegroundColor Yellow
        $mediaEntries = $zip.Entries |
            Where-Object { $_.FullName -match '^ppt/media/' -and $_.FullName -notmatch '\.xml$' } |
            Sort-Object Name
    }

    Write-Host "Found $($mediaEntries.Count) media file(s)." -ForegroundColor Cyan

    $i = 1
    foreach ($entry in $mediaEntries) {
        $ext     = [System.IO.Path]::GetExtension($entry.Name).ToLower()
        # Map emf/wmf to png since browsers can't show them; jpg/png pass through
        $outExt  = if ($ext -in '.jpg','.jpeg','.png') { $ext.TrimStart('.') } else { 'png' }
        $padded  = "{0:D2}" -f $i
        $outFile = Join-Path $OutDir "slide-$padded.$outExt"

        $stream   = $entry.Open()
        $fileStream = [System.IO.File]::Create($outFile)
        try { $stream.CopyTo($fileStream) }
        finally { $fileStream.Dispose(); $stream.Dispose() }

        Write-Host "  OK slide-$padded.$outExt  (from $($entry.Name))" -ForegroundColor Green
        $i++
    }
}
finally {
    $zip.Dispose()
    Remove-Item $zipPath -Force -ErrorAction SilentlyContinue
}

Write-Host ""
Write-Host "Done! Check the slides folder: $OutDir" -ForegroundColor Green
Write-Host ""
Write-Host "IMPORTANT: Open index.html and update R2_BASE with your Cloudflare R2 URL." -ForegroundColor Yellow
Write-Host "Then upload the slides folder contents to R2 under the 'slides/' prefix." -ForegroundColor Yellow
