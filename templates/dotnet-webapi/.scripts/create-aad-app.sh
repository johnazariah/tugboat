#!/bin/bash

set -x

# REQUIRES
#   ${proj_aad_app_name}
#   ${sub}
#   ${github_user}
#   ${github_repo}

# Create AAD Application
@echo Creating AAD Application ${proj_aad_app_name}

app=$(az ad app create --display-name ${proj_aad_app_name} --output json)
app_oid=$(echo ${app} | jq -r ".objectId")
app_id=$(echo ${app} | jq -r ".appId")

# Create AAD Service Principal from AAD application
@echo Creating AAD Service Principal for ${proj_aad_app_name} with app_id ${app_id} and app_oid ${app_oid}

az ad sp create --id ${app_oid}
spn=$(az ad sp show --id ${app_id} --output json)
spn_oid=$(echo ${spn} | jq -r '.objectId')
spn_tenant=$(echo ${spn} | jq -r '.appOwnerTenantId')

# Set GitHub Secrets
@echo Setting GitHub Secrets
@echo AZURE_CLIENT_ID=${app_id}
gh secret set AZURE_CLIENT_ID       --body ${app_id}

@echo AZURE_TENANT_ID=${spn_tenant}
gh secret set AZURE_TENANT_ID       --body ${spn_tenant}

@echo AZURE_SUBSCRIPTION_ID=${sub}
gh secret set AZURE_SUBSCRIPTION_ID --body ${sub}

@echo PROJECT_SPN_OID=${spn_oid}
gh secret set PROJECT_SPN_OID       --body ${spn_oid}

# Creation Contributor Role assignment on the Subscription scope
@echo Creating Contributor Role assignment on the Subscription scope
az role assignment create\
    --assignee-object-id ${spn_oid}\
    --assignee-principal-type ServicePrincipal\
    --role "Owner"\
    --subscription ${sub}

# Provide OIDC federated credentials to Github
@echo Providing OIDC federated credentials to Github
az rest\
    --method POST\
    --uri "https://graph.microsoft.com/beta/applications/${app_oid}/federatedIdentityCredentials"\
    --headers "{\"Content-Type\":\"application/json\"}"\
    --body "{\
        \"name\":\"${proj_aad_app_name}\",\
        \"issuer\":\"https://token.actions.githubusercontent.com\",\
        \"subject\":\"repo:${github_user}/${github_repo}:ref:refs/heads/main\",\
        \"description\":\"Tugboat Integration\",\
        \"audiences\":[\"api://AzureADTokenExchange\"]\
    }"
