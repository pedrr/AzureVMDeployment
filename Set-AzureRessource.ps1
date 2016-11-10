# Login to Azure
try {
    Get-AzureRmContext | Out-Null
}
catch {
    Login-AzureRmAccount
}


#global variables

$SubscriptionId = "b16fee0f-ae27-4cca-918a-e4e5f233bc94"
$location = "westeurope"

$VMs = Import-Csv 'C:\Users\simon.scharschinger\OneDrive - infoWAN\OneDrive - infoWAN Datenkommunikation GmbH\PS-Scripts\DeployAzure\VMs.csv'
$Storages = Import-csv 'C:\Users\simon.scharschinger\OneDrive - infoWAN\OneDrive - infoWAN Datenkommunikation GmbH\PS-Scripts\DeployAzure\Storage.csv'
$Subnets = Import-csv 'C:\Users\simon.scharschinger\OneDrive - infoWAN\OneDrive - infoWAN Datenkommunikation GmbH\PS-Scripts\DeployAzure\Subnets.csv'

$username = "adminguy"
$password = "SuperStrong123"
$creds = New-Object System.Management.Automation.PSCredential -ArgumentList $username, ($password | ConvertTo-SecureString -AsPlainText -Force)


$Images = Get-AzureRmVMImageSku -Location $location -PublisherName MicrosoftWindowsServer -Offer WindowsServer

# Select Azure Subscription
Get-AzureRmSubscription -SubscriptionId $SubscriptionId | Select-AzureRmSubscription | Out-Null



foreach ($VM in $VMs) {
   

    # Test if Azure Resource Group already exist and create if not
    if(-not (Get-AzureRmResourceGroup $VM.ResourceGroup -ErrorAction SilentlyContinue)) {
        $AzureRG = New-AzureRmResourceGroup -Name $VM.ResourceGroup -Location $location
    }

    # Test if Azure Storage Account already exist and create if not
    if((Get-AzureRmStorageAccountNameAvailability $VM.ResourceGroup).NameAvailable) {
        $Storage = $Storages | Where-Object {$_.Name -eq $VM.StorageAccount}
        $StorageAccount = New-AzureRmStorageAccount -Name $Storage.Name -ResourceGroupName $VM.ResourceGroup -SkuName $Storage.SKU -Kind $Storage.Kind -Location $location
        Start-Sleep -Seconds 60
    }
    $StorageAccount = Get-AzureRmStorageAccount -Name $vm.StorageAccount -ResourceGroupName $VM.ResourceGroup
    
    $NetworkAvailable = Get-AzureRmVirtualNetwork | Where-Object {$_.Name -eq $VM.Network}
    if(-not ($NetworkAvailable)) {
        $network = $Subnets | Where-Object {$_.Name -eq $VM.Network}
        $Subnet = New-AzureRmVirtualNetworkSubnetConfig -Name $network.Name -AddressPrefix $network.Prefix
        $myVnet = New-AzureRmVirtualNetwork -Name $Network.vnet -ResourceGroupName $network.ResourceGroup -Location $location -AddressPrefix $network.Prefix -Subnet $Subnet -DnsServer "10.0.0.10","8.8.8.8"
    }

    $myVnet = Get-AzureRmVirtualNetwork -Name $VM.Network -ResourceGroupName $vm.Network

    $VMAvailability = Get-AzureRmVM | Where-Object {$_.Name -eq $VM.VMName}
    if(-not ($VMAvailability)) {
        $ImageType = $Images | Where-Object {$_.Skus -eq $vm.OS}
        if($ImageType -eq $null) {
            break
        }
        $myVm = New-AzureRMVMConfig -Name $VM.VMName -VMSize $VM.Size
        $myVm = Set-AzureRmVMOperatingSystem -VM $myVm -Windows -ComputerName $VM.VMName -Credential $creds -ProvisionVMAgent -EnableAutoUpdate
        $myVm = Set-AzureRmVmSourceImage -VM $myVm -PublisherName $ImageType.PublisherName -Offer $ImageType.Offer -Skus $ImageType.Skus -Version "latest"
        
        
        #public ip for troubleshooting
        
        $myPublicIp = New-AzureRmPublicIpAddress -Name ("PIP_"+$VM.VMName) -ResourceGroupName $vm.ResourceGroup -Location $location -AllocationMethod Dynamic
        $myNIC = New-AzureRmNetworkInterface -Name ("NIC_"+$VM.VMName) -ResourceGroupName $vm.ResourceGroup -Location $location -SubnetId $myVnet.Subnets[0].Id -PrivateIpAddress $VM.IP -PublicIpAddressId $myPublicIp.Id

        $myVM = Add-AzureRmVMNetworkInterface -VM $myVM -Id $myNIC.Id
        
        if($myVm -eq $null) {
            break
        }

        $blobPath = "vhds/"+$vm.VMName+"_OSDisk.vhd"
        $osDiskUri = $StorageAccount.PrimaryEndpoints.Blob.ToString() + $blobPath

        $myVnet = Set-AzureRmVMOSDisk -VM $myVm -Name ("OS_"+$vm.VMName) -VhdUri $osDiskUri -CreateOption FromImage
        Write-Host "Creating VM '$($vm.VMName)' in ResourceGroup '$($vm.ResourceGroup)'"
        $VMStatus = New-AzureRmVM -ResourceGroupName $vm.ResourceGroup -Location $location -VM $myVm
        If($VMStatus.StatusCode -eq "OK") {
            Write-Host "VM '$($VM.VMName)' successfully created"
            Stop-AzureRmVM -ResourceGroupName $vm.ResourceGroup -Name $VM.VMName -Force | Out-Null
        }
        else {
            Write-Host "Cannot create VM '$($VM.VMName)'"
        }
    }


}