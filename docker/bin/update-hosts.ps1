param(
    [ValidateSet("add", "remove")]
    [Parameter(Position = 0)]
    [string] 
    $Command,

    [Parameter(Position = 1)]
    [string]
    $HostName,

    [Parameter(Position = 2)]
    [string]
    $HostIp
)

$hostFile = "/etc/hosts"

if($IsWindows) {
    $hostFile = "$($ENV:WINDIR)\System32\drivers\etc\hosts"
}

switch($Command) {
    "add" {
        $lines = Get-Content $hostFile
        $content = @()
        $found = $false 
        foreach($line in $lines)
        {
            if ([string]::IsNullOrWhiteSpace($line)) {
                $content += $line;
                continue;
            }

            $parts = $line.Trim().Split(" ", "RemoveEmptyEntries")

            if($parts.Length -eq 2)
            {
                if($parts[0] -ne $HostName) {
                    $content += $line;
                    continue 
                }

                if($parts[1] -ne $HostIp) {
                    $next = "$($HostName) $($HostIp)"
                    $content += $next 
                    $found = $true 
                    continue;
                }
            }

            $content += $line
        } 
        
        if(!$found) {
            $content += "$($HostName) $($HostIp)"
        }

        Set-Content -Path $hostFile -Value $content -Encoding ascii
    }

    "remove" {
        $lines = Get-Content $hostFile
        $content = @()
        $found = $false 
        foreach($line in $lines)
        {
            if ([string]::IsNullOrWhiteSpace($line)) {
                $content += $line;
                continue;
            }

            $parts = $line.Trim().Split(" ", "RemoveEmptyEntries")

            if($parts.Length -eq 2)
            {
                if($parts[0] -eq $HostName) {
                    $found = $true 
                    continue 
                }
            }

            $content += $line
        } 

        if($found) {
            Set-Content -Path $hostFile -Value $content -Encoding ascii
        }
    }
}