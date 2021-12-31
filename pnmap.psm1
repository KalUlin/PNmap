$moduleRoot = Split-Path -Path $MyInvocation.MyCommand.Path -Parent
$PublicFunctions = Join-Path -Path $moduleRoot -ChildPath 'Public'
$PrivateFunctions = Join-Path -Path $moduleRoot -ChildPath 'Private'


$items = Get-ChildItem "$Publicfunctions\*.ps1" -Recurse
foreach ($i in $items) {
    . $i.FullName
}
$items = Resolve-Path "$PrivateFunctions\*.ps1" 
foreach ($i in $items) {
    . $i.ProviderPath
}
