function Export-NmapToCsv {
    [CmdletBinding()]
    param (
        [Parameter()]
        $NmapObject,
        [Parameter()]
        [string]
        $FolderPath,
        [Parameter()]
        [string]
        $FileBaseName
    ) 

    $FileName = $FileBaseName + ".csv"
    $FileFullPath = Join-Path -Path $FolderPath -ChildPath $FileName
    $NmapObject |Export-Csv -Path $FileFullPath
}