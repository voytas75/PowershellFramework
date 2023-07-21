$ModuleName = "powershell-awesome-framework"
#[void](Import-Module ".\${ModuleName}.psd1")
$moduleData = Get-Module -Name $ModuleName -All
$moduleVersion = $moduleData.Version.ToString()
$commandList = Get-Command -Module $ModuleName
Remove-Module $ModuleName

Write-Output "Calculating fingerprint of ${ModuleName}"
$fingerprint = foreach ( $command in $commandList )
{
    foreach ( $parameter in $command.parameters.keys )
    {
        '{0}:{1}' -f $command.name, $command.parameters[$parameter].Name
        $command.parameters[$parameter].aliases | 
            Foreach-Object { '{0}:{1}' -f $command.name, $_}
    }
}
$date = [System.Math]::Round((Get-Date -UFormat %s))
$fileName = "${moduleName}_${moduleVersion}_${date}_fingerprint.out"
$fingerprint | Out-File -FilePath $fileName -Force
if (Test-Path $fileName) {$fileName}
