<#
.SYNOPSIS Script to deploy instant clones reused ESXi instant clone script.
.NOTES  Author:  William Lam
.NOTES  Site:    www.virtuallyghetto.com
.NOTES  Reference: http://www.virtuallyghetto.com/2018/05/leveraging-instant-clone-in-vsphere-6-7-for-extremely-fast-nested-esxi-provisioning.html
#>

Import-Module InstantClone.psm1

$SourceVM = "Windows 10 Template"

$numOfVMs = 3

$ipNetwork = "192.168.20"
$ipStartingCount=50
$netmask = "255.255.255.0"
$dns = "192.168.20.10"
$gw = "192.168.20.1"
$networktype = "static" # static or dhcp

### DO NOT EDIT BEYOND HERE ###

$StartTime = Get-Date
Write-host ""
foreach ($i in 1..$numOfVMs) {
    $newVMName = "Windows-$i"

    # Generate random UUID which will be used to update
    # ESXi Host & VSAN Node UUID
    $uuid = [guid]::NewGuid()
    # Changing ESXi Host UUID requires format to be in hex
    $uuidHex = ($uuid.ToByteArray() | %{"0x{0:x}" -f $_}) -join " "

    $guestCustomizationValues = @{
        "guestinfo.ic.hostname" = "$newVMName"
        "guestinfo.ic.ipaddress" = "$ipNetwork.$ipStartingCount"
        "guestinfo.ic.netmask" = "$netmask"
        "guestinfo.ic.gateway" = "$gw"
        "guestinfo.ic.dns" = "$dns"
        "guestinfo.ic.sourcevm" = "$SourceVM"
        "guestinfo.ic.networktype" = "$networktype"
        "guestinfo.ic.uuid" = "$uuid"
        "guestinfo.ic.uuidHex" = "$uuidHex"
    }
    $ipStartingCount++

    # Create Instant Clone
    New-InstantClone -SourceVM $SourceVM -DestinationVM $newVMName -CustomizationFields $guestCustomizationValues
}

$EndTime = Get-Date
$duration = [math]::Round((New-TimeSpan -Start $StartTime -End $EndTime).TotalMinutes,2)

Write-Host -ForegroundColor Cyan  "`nTotal Instant Clones: $numOfVMs"
Write-Host -ForegroundColor Cyan  "StartTime: $StartTime"
Write-Host -ForegroundColor Cyan  "  EndTime: $EndTime"
Write-Host -ForegroundColor Green " Duration: $duration minutes"