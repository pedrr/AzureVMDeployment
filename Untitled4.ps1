$myVnet = Get-AzureRmVirtualNetwork -Name qainfrastructure -ResourceGroupName qainfrastructure

#$1myIpConfig = New-AzureRmNetworkInterfaceIpConfig -Name ("IPConfig_test") -PrivateIpAddress 10.0.0.11 -SubnetId $myVnet.Subnets[0].Id -
$1myNIC = New-AzureRmNetworkInterface -Name ("NIC_test") -ResourceGroupName qainfrastructure -Location $location -PrivateIpAddress 10.0.0.11 -SubnetId $myVnet.Subnets[0].Id

$1myNIC

#$1myVM = Add-AzureRmVMNetworkInterface -VM $myVM -Id $myNIC.Id
