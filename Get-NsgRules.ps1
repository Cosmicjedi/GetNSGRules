$azureSubs = Get-azSubscription |where State -eq "Enabled"
# Path to directory where you want NSG outputs, 1 csv per subscription
$exportpath = "$env:USERPROFILE\Documents\NSGs"

foreach ($azureSub in $azureSubs) {
    Set-AzContext -Subscription $azureSub | Out-Null
        $azureSubName = $azureSub.Name
    $azureNsgs = Get-AzNetworkSecurityGroup 
    foreach ( $azureNsg in $azureNsgs ) {
        # Export custom rules
        Get-AzNetworkSecurityRuleConfig -NetworkSecurityGroup $azureNsg | `
            Select-Object @{label = 'NSG Name'; expression = { $azureNsg.Name } }, `
            @{label = 'NSG Location'; expression = { $azureNsg.Location } }, `
            @{label = 'Rule Name'; expression = { $_.Name } }, `
            @{label = 'Source'; expression = { $_.SourceAddressPrefix } }, `
            @{label = 'Source Application Security Group'; expression = { $_.SourceApplicationSecurityGroups.id.Split('/')[-1] } },
            @{label = 'Source Port Range'; expression = { $_.SourcePortRange } }, Access, Priority, Direction, `
            @{label = 'Destination'; expression = { $_.DestinationAddressPrefix } }, `
            @{label = 'Destination Application Security Group'; expression = { $_.DestinationApplicationSecurityGroups.id.Split('/')[-1] } }, `
            @{label = 'Destination Port Range'; expression = { $_.DestinationPortRange } }, `
            @{label = 'Resource Group Name'; expression = { $azureNsg.ResourceGroupName } } | `
            Export-Csv -Path "$exportpath\$azureSubName-nsg-rules.csv" -NoTypeInformation -Append -force
        
        # Export default rules
        Get-AzNetworkSecurityRuleConfig -NetworkSecurityGroup $azureNsg -Defaultrules | `
            Select-Object @{label = 'NSG Name'; expression = { $azureNsg.Name } }, `
            @{label = 'NSG Location'; expression = { $azureNsg.Location } }, `
            @{label = 'Rule Name'; expression = { $_.Name } }, `
            @{label = 'Source'; expression = { $_.SourceAddressPrefix } }, `
            @{label = 'Source Port Range'; expression = { $_.SourcePortRange } }, Access, Priority, Direction, `
            @{label = 'Destination'; expression = { $_.DestinationAddressPrefix } }, `
            @{label = 'Destination Port Range'; expression = { $_.DestinationPortRange } }, `
            @{label = 'Resource Group Name'; expression = { $azureNsg.ResourceGroupName } } | `
            Export-Csv -Path "$exportpath\$azureSubName-nsg-rules.csv" -NoTypeInformation -Append -force
      }    
 
}