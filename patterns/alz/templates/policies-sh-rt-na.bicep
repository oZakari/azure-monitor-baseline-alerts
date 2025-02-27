targetScope = 'managementGroup'

@metadata({ message: 'The JSON version of this file is programatically generated from Bicep. PLEASE DO NOT UPDATE MANUALLY!!' })
@description('Provide a prefix (unique at tenant-scope) for the Management Group hierarchy and other resources created as part of an Azure landing zone. DEFAULT VALUE = "alz"')
param topLevelManagementGroupPrefix string = 'arrowtest'

@description('Optionally set the deployment location for policies with Deploy If Not Exists effect. DEFAULT VALUE = "deployment().location"')
param location string = deployment().location

@description('Optionally set the scope for custom Policy Definitions used in Policy Set Definitions (Initiatives). Must be one of \'/\', \'/subscriptions/id\' or \'/providers/Microsoft.Management/managementGroups/id\'. DEFAULT VALUE = \'/providers/Microsoft.Management/managementGroups/\${topLevelManagementGroupPrefix}\'')
param scope string = tenantResourceId('Microsoft.Management/managementGroups', topLevelManagementGroupPrefix)

// Extract the environment name to dynamically determine which policies to deploy.
var cloudEnv = environment().name

// Default deployment locations used in templates
var defaultDeploymentLocationByCloudType = {
  AzureCloud: 'northeurope'
  AzureChinaCloud: 'chinaeast2'
  AzureUSGovernment: 'usgovvirginia'
}

// Used to identify template variables used in the templates for replacement.
var templateVars = {
  scope: '/providers/Microsoft.Management/managementGroups/contoso'
  defaultDeploymentLocation: '"location": "northeurope"'
  localizedDeploymentLocation: '"location": "${defaultDeploymentLocationByCloudType[cloudEnv]}"'
}

var targetDeploymentLocationByCloudType = {
  AzureCloud: location ?? 'northeurope'
  AzureChinaCloud: location ?? 'chinaeast2'
  AzureUSGovernment: location ?? 'usgovvirginia'
}

var deploymentLocation = '"location": "${targetDeploymentLocationByCloudType[cloudEnv]}"'

var loadPolicyDefinitions = {
  All: [
    // Used in Connectivity policy definitions only
    loadTextContent('../../../services/Network/routeTables/Deploy-ActivityLog-RouteTable-Update.json')
    loadTextContent('../../../services/Network/routeTables/Deploy-ActivityLog-RouteTable-Delete.json')
    loadTextContent('../../../services/Network/routeTables/Deploy-ActivityLog-RouteTable-Routes-Delete.json')

    // Used in ServiceHealth policy definitions only
    loadTextContent('../../../services/Resources/subscriptions/Deploy-ServiceHealth-ActionGroups.json')
    loadTextContent('../../../services/Resources/subscriptions/Deploy-ActivityLog-ResourceHealth-UnHealthly-Alert.json')
    loadTextContent('../../../services/Resources/subscriptions/Deploy-ActivityLog-ServiceHealth-Health.json')
    loadTextContent('../../../services/Resources/subscriptions/Deploy-ActivityLog-ServiceHealth-Incident.json')
    loadTextContent('../../../services/Resources/subscriptions/Deploy-ActivityLog-ServiceHealth-Maintenance.json')
    loadTextContent('../../../services/Resources/subscriptions/Deploy-ActivityLog-ServiceHealth-Security.json')

     // Used in Notification-Assets policy definitions only
     loadTextContent('../../../services/AlertsManagement/actionRules/Deploy-AlertProcessingRule-Deploy.json')
     loadTextContent('../../../services/AlertsManagement/actionRules/Deploy-AlertProcessingRule-Suppression.json')
  ]
  AzureCloud: []
  AzureChinaCloud: []
  AzureUSGovernment: []
}

// The following var contains lists of files containing Policy Set Definition (Initiative) resources to load, grouped by compatibility with Cloud.
// To get a full list of Azure clouds, use the az cli command "az cloud list --output table"
// We use loadTextContent instead of loadJsonContent as this allows us to perform string replacement operations against the imported templates.
// Use string(loadJsonContent('../file.json')) when the JSON has more than 131072 characters
var loadPolicySetDefinitions = {
  All: [
    string(loadJsonContent('../policySetDefinitions/Deploy-RouteTable-Alerts.json'))
    string(loadJsonContent('../policySetDefinitions/Deploy-ServiceHealth-Alerts.json'))
  ]
  AzureCloud: []
  AzureChinaCloud: []
  AzureUSGovernment: []
}

