# Tugboat

![CI](https://github.com/johnazariah/tugboat/workflows/CI/badge.svg)
 [![NuGet Package](https://img.shields.io/nuget/v/WestIsland.Tugboat.Templates.svg)](https://www.nuget.org/packages/WestIsland.Tugboat.Templates/)

This library attempts to provide a simple, boilerplate free foundation on which to get started with .NET, with pragmatic defaults and extension points, allowing a developer to focus on grain design and testing whilst providing opinionated guidance around the real-world concerns of configuration, packaging, service presentation and deployment.

Using this library is best done by interacting with the working bits published to Nuget. This will allow you to focus on building .NET applications in your choice of idiomatic C# or F# with the least ceremony.

_Specifically, you don't need to clone this repo - or be familiar with the languages and tools used in this repo - to get started with .NET!_

_Of course, you are welcome to do so, and code contributions and ideas are always welcome!_

Here's how you can quickly get started with .NET:

## 1. Install the templates

```shell
dotnet new --install WestIsland.Tugboat.Templates
```

## 2. Create an application with a name like `HelloTugboat`

```shell
$ dotnet new dotnet-webapi --name HelloTugboat
The template "Tugboat: WebAPI" was created successfully.
```

This will create a fully-functional **C#** application in the `HelloTugboat` folder.

You can also choose to generate the project in **F#** by using the following command:

```shell
$ dotnet new dotnet-webapi --name HelloTugboat --language F#
The template "Tugboat: WebAPI" was created successfully.
```

## 3. Inspect the generated application

```shell
$ cd HelloTugboat
$ ls -al
total 47
drwxr-xr-x 1 johnaz 4096    0 Apr 11 06:09 ./
drwxr-xr-x 1 johnaz 4096    0 Apr 11 05:43 ../
drwxr-xr-x 1 johnaz 4096    0 Apr 11 05:43 .azure/
-rw-r--r-- 1 johnaz 4096  106 Apr 11 05:43 .dockerignore
drwxr-xr-x 1 johnaz 4096    0 Apr 11 05:43 .github/
-rw-r--r-- 1 johnaz 4096 3312 Apr 11 05:43 .gitignore
drwxr-xr-x 1 johnaz 4096    0 Apr 11 05:43 .makefiles/
drwxr-xr-x 1 johnaz 4096    0 Apr 11 05:43 .scripts/
-rw-r--r-- 1 johnaz 4096  476 Apr 11 05:43 dev.sh
-rw-r--r-- 1 johnaz 4096  921 Apr 11 05:43 Dockerfile
-rw-r--r-- 1 johnaz 4096  477 Apr 11 05:43 Makefile
drwxr-xr-x 1 johnaz 4096    0 Apr 11 05:43 src/
drwxr-xr-x 1 johnaz 4096    0 Apr 11 05:43 wwwroot/
```

You will notice that it contains:

* A `src` folder with:
  * A _console application_ project named **appl** which is the **host application**
  * A _class library_ project named **appl-controllers** where controllers are provided to expose methods over WebAPI
  * A _class library_ project named **appl-logic** where the business logic can be placed
  * A _xunit test_ project where grains can be tested in a test cluster, with examples of how to do **unit-** and **property-based-** testing
  * A _solution file_ to coordinate the projects together
* A `Makefile` script to help you with the incantations to use whilst developing. You do not need to know `make` to use it
* A `Dockerfile` script to package your application into a [Docker](https://www.docker.com/) container. You do not need to have Docker installed if you do not want to use it
* `.gitignore` and `.dockerignore` files to help keep your working set clean
* A `.github` folder which contains pipelines ready to build your library when you commit it to a [GitHub](https://github.com/) repository
* An `.azure` folder which contains scripts used by the github pipelines to set up all the requisite Azure resources in your own Azure subscription
* A `dev.sh` shell script which fires up a completely self-contained development environment with all the tools and libraries pre-installed.

## 4. Fire up the Dev Environment

In the project folder of the newly created project, run

```shell
./dev.sh
```

This will download a docker image and fire it up, and give you an interactive prompt where you have access to all the tools you will need to interact with `make`; Azure through the `az` CLI; and Github through the `gh` CLI. The `Makefile` provided also has a lot of pre-packaged functionality.

Inside your dev environment, type `make hello`, and follow the prompts. You can also read the `README.md` in your generated folder for further instructions.

## 5. Make it your own

Take your time and look over the various projects in the solution. Add your own code, tests and controllers. Rebuilding and running the application will extend it and make it your own!

Play with various packaging and deployment options: Package and run your application from a docker container, or deploy it to Kubernetes and scale it out there.

## 6. Learn more

The application generated here is a sophisticated starting point.

It has built-in support for configuration, extension, tests, CI/CD, packaging and deployment.

Follow the [documentation](https://johnazariah.github.io/tugboat/) to learn more.
