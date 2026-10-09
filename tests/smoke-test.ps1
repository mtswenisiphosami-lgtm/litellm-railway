# Smoke test for a LiteLLM proxy: health, model list, one chat completion, spend logged.
# Works in Windows PowerShell 5.1 and PowerShell 7.
#
# Usage:
#   $env:LITELLM_API_KEY = "sk-..."       # a VIRTUAL key with a small budget, not the master key
#   $env:BASE_URL = "https://your-app.up.railway.app"   # default: http://127.0.0.1:4000
#   $env:MODEL = "claude-haiku-5-5"       # the public model name you added in the UI
#   powershell -ExecutionPolicy Bypass -File tests\smoke-test.ps1
#
# Cost: one short chat completion (a fraction of a US cent on a cheap model).

$ErrorActionPreference = "Stop"
$BaseUrl = if ($env:BASE_URL) { $env:BASE_URL.TrimEnd("/") } else { "http://127.0.0.1:4000" }
$Model = if ($env:MODEL) { $env:MODEL } else { "claude-haiku-5-5" }
$SpendWait = if ($env:SPEND_WAIT_SECONDS) { [int]$env:SPEND_WAIT_SECONDS } else { 120 }

if (-not $env:LITELLM_API_KEY) {
    Write-Error "LITELLM_API_KEY is not set (use a virtual key, not the master key)."
    exit 2
}

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$Headers = @{ Authorization = "Bearer $($env:LITELLM_API_KEY)" }
$script:Failures = 0
function Pass($msg) { Write-Host "PASS  $msg" -ForegroundColor Green }
function Fail($msg) { Write-Host "FAIL  $msg" -ForegroundColor Red; $script:Failures++ }

function Get-KeySpend {
    try { [double](Invoke-RestMethod -Uri "$BaseUrl/key/info" -Headers $Headers -TimeoutSec 15).info.spend }
    catch { 0 }
}

Write-Host "Testing $BaseUrl with model '$Model'"

# 1. Health: proxy up and connected to Postgres
try {
    $h = Invoke-RestMethod -Uri "$BaseUrl/health/readiness" -TimeoutSec 15
    if ($h.status -eq "healthy" -and $h.db -eq "connected") { Pass "health/readiness: healthy, database connected" }
    else { Fail "health/readiness returned status=$($h.status) db=$($h.db)" }
} catch { Fail "health/readiness: $($_.Exception.Message)" }

# 2. The key can see the model
try {
    $m = Invoke-RestMethod -Uri "$BaseUrl/v1/models" -Headers $Headers -TimeoutSec 15
    if ($m.data.id -contains $Model) { Pass "/v1/models lists '$Model'" }
    else { Fail "/v1/models does not list '$Model' (found: $($m.data.id -join ', '))" }
} catch { Fail "/v1/models: $($_.Exception.Message)" }

# 3. Spend before the request
$SpendBefore = Get-KeySpend

# 4. One chat completion
$ChatOk = $false
$Body = @{
    model      = $Model
    max_tokens = 64
    messages   = @(@{ role = "user"; content = "Reply with exactly the word: pong" })
} | ConvertTo-Json -Depth 5
try {
    $r = Invoke-RestMethod -Uri "$BaseUrl/v1/chat/completions" -Method Post -Headers $Headers `
        -ContentType "application/json" -Body $Body -TimeoutSec 120
    if ($r.choices[0].message.content -match "pong") { Pass "chat completion: model replied"; $ChatOk = $true }
    else { Fail "chat completion: unexpected reply '$($r.choices[0].message.content)'"; $ChatOk = $true }
} catch { Fail "chat completion: $($_.Exception.Message)" }

# 5. Spend is recorded (spend is written in batches, so this can take up to ~60 s)
if ($ChatOk) {
    $waited = 0
    $SpendAfter = $SpendBefore
    while ($waited -le $SpendWait) {
        $SpendAfter = Get-KeySpend
        if ($SpendAfter -gt $SpendBefore) { break }
        Start-Sleep -Seconds 10; $waited += 10
    }
    if ($SpendAfter -gt $SpendBefore) { Pass "spend recorded on key: `$$SpendBefore -> `$$SpendAfter" }
    else { Fail "spend did not increase within $SpendWait s (still `$$SpendAfter)" }
}

Write-Host ""
if ($script:Failures -eq 0) { Write-Host "ALL CHECKS PASSED" -ForegroundColor Green; exit 0 }
else { Write-Host "$($script:Failures) CHECK(S) FAILED" -ForegroundColor Red; exit 1 }
