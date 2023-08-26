#Script Powershell pour la création et
#déploiement d'une machine virtuelle sur Azure
#Version: 1.0

#Parameters definition
param (
    [string]$RGName,
    [string]$Location,
    [string]$SubnetName,
    [string]$SubmetRange,
    [string]$VNetName,
    [string]$VMName,
    [string]$VNetRange,
    [string]$VMSize,
    [string]$PublicIPName,
    [string]$NSGName,
    [string]$NICName,
    [string]$Username,
    [string]$KeyVaultName,
    [string]$SecretName
)

try{
    #Connect to Azure
    Connect-AzAccount -ErrorAction Stop
}catch{
    Write-Host -ForegroundColor Red "Une erreur est survenue lors de la connexion..."
    Write-Host "$($_.exception.message)"

}

#Création d'un ressource group
New-AzResourceGroup -NAME $RGName -Location $Location

#Création d'un sous-réseau
$Subnet = New-AzVirtualNetworkSubnetConfig -Name $SubnetName -AddressPrefix $SubnetRange

$VirtualNetwork = New-AzVirtualNetwork -ResourceGroupName $RGName -Location $Location -Name $VNetName -AddressPrefix $VNetRange -Subnet $Subnet

$PublicIP = New-AzPublicIpAddress -ResourceGroupName $RGName -Location $Location -AllocationMethod "Dynamic" -Name $PublicIPName

Write-Output -InputObject "Creating SSH/RDP network security rule"
$SecurityGroupRule = switch ("-Windows") {
    "-Linux" { New-AzNetworkSecurityRuleConfig -Name "SSH-Rule" -Description "Allow SSH" -Access "Allow" -Protocol "TCP" -Direction "Inbound" -Priority 100 -DestinationPortRange 22 -SourceAddressPrefix "*" -SourcePortRange "*" -DestinationAddressPrefix "*" }
    "-Windows" { New-AzNetworkSecurityRuleConfig -Name "RDP-Rule" -Description "Allow RDP" -Access "Allow" -Protocol "TCP" -Direction "Inbound" -Priority 100 -DestinationPortRange 3389 -SourceAddressPrefix "*" -SourcePortRange "*" -DestinationAddressPrefix "*" }
}

$NetworkSG = New-AzNetworkSecurityGroup -ResourceGroupName $RGName -Location $Location -Name $NSGName -SecurityRules $SecurityGroupRule

$NetworkInterface = New-AzNetworkInterface -Name $NICName -ResourceGroupName $RGName -Location $Location -SubnetId $VirtualNetwork.Subnets[0].Id -PublicIpAddressId $PublicIP.Id -NetworkSecurityGroupId $NetworkSG.Id

$VirtualMachine = New-AzVMConfig -VMName $VMName -VMSize $VMSize

$VirtualMachine = Set-AzVMOperatingSystem -VM $VirtualMachine -Windows -ComputerName $ComputerName -Credential $Credential

$VirtualMachine = Set-AzVMOSDisk -VM $VirtualMachine -Name $VMName -Windows -DiskSizeInGB 80 -CreateOption FromImage


