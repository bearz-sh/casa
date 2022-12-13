
$ErrorActionPreference = 'stop'
$cwd  = (Resolve-Path "$PsScriptRoot/../").Path

if (Test-Path "$cwd/etc/env.txt") {
    return (Get-Content "$cwd/etc/env.txt").Trim()
}

return "dev"