<#PSScriptInfo

.VERSION 1.0.0

.GUID 5bf239ee-ba5a-4d72-98a1-228e1d174fb5

.AUTHOR Martin Olsson

.COMPANYNAME Martin Olsson

.COPYRIGHT (c) Martin Olsson. All rights reserved.

.TAGS

.LICENSEURI

.PROJECTURI

.ICONURI

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES


.PRIVATEDATA

#>

<# 
.SYNOPSIS
Compresses files to multiple archive files.

.DESCRIPTION 
This script takes filtered files from a folder and compresses them to multiple output archive files (with limited size or file count per output archive).
Set FileSizeByteLimit to 0 for infinite file size per archive. Set FileSizeCountLimit to 0 for infinite file count per archive.

.INPUTS
None

.OUTPUTS
.None

.EXAMPLE
Compress-ToMultipleArchiveFiles -Path "$env:USERPROFILE\Downloads" -Filter "*.pdf" -Destination "$env:USERPROFILE\Desktop" -FileSizeByteLimit 100000 -FileSizeCountLimit 10

#>
param(
    [Parameter(Mandatory)]
    [ValidateNotNull()]
    [Microsoft.ActiveDirectory.Management.ADComputer]$Computer,

    [Parameter(Mandatory)]
    [ValidatePattern('^([a-zA-Z0-9]{2}:){5}[a-zA-Z0-9]{2}$')]
    [string]$MACAddress,

    [Parameter(Mandatory)]
    [ValidateNotNull()]
    [System.Management.Automation.PSCredential]$Credential
)

try {
    $formattedMACAddress = $MACAddress.Replace(':', '').ToLower()
    [guid]$netbootGuid = "00000000-0000-0000-0000-$($formattedMACAddress)"
}
catch {
    throw "Failed to generate netboot GUID for $($Computer.Name). $($PSItem)"
}

try {
    $params = @{
        Identity = $Computer
        Replace = @{ 'netbootGUID' = $netbootGuid }
        Credential = $Credential
        Confirm = $true
    }
    Set-ADComputer @params
}
catch {
    throw "Failed to configure netboot GUID for $($Computer.Name). $($PSItem)"
}

Get-ADComputer -Identity $Computer -Property netbootGUID