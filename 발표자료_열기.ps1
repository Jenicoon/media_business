$ErrorActionPreference = 'Stop'
$presentationUrl = 'http://127.0.0.1:4173'
$presentationNode = (Get-Command node -ErrorAction Stop).Source
$presentationAvailable = $false
try { $presentationResponse = Invoke-WebRequest -Uri $presentationUrl -UseBasicParsing -TimeoutSec 2; $presentationAvailable = $presentationResponse.Content.Contains('video-dialog') } catch {}
if (-not $presentationAvailable) {
    Start-Process -FilePath $presentationNode -ArgumentList ('"' + (Join-Path $PSScriptRoot 'presentation-server.cjs') + '"') -WorkingDirectory $PSScriptRoot -WindowStyle Hidden
    for ($presentationAttempt = 0; $presentationAttempt -lt 20; $presentationAttempt++) {
        try { $presentationResponse = Invoke-WebRequest -Uri $presentationUrl -UseBasicParsing -TimeoutSec 1; if ($presentationResponse.Content.Contains('video-dialog')) { $presentationAvailable = $true; break } } catch {}
        Start-Sleep -Milliseconds 200
    }
}
if (-not $presentationAvailable) { throw 'Presentation server could not start on port 4173.' }
Start-Process $presentationUrl
