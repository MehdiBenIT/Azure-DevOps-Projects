# Azure VM Deployment Script

This script automates the deployment of a virtual machine in Microsoft Azure. It creates necessary resources such as a resource group, virtual network, security group, and deploys a virtual machine using Azure PowerShell.

## Prerequisites

1. [Azure PowerShell](https://docs.microsoft.com/en-us/powershell/azure/install-az-ps) installed on your machine.

## Configuration

Before running the script, make sure to set up the required parameters in the script:

1. Open `DeployAzureVM.ps1` in a text editor.

2. Edit the following parameters at the beginning of the script:
   - `$ResourceGroupName`: Name of the Azure resource group.
   - `$Location`: Azure region where resources will be deployed.
   - `$SubnetName`: Name of the subnet.
   - `$SubnetRange`: Subnet address range (CIDR format).
   - `$VNetName`: Name of the virtual network.
   - `$VMName`: Name of the virtual machine.
   - `$Username`: Username for the virtual machine.
   - `$KeyVaultName`: Azure Key Vault name.
   - `$SecretName`: Name of the secret in the Key Vault.
   - Add any additional parameters as needed.

## Execution

1. Open a PowerShell terminal.

2. Navigate to the directory containing `DeployAzureVM.ps1`.

3. Run the script with the required parameters using the following command:

   ```powershell
   .\DeployAzureVM.ps1 -ResourceGroupName "RG01" -Location "East US" -SubnetName "Subnet01" -SubnetRange "10.0.1.0/24" -VNetName "MyVNet" -VMName "MyVM" -Username "MyUser" -KeyVaultName "MyKeyVault" -SecretName "MySecret"

## Execution

This is a simplified example. Make sure to customize the script further based on your specific requirements and environment.