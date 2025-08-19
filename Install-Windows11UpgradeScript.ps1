<#PSScriptInfo

.VERSION 1.0.0

.GUID 183e74aa-0614-4822-be86-02eda1da1ce7

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

.DESCRIPTION 
 Copy Windows 11 upgrade script to the computer 

#> 
param(
    [ValidateNotNull()]
    [string]$PowershellScriptUrl = 'https://raw.githubusercontent.com/SysadminMartinOlsson/PowerShell-scripts/refs/heads/main/Start-Windows11Upgrade.ps1',

    [ValidateNotNull()]
    [string]$BatchScriptUrl = 'https://raw.githubusercontent.com/SysadminMartinOlsson/PowerShell-scripts/refs/heads/main/UpgradeToWindows11.bat',

    [string]$ShortcutPath = "$env:PUBLIC\Desktop\Upgrade to Windows 11.lnk",

    [switch]$Force
)

$systemDrive = $env:SystemDrive
if ([string]::IsNullOrEmpty($systemDrive)) {
    $systemDrive = 'C:'
}

# Determine if the system is eligible for upgrade.
$isSystemEligibleForUpgrade = $false
$osName = (Get-ComputerInfo).OsName
if ($osName -match 'Windows 10') {
    $isSystemEligibleForUpgrade = $true
}

$tempDirectoryPath = Join-Path -Path $systemDrive -ChildPath 'Temp'
$powershellScriptDestinationPath = Join-Path -Path $tempDirectoryPath -ChildPath ([URI]$PowershellScriptUrl).Segments[-1]
$batchScriptDestinationPath = Join-Path -Path $tempDirectoryPath -ChildPath ([URI]$BatchScriptUrl).Segments[-1]
$installerFilePath = Join-Path -Path $tempDirectoryPath -ChildPath 'Windows11InstallationAssistant.exe'

if ($isSystemEligibleForUpgrade -or $Force) {
    if (-not (Test-Path -Path $tempDirectoryPath)) {
        Write-Verbose 'Creating temp directory...'
        New-Item -Path $tempDirectoryPath -ItemType Directory
    }

    # Download the PowerShell script.
    $webClient = New-Object System.Net.WebClient
    $webClient.DownloadFile($PowershellScriptUrl, $powershellScriptDestinationPath)

    # Download the Batch script.
    $webClient.DownloadFile($BatchScriptUrl, $batchScriptDestinationPath)

    if (
        (-not [string]::IsNullOrEmpty($ShortcutPath)) -and
        (-not (Test-Path -Path $ShortcutPath)) -and
        (Test-Path -Path $batchScriptDestinationPath)
    ) {
        # Create shortcut to the batch file.
        $shell = New-Object -ComObject WScript.Shell
        $shortcut = $shell.CreateShortcut($ShortcutPath)
        $shortcut.TargetPath = $batchScriptDestinationPath
        $shortcut.Save()
    }
}
else {
    # Remove installer files/shortcuts if the system isn't eligible for upgrade
    # (which should mean that the computer has already been upgraded to Windows 11).
    if (Test-Path -Path $powershellScriptDestinationPath -PathType Leaf) {
        Remove-Item -Path $powershellScriptDestinationPath
    }
    if (Test-Path -Path $batchScriptDestinationPath -PathType Leaf) {
        Remove-Item -Path $batchScriptDestinationPath
    }
    if (Test-Path -Path $installerFilePath -PathType Leaf) {
        Remove-Item -Path $installerFilePath
    }
    if ((-not [string]::IsNullOrEmpty($ShortcutPath)) -and (Test-Path -Path $ShortcutPath -PathType Leaf)) {
        Remove-Item -Path $ShortcutPath
    }
}