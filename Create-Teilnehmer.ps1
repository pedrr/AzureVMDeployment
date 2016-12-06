
Connect-MsolService

#global variables

#$SubscriptionId = "b16fee0f-ae27-4cca-918a-e4e5f233bc94"
$location = "westeurope"

foreach ($count in 1..10) {

    $upn = "edu-tn$count@infowanedu.onmicrosoft.com"
    New-MsolUser -UserPrincipalName $upn -DisplayName "Teilnehmer $count" -FirstName $count -LastName "Teilnehmer"
    $user = Get-MsolUser -UserPrincipalName $upn
    Set-MsolUserPassword -UserPrincipalName $upn -NewPassword "InfoWan123!"
    New-MsolGroup -DisplayName "TN$count-Group" -Description "Group for TN$count"
    $group = Get-MsolGroup -SearchString "TN$count-Group"
    Add-MsolGroupMember -GroupObjectId $group.ObjectId -GroupMemberObjectId $User.ObjectId

    $RG = "RGTN$count"

    if(-not (Get-AzureRmResourceGroup $RG -ErrorAction SilentlyContinue)) {
        $AzureRG = New-AzureRmResourceGroup -Name $RG -Location $location
    }

    New-AzureRmRoleAssignment -ObjectId $group[0].ObjectId -RoleDefinitionName "Owner" -ResourceGroupName $RG
    


}