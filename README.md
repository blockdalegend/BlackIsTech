#Azure Repeatable infrastructure demo

What it is
This is a demo showing one of the many paths to create infrastructure in well structured, repeatable manner. This project is built using Azure Bicep which is a DSL that is the sucessor of ARM (Azure Resource Manager) templates. https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/overview?tabs=bicep

How to use azure developer cli (different than Azure CLI) to build this project stamp:

1. Install Azure Developer CLI
2. Setup azd cli on your machine
3. go to the root of this project and type 'azd up' this will build the resources in Azure
4. type 'azd down' to delete the resources

How to use Azure pipelines

1. Create a release pipeline
2. Add the github repo as the source artifact
3. Add an ARM Template Deployment task add main.bicep and main.parameters.* file 
4. I added additional task to my release pipeline to get secrets from keyvault to seed database
