function Show-NmapOutput {
   [CmdletBinding()]
   param (
       [Parameter()]
       $NmapObject
   ) 
$ParameterList =[pscustomobject] @{
    "IPv4" = $true
    "Status" = $true
    "HostName" = $false
    "FQDN" = $false
    "IPv6" = $false
    "MAC" = $false
    "OpenTcpPorts" = $false
    "MACVendor" = $false
    "Services" = $false
    "OS" = $false
    "Script" = $false
    "Ports" = $false
}

if($NmapObject.count -eq 1){
    $NmapObject | format-list
}else{
    #    $NmapObject | format-table -AutoSize
    foreach ($Host in $NmapObject) {
        if($Host.HostName -notlike "<no-hostname>"){
            $ParameterList.HostName = $true
        }
        if($Host.FQDN -notlike "<no-fullname>"){
            $ParameterList.FQDN = $true
        }
        if($Host.IPv6 -notlike "<no-ipv6>"){
            $ParameterList.IPv6 = $true
        }
        if($Host.MAC -notlike "<no-mac>"){
            $ParameterList."MAC" = $true
        }
        # if($Host.Ports -notlike "<no-ports>"){
        #     $ParameterList.Ports = $true
        # }
        if($Host.Services -notlike "<no-services>"){
            $ParameterList.Services = $true
        }
        if($Host.OS -notlike "<no-os>"){
            $ParameterList.os = $true
        }
        if($Host.Script -notlike "<no-script>"){
            $ParameterList.script = $true
        }
        if(-not [string]::isnullorwhitespace($Host.OpenTcpPorts) ){
            $ParameterList.OpenTcpPorts = $true
        }
        if(-not [string]::isnullorwhitespace($Host.MACVendor) ){
            $ParameterList.MACVendor = $true
        }

    }

    $ParametersToDisplay = $ParameterList.psobject.properties | where {$_.value -eq $true}|select -ExpandProperty name
    $NmapObject |select $ParametersToDisplay |Sort-Object {[system.version[]]($_.IPv4)}|  format-table -AutoSize
   }
}