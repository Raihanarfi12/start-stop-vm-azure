param(
    [Parameter(Mandatory = $true)]
    # Specify the name of the Virtual Machine, or use the asterisk symbol "*" to affect all VMs in the resource group
    $VMName,
    [Parameter(Mandatory = $true)]
    $ResourceGroupName,
    [Parameter(Mandatory = $false)]
    # Optionally specify Azure Subscription ID
    $AzureSubscriptionID,
    [Parameter(Mandatory = $true)]
    [ValidateSet("Start", "Stop")]
    # Specify desired Action, allowed values "Start" or "Stop"
    $Action
)

Write-Output "Script started at $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"

# temporarily hide Warning message (see Issue #2 in Github)
$WarningPreference = "SilentlyContinue"
# explicitly load the required PowerShell Az modules
Import-Module Az.Accounts,Az.Compute
# re-set WarningPreference to show Warning Messages
$WarningPreference = "Continue"

$errorCount = 0

# connect to Azure, suppress output
try {
    $null = Connect-AzAccount -Identity
}
catch {
    $ErrorMessage = "Error connecting to Azure: " + $_.Exception.message
    Write-Error $ErrorMessage
    throw $ErrorMessage
    exit
}

# select Azure subscription by ID if specified, suppress output
if ($AzureSubscriptionID) {
    try {
        $null = Select-AzSubscription -SubscriptionID $AzureSubscriptionID    
    }
    catch {
        $ErrorMessage = "Error selecting Azure Subscription ($AzureSubscriptionID): " + $_.Exception.message
        Write-Error $ErrorMessage
        throw $ErrorMessage
        exit
    }
}

# check if we are in an Azure Context
try {
    $AzContext = Get-AzContext
}
catch {
    $ErrorMessage = "Error while trying to retrieve the Azure Context: " + $_.Exception.message
    Write-Error $ErrorMessage
    throw $ErrorMessage
    exit
}
if ([string]::IsNullOrEmpty($AzContext.Subscription)) {
    $ErrorMessage = "Error. Didn't find any Azure Context. Have you assigned the permissions according to 'CustomRoleDefinition.json' to the Managed Identity?"
    Write-Error $ErrorMessage
    throw $ErrorMessage
    exit
}

$VMs = $VMName.split(',')
# Loop through all specified VMs (if more than one). The loop only executes once if only one VM is specified.
foreach ($VM in $VMs) {
    switch ($Action) {
        "Start" {
            $VirM = Get-AzVM -ResourceGroupName $ResourceGroupName -ErrorAction Stop
            # Start the VM
            try {
                Write-Output "Starting VM $($VirM.Name)..."
                $null = $VirM | Start-AzVM -ErrorAction Stop -NoWait
            }
            catch {
                $ErrorMessage = $_.Exception.message
                Write-Error "Error starting the VM $($VirM.Name): " + $ErrorMessage
                # increase error count
                $errorCount++
                Break
            }
        }
        "Stop" {
            # Stop the VM
            $VirM = Get-AzVM -ResourceGroupName $ResourceGroupName -ErrorAction Stop
            try {
                Write-Output "Stopping VM $($VirM.Name)..."
                $null = $VirM | Stop-AzVM -ErrorAction Stop -Force -NoWait
            }
            catch {
                $ErrorMessage = $_.Exception.message
                Write-Error "Error stopping the VM $($VirM.Name): " + $ErrorMessage
                # increase error count
                $errorCount++
                Break
            }
        }    
    }
}

$endOfScriptText = "Script ended at $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
if ($errorCount -gt 0) {
    throw "Errors occured: $errorCount `r`n$endofScriptText"
}
Write-Output $endOfScriptText
