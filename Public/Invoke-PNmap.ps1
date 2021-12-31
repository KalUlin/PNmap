$Script:Config = @{
    AutoExportToCsv     = $true
    CsvExportFolderPath = "c:\PNmap\"
    XmlTempFolderPath   = $env:temp
}
$Script:NmapPresets = [ordered]@{
    Regular                       = ''
    RegularWithOsVersion          = "-O"
    RegularWithOsAndPortVersion   = "-O -sV"
    QuickScanNoPortNoDns          = "-sn -n -T4"
    QuickScanNoPortWithDns        = "-sn -T4"
    FullPortScan                  = "-p-" 
    FullPortScanOSwithPortVersion = "-p- -sV -O"
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
        [Parameter(ParameterSetName = 'Custom', Position = 1)]
        [string]
        $ArgumentString,
        [Parameter(ParameterSetName = 'Preset', Position = 2)]
        [string]
        $Preset 
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
        $FileNameXmlFullPath = (Join-Path -Path $Script:Config.XmlTempFolderPath -ChildPath $FileNameXml)
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
            
            if ($script:Config.AutoExportToCsv -eq $true) {
                if (-not (Test-Path -Path $($script:config.CsvExportFolderPath))) {
                    New-Item -Path ($script:config.CsvExportFolderPath) -ItemType Directory
                }
                Export-NmapToCsv -NmapObject $NmapObject -FolderPath ($script:config.CsvExportFolderPath) -FileBaseName $FileBaseName
            }
            
        }
    }
    $InformationPreference = $PreviousInfoPreference
}
    
New-Alias -Name pnmap -Value Invoke-PNmap