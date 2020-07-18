#.\MassDeleteVMs.ps1 <vmname> <number of vms>

$SourceVM = $args[0]
$numOfVMs = $args[1]

foreach ($i in 1..$numOfVMs) {
    $VMName = "$SourceVM-$i"

    Write-Host "Removing VM: $VMname..."

    Stop-VM -kill $VMName -Confirm:$false > $null
    Remove-VM $VMName -DeletePermanently -RunAsync:$true -Confirm:$false > $null

    $ipStartingCount++
}