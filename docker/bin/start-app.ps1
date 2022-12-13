param(
    [Parameter(Position = 0)]
    [ArgumentCompleter( {
        param ( $commandName,
                $parameterName,
                $wordToComplete,
                $commandAst,
                $fakeBoundParameters )
        # Perform calculation of tab completed values here.
        $dir = "$PsScriptRoot/../templates"
        $results = (Get-ChildItem "$dir/$wordToComplete*" | Select-Object -ExpandProperty Name)
        return $results
    })]
    [string[]]
    $App,

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
 
$appDir = "$cwd/apps/$target-$app"
$composeFile = "$appDir/docker-compose.yml"

$splat = @("compose", "-f", "$composeFile")
$splat += "--env-file"
$splat += "$appDir/compiled.env"
$splat += "start"
if (!(Test-Path $composeFile)) {
    throw [IO.FileNotFoundException] "compose file not found for $app at $composeFile"
}

if($IsWindows) {
    docker @splat 
} else {
    sudo docker @splat  
}