// The following vars are used to manipulate the imported Policy Definitions to replace deployment location values
// Needs a double replace to handle updates in both templates for All clouds, and localized templates
var processPolicyDefinitionsAll = [for content in loadPolicyDefinitions.All: replace(replace(content, templateVars.defaultDeploymentLocation, deploymentLocation), templateVars.localizedDeploymentLocation, deploymentLocation)]
var processPolicyDefinitionsAzureCloud = [for content in loadPolicyDefinitions.AzureCloud: replace(replace(content, templateVars.defaultDeploymentLocation, deploymentLocation), templateVars.localizedDeploymentLocation, deploymentLocation)]
var processPolicyDefinitionsAzureChinaCloud = [for content in loadPolicyDefinitions.AzureChinaCloud: replace(replace(content, templateVars.defaultDeploymentLocation, deploymentLocation), templateVars.localizedDeploymentLocation, deploymentLocation)]
var processPolicyDefinitionsAzureUSGovernment = [for content in loadPolicyDefinitions.AzureUSGovernment: replace(replace(content, templateVars.defaultDeploymentLocation, deploymentLocation), templateVars.localizedDeploymentLocation, deploymentLocation)]

// The following vars are used to manipulate the imported Policy Set Definitions to replace Policy Definition scope values
var processPolicySetDefinitionsAll = [for content in loadPolicySetDefinitions.All: replace(content, templateVars.scope, scope)]
var processPolicySetDefinitionsAzureCloud = [for content in loadPolicySetDefinitions.AzureCloud: replace(content, templateVars.scope, scope)]
var processPolicySetDefinitionsAzureChinaCloud = [for content in loadPolicySetDefinitions.AzureChinaCloud: replace(content, templateVars.scope, scope)]
var processPolicySetDefinitionsAzureUSGovernment = [for content in loadPolicySetDefinitions.AzureUSGovernment: replace(content, templateVars.scope, scope)]

// The following vars are used to convert the imported Policy Definitions into objects from JSON
var policyDefinitionsAll = [for content in processPolicyDefinitionsAll: json(content)]
var policyDefinitionsAzureCloud = [for content in processPolicyDefinitionsAzureCloud: json(content)]
var policyDefinitionsAzureChinaCloud = [for content in processPolicyDefinitionsAzureChinaCloud: json(content)]
var policyDefinitionsAzureUSGovernment = [for content in processPolicyDefinitionsAzureUSGovernment: json(content)]

// The following vars are used to convert the imported Policy Set Definitions into objects from JSON
var policySetDefinitionsAll = [for content in processPolicySetDefinitionsAll: json(content)]
var policySetDefinitionsAzureCloud = [for content in processPolicySetDefinitionsAzureCloud: json(content)]
var policySetDefinitionsAzureChinaCloud = [for content in processPolicySetDefinitionsAzureChinaCloud: json(content)]
var policySetDefinitionsAzureUSGovernment = [for content in processPolicySetDefinitionsAzureUSGovernment: json(content)]

// The following var is used to compile the required Policy Definitions into a single object
var policyDefinitionsByCloudType = {
  All: policyDefinitionsAll
  AzureCloud: policyDefinitionsAzureCloud
  AzureChinaCloud: policyDefinitionsAzureChinaCloud
  AzureUSGovernment: policyDefinitionsAzureUSGovernment
}

// The following var is used to compile the required Policy Definitions into a single object
var policySetDefinitionsByCloudType = {
  All: policySetDefinitionsAll
  AzureCloud: policySetDefinitionsAzureCloud
  AzureChinaCloud: policySetDefinitionsAzureChinaCloud
  AzureUSGovernment: policySetDefinitionsAzureUSGovernment
}

// The following var is used to extract the Policy Definitions into a single list for deployment
// This will contain all policy definitions classified as available for All cloud environments, and those for the current cloud environment
var policyDefinitions = concat(policyDefinitionsByCloudType.All, policyDefinitionsByCloudType[cloudEnv])

// The following var is used to extract the Policy Set Definitions into a single list for deployment
// This will contain all policy set definitions classified as available for All cloud environments, and those for the current cloud environment
var policySetDefinitions = concat(policySetDefinitionsByCloudType.All, policySetDefinitionsByCloudType[cloudEnv])

// Create the Policy Definitions as needed for the target cloud environment
resource PolicyDefinitions 'Microsoft.Authorization/policyDefinitions@2025-01-01' = [for policy in policyDefinitions: {
  name: policy.name
  properties: {
    description: policy.properties.description
    displayName: policy.properties.displayName
    metadata: policy.properties.metadata
    mode: policy.properties.mode
    parameters: policy.properties.parameters
    policyType: policy.properties.policyType
    policyRule: policy.properties.policyRule
  }
}]

// Create the Policy Definitions as needed for the target cloud environment
// Depends on Policy Definitons to ensure they exist before creating dependent Policy Set Definitions (Initiatives)
resource PolicySetDefinitions 'Microsoft.Authorization/policySetDefinitions@2025-01-01' = [for policy in policySetDefinitions: {
  dependsOn: [
    PolicyDefinitions
  ]
  name: policy.name
  properties: {
    description: policy.properties.description
    displayName: policy.properties.displayName
    metadata: policy.properties.metadata
    parameters: policy.properties.parameters
    policyType: policy.properties.policyType
    policyDefinitions: policy.properties.policyDefinitions
    policyDefinitionGroups: policy.properties.policyDefinitionGroups
  }
}]

output policyDefinitionNames array = [for policy in policyDefinitions: policy.name]
output policySetDefinitionNames array = [for policy in policySetDefinitions: policy.name]
