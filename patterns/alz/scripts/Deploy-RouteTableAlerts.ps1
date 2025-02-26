# Define deployment parameters
$location = "centralus"
$pseudoRootManagementGroup = "arrowtest"

# Define policy assignment parameters
$parameters = @{
    topLevelManagementGroupPrefix = $pseudoRootManagementGroup
    policyAssignmentParameters = @{
        ALZMonitorResourceGroupName        = @{ value = "rg-amba-monitoring-001" }
        ALZMonitorResourceGroupTags        = @{
            value = @{
                Project     = "amba-monitoring"
                Environment = "Production"
                Owner       = "Team XYZ"
            }
        }
        ALZMonitorResourceGroupLocation   = @{ value = $location }
    }
}

# Execute the PowerShell deployment command for management group
New-AzManagementGroupDeployment `
    -Name "amba-RouteTableAssignment" `
    -Location $location `
    -ManagementGroupId $pseudoRootManagementGroup `
    -TemplateFile ".\patterns\alz\policyAssignments\DINE-RouteTableAssignment.json" `
    -TemplateParameterObject $parameters
