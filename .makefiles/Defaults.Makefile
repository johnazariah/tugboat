#overrides from .cfg files
org                 ?=$(shell echo GeneratedProjectName | cut -c1-15 | tr A-Z a-z)org
org_region          ?=westus

project             ?=GeneratedProjectName
proj_region         ?=westus
proj_config         ?=Debug

git_username        ?=Primary Developer
git_email           ?=primary@$(org).org

tenant              ?=microsoft.onmicrosoft.com
sub                 ?="some illegal guid which will fail"
