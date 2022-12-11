
param(
    [Parameter(Position = 0)]
    [string[]]
    $files
)

$splat = @()

write-host "updating vars"
Write-host $files

foreach($f in $files) {
    $splat += "-e"
    $splat += $f 
}
Write-host "dotenv $($splat -join ", ") --bash -c printenv"
$results = (dotenv @splat -- bash -c printenv)

foreach($line in $results) {
    $first = $line.IndexOf("=")
    $key = $line.Substring(0, $first)
    $value = $line.SubString($first + 1)

    if([string]::IsNullOrEmpty([Environment]::GetEnvironmentVariable($key))) {
        Write-Host "add $key"
        [Environment]::SetEnvironmentVariable($key, $value);
    }
}
