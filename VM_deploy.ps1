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

$RGName = "RG01-LAB"
$Location = "North Europe"
$SubnetName = "Subnet01"
$SubnetRange = "192.168.1.0/24"
$VNetName = "VNET01"
$VMName = "VM01"
$VNetRange = "192.168.0.0/16"
$VMSize = "Standard_D2as_V4"
$PublicIPName = "PublicIP"
$NSGName = "NSG01"
$NICName = "NIC01"

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

$Username = "MyUser"
$Password = 'Password123!' | ConvertTo-SecureString -Force -AsPlainText
$Credential = New-Object -TypeName PSCredential -ArgumentList ($Username, $Password)

$VirtualMachine = New-AzVMConfig -VMName $VMName -VMSize $VMSize

$VirtualMachine = Set-AzVMOperatingSystem -VM $VirtualMachine -Windows -ComputerName $ComputerName -Credential $Credential

$VirtualMachine = Set-AzVMOSDisk -VM $VirtualMachine -Name "VM01-OS" -Windows -DiskSizeInGB 80 -CreateOption FromImage


