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
$target = $Environment
$cwd  = (Resolve-Path "$PsScriptRoot/../").Path

if (!(Test-Path "$cwd/etc")) {
    New-Item "$cwd/etc" -ItemType Directory
}

$Environment > "$cwd/etc/env.txt"