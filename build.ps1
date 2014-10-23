Param(
[string]$vm_username,
[string]$vm_password,
[string]$vm_name,
[string]$azure_service_name,
[switch]$new
)

Write-Host "Starting execution at:"(Get-Date -Format g)

$secpasswd = ConvertTo-SecureString $vm_password -AsPlainText -Force
$cred=New-Object System.Management.Automation.PSCredential ($vm_username, $secpasswd)

if ($new){
    $image_name = "sql2012exp-20140925-13769"
    Write-Host 'Removing previous VM'
    Remove-AzureVM -ServiceName $azure_service_name -Name $vm_name -DeleteVHD
    Remove-AzureService -ServiceName $azure_service_name -Force
 
    Write-Host 'Spinning New Azure VM'
    New-AzureQuickVM -ServiceName $azure_service_name -Windows -Name $vm_name -ImageName $image_name -Password $cred.GetNetworkCredential().Password -AdminUsername $cred.UserName -InstanceSize Medium -Location "South Central US" -WaitForBoot

    Write-Host 'Adding Azure End Point 8080 for TFS'
    Get-AzureVM -ServiceName $azure_service_name -Name $vm_name | Add-AzureEndpoint -Name "TFS" -Protocol "tcp" -PublicPort 8080 -LocalPort 8080 | Update-AzureVM

    Write-Host 'Adding Azure End Point 9090 for Tfs Listener'
    Get-AzureVM -ServiceName $azure_service_name -Name $vm_name | Add-AzureEndpoint -Name "TfsListener" -Protocol "tcp" -PublicPort 9090 -LocalPort 9090 | Update-AzureVM
}

$script_path_step3 = 'New-TeamProject.ps1'
$script_path_step4 = 'New-SampleData.ps1'
$script_path_step5 = 'Install-TfsListener.ps1'
$script_path_step6 = 'Configure-TfsListener.ps1'

#$boxstarterVM = Enable-BoxstarterVM -Provider azure -CloudServiceName $azure_service_name -VMName $vm_name -Credential $cred
#$boxstarterVM | Install-BoxstarterPackage -Package tfsexpress.standard -Credential $cred
#$boxstarterVM | Install-BoxstarterPackage -Package tfsexpress.build -Credential $cred
#$boxstarterVM | Install-BoxstarterPackage -Package VisualStudio2013Professional -Credential $cred
#$boxstarterVM | Install-BoxstarterPackage -Package git -Credential $cred
#$boxstarterVM | Install-BoxstarterPackage -Package tfs2013powertools -Credential $cred
Restart-AzureVM -ServiceName $azure_service_name -Name $vm_name
Invoke-RmtAzure "$vm_username" "$vm_password" "$vm_name" "$azure_service_name" "$script_path_step3"
Invoke-RmtAzure "$vm_username" "$vm_password" "$vm_name" "$azure_service_name" "$script_path_step4"
Invoke-RmtAzure "$vm_username" "$vm_password" "$vm_name" "$azure_service_name" "$script_path_step5"

$Url="https://www14.v1host.com/v1sdktesting/"
$Password="remote"
$UserName="remote"
Invoke-RmtAzure "$vm_username" "$vm_password" "$vm_name" "$azure_service_name" "$script_path_step6" @($azure_service_name,$Url,$Password,$UserName)

Write-Host "Ending execution at:"(Get-Date -Format g)