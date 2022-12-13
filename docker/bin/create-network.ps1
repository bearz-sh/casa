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

& "$cwd/bin/get-env.ps1" -Files "$cwd/etc/$target.env"

$splat = @(
    "network",
    "create",
    "--driver=bridge",
    "--subnet=$($Env:DOCKER_VNET_IP_RANGE)",
    "--gateway=$($Env:DOCKER_VNET_IP_GATEWAY)",
    "$($Env:DOCKER_VNET_NAME)"
)

if ($IsWindows) {
    docker @splat
} else {
    sudo docker @splat
}