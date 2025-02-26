# Define deployment parameters
$location = "centralus"
$pseudoRootManagementGroup = "arrowtest"

# Define policy assignment parameters using PowerShell hashtable
$parameters = @{
    topLevelManagementGroupPrefix = $pseudoRootManagementGroup
    policyAssignmentParameters = @{
        ALZMonitorResourceGroupName = @{ value = "rg-amba-monitoring-001" }
        ALZMonitorResourceGroupTags = @{
            value = @{
                Project     = "amba-monitoring"
                Environment = "Production"
                Owner       = "Team XYZ"
            }
        }
        ALZMonitorResourceGroupLocation = @{ value = $location }
        ALZMonitorActionGroupEmail      = @{ value = @("email1@microsoft.com", "email2@microsoft.com") }
    }
}

# Execute the PowerShell deployment command for management group
New-AzManagementGroupDeployment `
    -Name "amba-ServiceHealthAssignment" `
    -Location $location `
    -ManagementGroupId $pseudoRootManagementGroup `
    -TemplateFile ".\patterns\alz\policyAssignments\DINE-ServiceHealthAssignment.json" `
    -TemplateParameterObject $parameters
