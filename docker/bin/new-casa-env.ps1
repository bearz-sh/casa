param(
    [Parameter(Position = 0)]
    [string]
    $Environment = "",

    [Parameter(Position = 1)]
    [string]
    $Domain = "dev.lab"

    [Parameter(Position = 2)]
    [string]
    $IP = "127.0.0.1"
)

$ErrorActionPreference = 'stop'
$cwd  = (Resolve-Path "$PsScriptRoot/../").Path 
if ([string]::IsNullOrWhiteSpace($Environment)) {
    if (Test-Path "$cwd/etc/env.txt") {
        $Environment = (Get-Content "$cwd/etc/env.txt" -Raw).Trim()
    } else {
        $Environment = "dev"
    }
}
$target = $Environment
$envFile = "$cwd/etc/$Environment.env"

$env:TARGET = $Environment
$env:DOMAIN = $Domain
$env:IP = $IP

if ($null -eq (Get-Command hbs -EA SilentlyContinue)) {

    throw [InvalidOperationException] "The hbs (handlebars) cli app is not on the path"
}

if (!(Test-Path $envFile)) {
    write-host "running hbs"
    write-host "$envFile"
    $content = hbs --H "$cwd/hbs/casa.js" "$cwd/target.env.hbs" --stdout
    $content > "$cwd/etc/$target.env"
}