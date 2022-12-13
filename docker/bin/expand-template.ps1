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

    [Parameter()]
    [switch]
    $Force 
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
$Force = $Force.ToBool()


$templatesDir = (Resolve-Path "$cwd/templates/$app").Path 
$appDir = "$cwd/apps/$target-$app"

if (!(Test-Path $appDir)) {
    New-Item $appDir -ItemType Directory
}

$appDir = (Resolve-Path $appDir).Path 

$rootEnv = "$cwd/etc/$target.env"
$rootSecrets = "$cwd/etc/$target.secrets.env"

# load all environment files first
$load = @();
if((Test-Path $rootEnv)) {
  $load += $rootEnv
}

if ((Test-Path $rootSecrets)) {
  $load += rootSecrets
}

if ($load.Length -gt 0) {
    & "$cwd/bin/get-env.ps1" -Files $load
}

$envFile = "$templatesDir/target.env.hbs"

if(Test-Path $envFile)
{
    $dest = "$appDir/.env"
    if ((!(Test-Path $dest)) -or $force) {
        $output = hbs -H "$cwd/hbs/casa.js" "$envFile" --stdout 
        $output > $dest 
    }

  
    $load +=  (Resolve-Path $dest).Path
}

$secretsEnvFile = "$templatesDir/secrets.env.hbs"
if(Test-Path $secretsEnvFile)
{
    $dest = "$appDir/secrets.env"
    if ((!(Test-Path $dest)) -or $force) {
        $output = hbs -H "$cwd/hbs/casa.js" "$secretsEnvFile" --stdout 
        $output > $dest 
    }
    
    $load +=  (Resolve-Path $dest).Path
}


if ($load.Length -gt 0) {
    & "$cwd/bin/get-env.ps1" -Files $load 
}

$templates = @()


Get-ChildItem "$templatesDir" -Recurse | Foreach-Object { 
    Write-Host $_.FullName
    if ($_.Extension -eq ".hbs") {
        $templates += $_ 
    } else {
        if($_ -is [System.IO.DirectoryInfo]) {
            return
        }
        
        $dest = $_.FullName.Replace($templatesDir, $appDir) 
        if ((!(Test-Path $dest)) -or $force) {
            $parentDir = $dest | Split-Path -Parent 
            if (!(Test-Path $parentDir)) {
                New-Item $parentDir -ItemType Directory
            }



            Copy-Item $_.FullName  $dest -Force 
        }
    }
}

foreach($file in $templates)
{
    if ($file.Name -eq "target.env.hbs" -or $file.Name -eq "secrets.env.hbs") {
        continue
    }

    $f = $file.FullName
    $dest = $f.Substring(0, $f.Length - 4)
    $dest = $dest.Replace($templatesDir, $appDir)
    if ((!(Test-Path $dest)) -or $force) {
        Write-host "$f => $dest"

        $parentDir = $dest | Split-Path -Parent 
        if (!(Test-Path $parentDir)) {
            New-Item $parentDir -ItemType Directory
        }

        $output = hbs -H "$cwd/hbs/casa.js" "$f" --stdout 
        $output > $dest
    }
}