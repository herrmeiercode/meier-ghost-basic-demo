param(
    [string]$GhostUrl = "http://localhost:2368",
    [string]$PublicUrl = "https://herrmeiercode.github.io/meier-ghost-basic-demo",
    [string]$OutputDirectory = "docs",
    [switch]$Push
)

$ErrorActionPreference = "Stop"
$repoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$outputPath = Join-Path $repoRoot $OutputDirectory

# gssg expects Unix helper commands. Git for Windows already ships them.
$gitUnixTools = Join-Path $env:ProgramFiles "Git\usr\bin"
if (Test-Path $gitUnixTools) {
    $env:Path = "$gitUnixTools;$env:Path"
} else {
    throw "Git Unix tools wurden nicht gefunden: $gitUnixTools"
}

Write-Host "Pruefe lokale Ghost-Installation unter $GhostUrl ..."
try {
    $response = Invoke-WebRequest -Uri $GhostUrl -UseBasicParsing -TimeoutSec 10
} catch {
    throw "Ghost ist unter $GhostUrl nicht erreichbar. Starte Ghost zuerst mit ghost.cmd start."
}

if ($response.StatusCode -ne 200) {
    throw "Ghost antwortet mit HTTP-Status $($response.StatusCode)."
}

if (-not (Get-Command wget.exe -ErrorAction SilentlyContinue)) {
    throw "Wget fehlt. Installiere es mit: winget install JernejSimoncic.Wget"
}

if (Test-Path $outputPath) {
    $resolvedRoot = (Resolve-Path $repoRoot).Path
    $resolvedOutput = (Resolve-Path $outputPath).Path
    if (-not $resolvedOutput.StartsWith($resolvedRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "Der Ausgabeordner liegt ausserhalb des Repositorys."
    }
    Remove-Item -Path $outputPath -Recurse -Force
}

Push-Location $repoRoot
try {
    Write-Host "Erzeuge statische Demo ..."
    npx.cmd --yes ghost-static-site-generator --domain $GhostUrl --url $PublicUrl --dest $OutputDirectory

    if ($LASTEXITCODE -ne 0) {
        throw "Der statische Export ist fehlgeschlagen."
    }

    New-Item -Path (Join-Path $outputPath ".nojekyll") -ItemType File -Force | Out-Null

    # gssg misses root-relative theme assets on Windows, so fetch them explicitly.
    $themeAssets = @("assets/css/screen.css", "assets/js/main.js")
    foreach ($assetPath in $themeAssets) {
        $assetTarget = Join-Path $outputPath ($assetPath.Replace("/", "\\"))
        $assetDirectory = Split-Path -Parent $assetTarget
        New-Item -Path $assetDirectory -ItemType Directory -Force | Out-Null
        Invoke-WebRequest -Uri "$GhostUrl/$assetPath" -UseBasicParsing -OutFile $assetTarget
    }

    $publicPath = ([System.Uri]$PublicUrl).AbsolutePath.TrimEnd("/")
    if ([string]::IsNullOrWhiteSpace($publicPath)) {
        $publicPath = ""
    }

    # Replace source URLs and root-relative paths for GitHub project pages.
    $textExtensions = @(".html", ".xml", ".txt", ".md", ".css", ".js", ".json")
    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    Get-ChildItem -Path $outputPath -Recurse -File |
        Where-Object { $textExtensions -contains $_.Extension.ToLowerInvariant() } |
        ForEach-Object {
            $fileContent = [System.IO.File]::ReadAllText($_.FullName)
            $updatedContent = $fileContent.Replace($GhostUrl, $PublicUrl)
            $updatedContent = $updatedContent.Replace("/assets/", "$publicPath/assets/")
            $updatedContent = $updatedContent.Replace("/public/", "$publicPath/public/")
            if ($updatedContent -ne $fileContent) {
                [System.IO.File]::WriteAllText($_.FullName, $updatedContent, $utf8NoBom)
            }
        }

    $localReferences = Get-ChildItem -Path $outputPath -Recurse -File |
        Select-String -Pattern "localhost:2368" -SimpleMatch

    if ($localReferences) {
        Write-Warning "Im Export wurden noch Localhost-Verweise gefunden. Bitte vor der Veroeffentlichung pruefen."
        $localReferences | Select-Object -First 20
    } else {
        Write-Host "Keine Localhost-Verweise gefunden."
    }

    Write-Host "Export abgeschlossen: $outputPath"

    if ($Push) {
        if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
            throw "Git wurde nicht gefunden."
        }

        git add docs
        $changes = git status --porcelain -- docs

        if (-not $changes) {
            Write-Host "Keine Aenderungen vorhanden."
            exit 0
        }

        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm"
        git commit -m "Demo aktualisieren ($timestamp)"
        if ($LASTEXITCODE -ne 0) { throw "Git-Commit fehlgeschlagen." }

        git push origin main
        if ($LASTEXITCODE -ne 0) { throw "Git-Push fehlgeschlagen." }

        Write-Host "Demo wurde zu GitHub uebertragen."
    } else {
        Write-Host "Zum direkten Veroeffentlichen erneut mit -Push ausfuehren."
    }
} finally {
    Pop-Location
}
