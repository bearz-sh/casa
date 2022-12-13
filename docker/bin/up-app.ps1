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
    $Environment,

    [Parameter()]
    [Switch]
    $ExpandTemplate 
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

if(!(Test-Path $appDir)) {
    & "$cwd/bin/expand-template.ps1" -App $App -Environment $Environment
} else if($ExpandTemplate) {
    & "$cwd/bin/expand-template.ps1" -App $App -Environment $Environment -Force
}



if (!(Test-Path $composeFile)) {
    throw [IO.FileNotFoundException] "compose file not found for $app at $composeFile"
}

$projectName = "$target-$app"
$splat = @("compose")

$envFiles = @(
    "$cwd/etc/$target.env",
    "$cwd/etc/$target.secrets.env"
    "$appDir/.env",
    "$appDir/secrets.env"
)

$splat += "-f"
$splat += $composeFile

$splat += "--project-name"
$splat += $projectName
$load = @();
$content = ""
foreach($e in $envFiles) {
    if ((Test-Path $e)) {
        $Content += Get-Content $e -Raw 
    }
}

Set-Content -Path "$appDir/compiled.env" -Value $Content  -Encoding "Utf8NoBom"

if((Test-Path "$appDir/up.ps1")) {
    & "$appDir/up.ps1"
}

$splat += "--env-file"
$splat += "$appDir/compiled.env"

$splat += "up"
$splat += "--no-recreate"
$splat += "--wait"



if ($IsWindows) {
    write-host "docker $($splat -join ' ')"
    docker @splat
} else {
    write-host "sudo docker $($splat -join ' ')"
    sudo docker @splat 
}