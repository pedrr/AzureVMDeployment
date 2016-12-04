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

$username = "adminguy"
$password = "SuperStrong123"

$JsonTemplatePath = 'C:\Users\simon.scharschinger\OneDrive - infoWAN\OneDrive - infoWAN Datenkommunikation GmbH\PS-Scripts\DeployAzure\AzureVM.json'
$VMs = Import-Csv 'C:\Users\simon.scharschinger\OneDrive - infoWAN\OneDrive - infoWAN Datenkommunikation GmbH\PS-Scripts\DeployAzure\VMs.csv'
$Storages = Import-csv 'C:\Users\simon.scharschinger\OneDrive - infoWAN\OneDrive - infoWAN Datenkommunikation GmbH\PS-Scripts\DeployAzure\Storage.csv'
$Images = Get-AzureRmVMImageSku -Location $location -PublisherName MicrosoftWindowsServer -Offer WindowsServer
$RG = "dev_json2"



$parameters = @{vmName = "TestVM2";
                adminUsername="superadmin";
                adminPassword="SuperStrongPassword123";
                ipAddress="10.0.0.22"
                }

Test-AzureRmResourceGroupDeployment -ResourceGroupName $RG -TemplateFile $JsonTemplatePath -TemplateParameterObject $parameters -Verbose
#New-AzureRmResourceGroupDeployment -Name ExampleDeployment -ResourceGroupName $RG -TemplateFile $JsonTemplatePath -TemplateParameterObject $parameters

<#

foreach ($VM in $VMs) {
   

    # Test if Azure Resource Group already exist and create if not
    if(-not (Get-AzureRmResourceGroup $VM.ResourceGroup -ErrorAction SilentlyContinue)) {
        $AzureRG = New-AzureRmResourceGroup -Name $VM.ResourceGroup -Location $location
    }

    $ImageType = $Images | Where-Object {$_.Skus -eq $vm.OS}
    if($ImageType -eq $null) {
        break
    }

#>
