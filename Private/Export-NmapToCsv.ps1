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

    if (-not (Test-Path -Path $FolderPath)) {
        New-Item -Path ($FolderPath) -ItemType Directory |out-null
    }
    $FileName = $FileBaseName + ".csv"
    $FileFullPath = Join-Path -Path $FolderPath -ChildPath $FileName
    $NmapObject | Export-Csv -Path $FileFullPath
}