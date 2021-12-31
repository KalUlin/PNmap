$Script:NmapPresets = [ordered]@{

    Intense              = '-T4 -A -v'
    IntensePlusUDP       = '-sS -sU -T4 -A -v'
    IntenseAllTcpPorts   = '-p 1-65535 -T4 -A -v'
    IntenseNoPing        = '-T4 -A -v -Pn'
    PingScan             = '-sn'
    QuickScan            = '-T4 -F'
    QuickScanPlus        = '-sV -T4 -O -F --version-light'
    QuickTraceroute      = '-sn -traceroute'
    Regular              = ""
    SlowComprehensive    = '-sS -sU -T4 -A -v -PE -PP -PS80,443 -PA3389 -PU40125 -PY -g 53 -script "default or (discovery and safe)"'

    QuickScanNoPortNoDns = "-sn -n -T4"
}

$ScriptBlock_Preset = {
    Write-Output $Script:NmapPresets.keys
}
Register-ArgumentCompleter -CommandName Invoke-PNmap -ParameterName Preset -ScriptBlock $ScriptBlock_Preset

function Invoke-PNmap {
    [CmdletBinding(DefaultParameterSetName = 'Simple')]
    param (
        [Parameter(Position = 0, ParameterSetName = 'Simple')]
        [Parameter(Position = 0, ParameterSetName = 'Preset')]
        [Parameter(Position = 0, ParameterSetName = 'Custom')]
        [string]
        $Target,
        [Parameter(Position = 1, ParameterSetName = 'Custom')]
        [string]
        $ArgumentString,
        [Parameter(Position = 2, ParameterSetName = 'Preset' )]
        [string]
        $Preset ,
        [Parameter(Position = 3, ParameterSetName = 'Simple')]
        [Parameter(Position = 3, ParameterSetName = 'Preset')]
        [Parameter(Position = 3, ParameterSetName = 'Custom')]
        [string]
        $AutoExportToCsv = $true,
        [Parameter(Position = 4, ParameterSetName = 'Simple')]
        [Parameter(Position = 4, ParameterSetName = 'Preset')]
        [Parameter(Position = 4, ParameterSetName = 'Custom')]
        [string]
        $CsvExportFolderPath = "$($env:systemdrive)\PNmap\",
        [Parameter(Position = 5, ParameterSetName = 'Simple')]
        [Parameter(Position = 5, ParameterSetName = 'Preset')]
        [Parameter(Position = 5, ParameterSetName = 'Custom')]
        [string]
        $XmlTempFolderPath = $env:temp
    )

    if ([string]::isnullorwhitespace($Target)) {
        Show-NmapCheatSheet
    }
    else {

        $PreviousInfoPreference = $InformationPreference
        $InformationPreference = 'Continue'
        
        if ($Preset) {
            $ArgumentString = $Script:NmapPresets.$Preset
        }

        
        $FileBaseName = "nmap_" + (Get-Date -Format "yyyy-MM-dd_HH-mm-ss")
        $FileNameXml = $FileBaseName + ".xml"
        $FileNameXmlFullPath = (Join-Path -Path $XmlTempFolderPath -ChildPath $FileNameXml)
        $ArgumentString += " -oX " + $FileNameXmlFullPath
        
        $ArgumentArray = @($Target)
        $ArgumentArray += $ArgumentString -split ' '
        $NmapExePath = "$((Get-Command nmap).path)"
        
        # Write-Information "Launch string: nmap $Target $ArgumentString `n"
        Write-Information "ARGUMENTS PASSED TO NMAP:"
        Write-Information ($ArgumentArray | Format-List | Out-String).trim()
        Write-Information "========================="
        & "$NmapExePath" $ArgumentArray
        if (-not $?) {
            Write-Information "NMAP EXITED WITH ERRORS"
        }
        else {
            Write-Information "Nmap exited with no errors"
            $NmapObject = ConvertFrom-NmapXml -Path $FileNameXmlFullPath
            $Global:pnmap = $NmapObject
            
            Show-NmapOutput -NmapObject $NmapObject
            
            if ($AutoExportToCsv -eq $true) {
                Export-NmapToCsv -NmapObject $NmapObject -FolderPath ($CsvExportFolderPath) -FileBaseName $FileBaseName
            }
            
        }
    }
    $InformationPreference = $PreviousInfoPreference
}
    
New-Alias -Name pnmap -Value Invoke-PNmap