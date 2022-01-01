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

<#
.SYNOPSIS
    Powershell wrapper module for Nmap
.DESCRIPTION
    Calls Nmap with supplied agurments or with a chosen Preset.
    Displays the regular Nmap output as well as the Powershell object equivalent. It also saves this Powershell object to a csv automatically.
    Additionaly, it exposes this new nmap powershell object to the global scope for further manipulation by the user ($pnmap).
    Calling this function with no presets or arguments will display an nmap argument cheat sheet.

.EXAMPLE
    invoke-pnmap -Target '10.1.11.1' -Preset PingScan
    invoke-pnmap "10.1.11.1/24" "-T4 -F -n"

    Can also be used with the alias 'pnmap'
    pnamp -Target "10.1.22.0/24" -ArgumentString "-T4 -F -n"
.PARAMETER Target
    IP address, Host name, IP range or CIDR style addressing
    example:
        invoke-pnmap -Target "10.1.22.1" 
        invoke-pnmap -Target "10.1.22.0/24" 
        invoke-pnmap -Target "10.1.22.5-10" 
        invoke-pnmap -Target "myserver-01" 
        
.PARAMETER ArgumentString
    Custom argement string for nmap
    example: 
        invoke-pnmap -Target "10.1.22.0/24" -ArgumentString "-p- -n -T2"
.PARAMETER Preset
    Predefined Nmap presets plus custom presets. Can be found via tab-completing
    example:
        invoke-pnmap -Target "10.1.22.0/24" -Preset IntenseAllTcpPorts
.PARAMETER AutoExportToCsv
    Determines if the Powershell Nmap object is automatically saved to CSV. Default is $true
.PARAMETER CsvExportFolderPath
    Determines the path where the csv file is to be saved
    Default is the \pnmap\ folder on the main system disk.
    Will be created if it doesn't exist
.PARAMETER XmlTempFolderPath
    Determines where the temporary XML gets saved. Required to produce the Powershell Nmap object
    Default is the users's temp folder
.OUTPUTS
    Outputs the nmap powershell object to the screen and saves it to a CSV.
    Also exposes this nmap powershell object to the global scope: $pnmap or $global:pnmap
.NOTES
    Author: @Kal Ulin 2021
    Nmap Xml parser modified from original:
        https://github.com/SamuelArnold/StarKill3r/blob/master/Star%20Killer/Star%20Killer/bin/Debug/Scripts/SANS-SEC505-master/scripts/Day1-PowerShell/Parse-Nmap.ps1
#>
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