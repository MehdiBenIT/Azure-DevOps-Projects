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

# Create Resource Group
New-AzResourceGroup -Name $ResourceGroupName -Location $Location -ErrorAction Stop

# Create Virtual Network and Subnet
$SubnetConfig = New-AzVirtualNetworkSubnetConfig -Name $SubnetName -AddressPrefix $SubnetRange
$VirtualNetwork = New-AzVirtualNetwork -ResourceGroupName $ResourceGroupName -Location $Location -Name $VNetName -AddressPrefix "192.168.0.0/16" -Subnet $SubnetConfig

# Create Public IP
$PublicIp = New-AzPublicIpAddress -ResourceGroupName $ResourceGroupName -Location $Location -AllocationMethod "Dynamic" -Name "PublicIP"

# Define Security Rules
$SecurityGroupRules = @()
$SecurityGroupRules += New-AzNetworkSecurityRuleConfig -Name "SSH-Rule" -Description "Allow SSH" -Access "Allow" -Protocol "Tcp" -Direction "Inbound" -Priority 100 -DestinationPortRange 22 -SourceAddressPrefix "*" -SourcePortRange "*" -DestinationAddressPrefix "*"

# Create Network Security Group
$NetworkSecurityGroup = New-AzNetworkSecurityGroup -ResourceGroupName $ResourceGroupName -Location $Location -Name "MyNetworkSecurityGroup" -SecurityRules $SecurityGroupRules

# Create Network Interface
$Nic = New-AzNetworkInterface -Name "MyNic" -ResourceGroupName $ResourceGroupName -Location $Location -SubnetId $VirtualNetwork.Subnets[0].Id -PublicIpAddressId $PublicIp.Id -NetworkSecurityGroupId $NetworkSecurityGroup.Id

# Retrieve VM password from Azure Key Vault
$Secret = Get-AzKeyVaultSecret -VaultName $KeyVaultName -Name $SecretName
$Password = $Secret.SecretValue | ConvertTo-SecureString

# Create VM Configuration
$VmConfig = New-AzVMConfig -VMName $VMName -VMSize "Standard_D2as_v4"

# Set Availability Set (Optional)
$AvailabilitySet = New-AzAvailabilitySet -ResourceGroupName $ResourceGroupName -Name "MyAvailabilitySet" -Location $Location

# Set Operating System and Credentials
$Credential = New-Object -TypeName PSCredential -ArgumentList ($Username, $Password)
$VmConfig = Set-AzVMOperatingSystem -VM $VmConfig -Windows -ComputerName $VMName -Credential $Credential

# Set OS Disk
$VmConfig = Set-AzVMOSDisk -VM $VmConfig -Name "${VMName}-OS" -Windows -DiskSizeInGB 128 -CreateOption FromImage


# Create the VM
New-AzVM -ResourceGroupName $ResourceGroupName -Location $Location -VM $VmConfig -Verbose
} catch {
    Write-Host -ForegroundColor Red "An error occurred: $($_.Exception.Message)"
    exit 1
}