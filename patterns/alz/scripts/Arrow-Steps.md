# Steps to Deploy Service Health Alerts and Route Table Activity Log Alerts

1. **Build `policies-sh.json`**

    To compile your Bicep file and generate the corresponding JSON ARM template file, use the `bicep build` command. Follow these steps:

    ```powershell
    bicep build .\patterns\alz\templates\policies-sh-rt-na.bicep --outfile .\patterns\alz\policyDefinitions\policies-sh-rt-na.json
    ```

1. **Configuring variables for deployment**

    Open your preferred command-line tool (Windows PowerShell, Cmd, Bash or other Unix shells), and navigate to the root of the cloned repo and log on to Azure with an account with at least Resource Policy Contributor access at the root of the management group hierarchy where you will be creating the policies and Policy Set Definitions.

    Run the following commands:

    ```powershell
    $location="Your Azure location of choice"
    $pseudoRootManagementGroup="The pseudo root management group id parenting the identity, management and connectivity management groups"
    ```

1. **Deploy the policies**

    ```powershell
    New-AzManagementGroupDeployment -Name "amba-ServiveHealthRouteTablePolicies" -Template-File ".\patterns\alz\policyDefinitions\policies-sh-rt.json" -Location $location -ManagementGroupId $pseudoRootManagementGroup --parameters '{ \"topLevelManagementGroupPrefix\": { \"value\": \"contoso\" } }'
    ```

1. **Assign the policies**

    Run the following PowerShell scripts for the respective policy set definitions:

    Route Table Activity Log Alerts

    ```powershell
    . patterns\alz\scripts\Deploy-RouteTableAlerts.ps1
    ```

    Service Health Alerts

    ```powershell
    . patterns\alz\scripts\Deploy-ServiceHealthAlerts.ps1
    ```

1. **Remediate the policies**

      1. Go to the Azure portal and navigate to the Policy blade.
      1. Select the policy set definition you just assigned, and click on the "Remediate" button to remediate any existing resources that are not compliant with the policy.
      1. This will create a remediation task that will automatically fix any non-compliant resources.
      1. You can monitor the progress of the remediation task in the Azure portal.
