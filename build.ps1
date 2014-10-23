$env:PSModulePath='C:\Users\_service\Documents\WindowsPowerShell\Modules;C:\Users\_service\AppData\Roaming\Boxstarter;C:\Program Files\WindowsPowerShell\Modules;C:\Windows\system32\WindowsPowerShell\v1.0\Modules\;C:\Program Files (x86)\AWS Tools\PowerShell\;C:\Program Files (x86)\Microsoft SDKs\Azure\PowerShell\ServiceManagement'
Import-Module Boxstarter.Azure

(new-object Net.WebClient).DownloadString("http://psget.net/GetPsGet.ps1") | iex
Install-Module -ModuleUrl https://raw.githubusercontent.com/lremedi/AzureInstanceTools/master/AzureInstanceTools.psm1 -update

$vm_username="v1deploy"
$vm_password="Versi0n1.c26nu"
$vm_name = "vmtfs2013"
$azure_service_name = "servicetfs2013"
$new=$TRUE

Write-Host "Starting execution at:"(Get-Date -Format g)

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

$script_path_step1 = 'Install-Tfs.ps1'
$script_path_step2 = 'Install-Tools.ps1'
$script_path_step3 = 'New-TeamProject.ps1'
$script_path_step4 = 'New-SampleData.ps1'
$script_path_step5 = 'Install-TfsListener.ps1'
$script_path_step6 = 'Configure-TfsListener.ps1'

Invoke-RmtAzure "$vm_username" "$vm_password" "$vm_name" "$azure_service_name" "$script_path_step1"
#Invoke-RmtAzure "$vm_username" "$vm_password" "$vm_name" "$azure_service_name" "$script_path_step2"
#Restart-AzureVM -ServiceName $azure_service_name -Name $vm_name 
#Invoke-RmtAzure "$vm_username" "$vm_password" "$vm_name" "$azure_service_name" "$script_path_step3"
#Invoke-RmtAzure "$vm_username" "$vm_password" "$vm_name" "$azure_service_name" "$script_path_step4"
#Invoke-RmtAzure "$vm_username" "$vm_password" "$vm_name" "$azure_service_name" "$script_path_step5"

#$Url="https://www14.v1host.com/v1sdktesting/"
#$Password="remote"
#$UserName="remote"
#Invoke-RmtAzure "$vm_username" "$vm_password" "$vm_name" "$azure_service_name" "$script_path_step6" @($azure_service_name,$Url,$Password,$UserName)

Write-Host "Ending execution at:"(Get-Date -Format g)