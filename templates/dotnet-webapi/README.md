# GeneratedProjectName

![Build and Test](https://github.com/_GITHUB_USER_/_ORG_-_PROJECT_/actions/workflows/ci.yml/badge.svg)
![Deploy to AKS](https://github.com/_GITHUB_USER_/_ORG_-_PROJECT_/actions/workflows/deploy-to-aks.yml/badge.svg)

## Tugboat Template

This application was generated from the `_TEMPLATE_` provided by WestIsland.Tugboat.Templates, by running:

```shell
dotnet new --install WestIsland.Tugboat.Templates
dotnet new _TEMPLATE_ --name GeneratedProjectName
```

## Overview

This is a .NET Web API application with support for deployment to AKS, and contains:

* A set of projects to encapsulate
  1. WebAPI Controllers
  1. Business Logic
  1. Tests
  1. Host Application
* A Swagger Endpoint for the API
* A static landing page for the application
* A Dockerfile to containerize the application
* Local development and testing support
* CI/CD, Automated Infrastructure Setup and Zero-Touch-Deployment support

The project includes a **self-contained Docker-based development environment** with all the required tools and libraries pre-installed. This means that all you need on your machine are the following tools:

1. Windows Terminal
1. Git with Git Bash
1. Visual Studio Code
1. Docker
1. .NET Framework

## Get Started

If you are reading this, the project has already been created. You should have a code-editor opened to the project directory.

### Prepare The Project Defaults

Navigate to the `.makefiles/Defaults.Makefile` and ensure _all_ the variables there have meaningful and correct results.

### Start the Development Environment

From a shell opened to the project directory, run:

```shell
./dev.sh
```

This will give you an environment you can run tools like `make`, the `az` and `gh` CLI tools.

### First Run

Running `make hello` will walk you through the process of setting up your environment for first and subsequent runs.

The first time you set up this repo, you will run `make tugboat-init`, which will:

1. Set up a local git repo and commit the current state of the code
1. Login to Azure
1. Login to Github
1. Create a Github Repo and push your code to it
1. Wire up permissions to establish secure connections between Github and Azure, so that Github Actions can set up your Azure Infrastructure and deploy your applications through a secure supply-chain

### CI Pipeline

The github repo you just pushed has several GitHub Workflows included. As soon as you push code or open a PR to the `main` branch, the CI pipeline will compile and test the .NET solution, and build a docker image of the tested application.

The CI pipeline acts as a baseline check of the health of the code you have committed.

As soon as you do the `First Run` steps above, the CI pipeline should have successfully completed.

### Set Up Azure Infrastructure

The project includes scripts to build and configure the Azure resources required to deploy your project to AKS.

The `Azure Infrastructure Setup` pipeline can be manually triggered. This is a good time to do that, and it will set up the Azure Infrastructure required to run your application, with HTTPS termination and a secure private network.

It should take about 15 minutes to complete depending on which region you have deployed to.

You should have to do this just once.

### Deploy your Application

When the `Azure Infrastructure Setup` pipeline completes, you can manually trigger the `Build and Deploy to AKS` pipeline.

This pipeline is going to be run every time you want to deploy your changes to AKS. You can keep it so you manually trigger the deployment (by default) or configure the pipeline to run on every commit or PR, or perhaps on a special tag.

The latest commit to master will be built, packaged, and deployed to AKS.

### Connect to the AKS cluster from your Dev Environment

#### First Time

When you have set up the infrastructure and deployed your application for the first time, you can run `make tugboat-connect-aks` in your dev environment. This will get the credentials from the AKS cluster and allow you to run `kubectl` against it.

#### Subsequent Times

If you already have set up and deployed your application previously and are returning to develop your application further, prepare your environment (as suggested by `make hello`) by running `make tugboat-prepare-env`. This will log you into Azure, Github and connect you to your cluster.

### Get the status of your application

Running `make status` in a properly prepared dev environment (see above) will display information from `kubectl`, showing you all the running pods, services, deployments and ingresses.

Since the default behaviour of this application is to create a new kubernetes deployment each time, disambiguated by the git hash of the commit that triggered it, the URL to the latest version will change after each deployment. Running `make status` or `make url` will display the URL of the most recent deployment.

## Next Steps

Once you have the default application up and visible in Azure, you can go ahead and make changes and improvements to your application.

Your development cycle will look like:

1. When you start up a new terminal, you can start up a fresh development environment if you wish by running `./dev.sh` in the project directory.
1. Prepare your environment by running `make tugboat-prepare-env`, which will log you in and connect you to the cluster.
1. You can use Visual Studio Code or Visual Studio to develop your application in the `src` directory
1. Run `make dotnet-all` to build and test your application from the command-line.
1. Run `make docker-build` and `make docker-run` to build and test your containerized application. You can do this from inside the development environment even though that is _also_ a Docker container.
1. When you are satisfied that the application serves the right endpoints and the correct results, you can `git commit` and `git push` the changes to GitHub.
1. Trigger the `Build and Deploy to AKS` pipeline to build, package and deploy your changes to AKS.
1. Run `make status` when the deployment is done and ensure that the pods are running. You will also be given the url to access the latest deployment.

## Contact Us

If you have suggestions for improvements, pull-requests and bug-reports, please contact us. We are:

* [John Azariah](https://github.com/johnazariah) 
* [Christian Smith](https://github.com/smith1511)