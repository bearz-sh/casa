param(
    [Parameter()]
    [switch]
    $Available 
)

$ErrorActionPreference = 'stop'
$cwd  = (Resolve-Path "$PsScriptRoot/../").Path 

if($Available) {
    $appsDir = "$cwd/templates"
    $children = Get-ChildItem $appsDir
    foreach($c in $children)
    {
        Write-Host $c.Name
    }
    return
}

$appsDir = "$cwd/apps"
$children = Get-ChildItem $appsDir
foreach($c in $children)
{
    Write-Host $c.Name
}
return