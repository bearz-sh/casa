param(
    [Parameter(Position = 1)]
    [ArgumentCompleter( {
        param ( $commandName,
                $parameterName,
                $wordToComplete,
                $commandAst,
                $fakeBoundParameters )

        $dir = "$PsScriptRoot/../etc"
        # Perform calculation of tab completed values here.
        $results =@()
        Get-ChildItem "$dir/$wordToComplete*.env" | Foreach-Object { $results += $_.Name.Substring(0, $_.Name.Length - 4) }
        return $results 
    })]
    [string]
    $Environment
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

$certs = "$cwd/etc/certs"
if (!(Test-Path $certs)) {
    New-Item $certs -ItemType Directory
}

$envFile = "$cwd/etc/$target.env"

if (!(Test-Path $envFile)) {
    throw [InvalidOperationException] "Environment file for environment $Environment does not exist at $envFile. Run new-environment.ps1 or just new-env command."
}

& "$cwd/bin/get-env.ps1" -Files "$cwd/etc/$target.env"

if(!$Env:NET_DOMAIN) {
    Write-Warning "setting NET_DOMAIN to dev.lab"
    $Env:NET_DOMAIN = "dev.lab"
}

$domain = $Env:NET_DOMAIN
$pem = "$certs/$domain.pem"

if (!(Test-Path $pem)) {
    Write-Host "mkcert -key-file '$certs/$domain.key' -cert-file '$pem' '$domain' '*.$($domain)'"
    mkcert -key-file "$certs/$domain.key" -cert-file "$pem" "$domain" "*.$($domain)"
}

$chainPem = "$certs/$domain-chain.pem"

if (!(Test-Path $chainPem)) {
   cat $pem "$(mkcert -CAROOT)/rootCA.pem" > $chainPem
}

$pem = "$certs/cert.pem"
$key = "$certs/cert.key"

if (!(Test-Path $pem)) {
    Copy-Item "$chainPem"  $pem 
}

if (!(Test-Path $key)) {
    Copy-Item "$certs/$domain.key"  $key 
}