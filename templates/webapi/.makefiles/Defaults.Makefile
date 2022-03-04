#overrides from .cfg files

org                 ?=evergreen
org_region          ?=westus

project             ?=GeneratedProjectName
proj_region         ?=westus
proj_config         ?=Debug

git_username        ?=developer
git_email           ?=developer@$(org).org

tenant              ?=microsoft.onmicrosoft.com
sub                 ?="some illegal guid which will fail"
