function Print-Header ($header) {
  Write-Host "`n${header}`n" -ForegroundColor Cyan
}

if (-not (Test-Path Env:AZP_URL)) {
  Write-Error "error: missing AZP_URL environment variable"
  exit 1
}

if (-not (Test-Path Env:AZP_TOKEN_FILE)) {
  if (-not (Test-Path Env:AZP_TOKEN)) {
    Write-Error "error: missing AZP_TOKEN environment variable"
    exit 1
  }

$Env:AZP_TOKEN_FILE = "\azp\.token"
  $Env:AZP_TOKEN | Out-File -FilePath $Env:AZP_TOKEN_FILE
}

Remove-Item Env:AZP_TOKEN

# Let the agent ignore the token env variables
$Env:VSO_AGENT_IGNORE = "AZP_TOKEN,AZP_TOKEN_FILE"

Set-Location agent

try {
  Print-Header "1. Configuring Azure Pipelines agent..."

.\config.cmd --unattended --agent "$(if (Test-Path Env:AZP_AGENT_NAME) { ${Env:AZP_AGENT_NAME} } else { hostname })" --url "$(${Env:AZP_URL})" --auth PAT --token "$(Get-Content ${Env:AZP_TOKEN_FILE})" --pool "$(if (Test-Path Env:AZP_POOL) { ${Env:AZP_POOL} } else { 'Default' })" --work "$(if (Test-Path Env:AZP_WORK) { ${Env:AZP_WORK} } else { '_work' })" --replace

Print-Header "2. Running Azure Pipelines agent..."

.\run.cmd
} finally {
  Print-Header "Cleanup. Removing Azure Pipelines agent..."

.\config.cmd remove --unattended --auth PAT --token "$(Get-Content ${Env:AZP_TOKEN_FILE})"
}