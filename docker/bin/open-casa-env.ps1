
$ErrorActionPreference = 'stop'
$cwd  = (Resolve-Path "$PsScriptRoot/../").Path

$envName = & "$cwd/bin/get-casa-env.ps1"

if ($envName -and (Test-Path "$cwd/etc/$envName.env")) {
    code "$cwd/etc/$envName.env"
} else {
    write-warning "env file '$cwd/etc/$envName.env' was not found"
}