# Tugboat

![CI](https://github.com/johnazariah/tugboat/workflows/CI/badge.svg)
 [![NuGet Package](https://img.shields.io/nuget/v/Tugboat.Templates.svg)](https://www.nuget.org/packages/Tugboat.Templates/)

This library attempts to provide a simple, boilerplate free foundation on which to get started with .NET, with pragmatic defaults and extension points, allowing a developer to focus on grain design and testing whilst providing opinionated guidance around the real-world concerns of configuration, packaging, service presentation and deployment.

Using this library is best done by interacting with the working bits published to Nuget. This will allow you to focus on building .NET applications in your choice of idiomatic C# or F# with the least ceremony.

_Specifically, you don't need to clone this repo - or be familiar with the languages and tools used in this repo - to get started with .NET!_

_Of course, you are welcome to do so, and code contributions and ideas are always welcome!_

Here's how you can quickly get started with .NET:

## 1. Install the templates

```shell
dotnet new --install WestIsland.Tugboat.Templates
```

This should print out the list of installed templates, including the following:

```shell
$ dotnet new --install WestIsland.Tugboat.Templates
  Restore completed in 660.35 ms.

...

Templates                                         Short Name                   Language          Tags
----------------------------------------------------------------------------------------------------------------------------------------------------
Console Application                               console                      [C#], F#, VB      Common/Console
Class library                                     classlib                     [C#], F#, VB      Common/Library
...
Tugboat: WebAPI                                   tugboat-webapi               [C#], F#          Tugboat/WebApi Direct Client
...

Examples:
    dotnet new mvc --auth Individual
    dotnet new react
    dotnet new --help

```

## 2. Create an application with a name like `HelloTugboat`

```shell
$ dotnet new tugboat-webapi --name HelloTugboat
The template "Tugboat: WebAPI" was created successfully.
```

This will create a fully-functional **C#** application in the `HelloTugboat` folder.

You can also choose to generate the project in **F#** by using the following command:

```shell
$ dotnet new tugboat-webapi --name HelloTugboat --language F#
The template "Tugboat: WebAPI" was created successfully.
```

## 3. Inspect the generated application

```shell
$ cd HelloTugboat
$ ls -al
total 31
drwxr-xr-x 1 johnaz 4096    0 Apr 30 09:50 ./
drwxr-xr-x 1 johnaz 4096    0 Apr 30 09:50 ../
-rw-r--r-- 1 johnaz 4096  124 Apr 30 09:50 .dockerignore
drwxr-xr-x 1 johnaz 4096    0 Apr 30 09:50 .github/
-rw-r--r-- 1 johnaz 4096 3266 Apr 30 09:50 .gitignore
-rw-r--r-- 1 johnaz 4096  206 Apr 30 09:50 docker-compose.yml
-rw-r--r-- 1 johnaz 4096 2119 Apr 30 09:50 Dockerfile
drwxr-xr-x 1 johnaz 4096    0 Apr 30 09:51 appl-controllers/
drwxr-xr-x 1 johnaz 4096    0 Apr 30 09:50 appl-tests/
drwxr-xr-x 1 johnaz 4096    0 Apr 30 09:50 HelloTugboat/
-rw-r--r-- 1 johnaz 4096 2578 Apr 30 09:50 HelloTugboat.sln
-rw-r--r-- 1 johnaz 4096 2720 Apr 30 09:50 Makefile
```

You will notice that it contains:

* A _console application_ project named `HelloTugboat` which is the **host application**
* A _class library_ project named **appl-controllers** where controllers are provided to expose methods over WebAPI
* A _xunit test_ project where grains can be tested in a test cluster, with examples of how to do **unit-** and **property-based-** testing
* A _solution file_ to coordinate the projects together
* A `Makefile` script to help you with the incantations to use whilst developing. You do not need to know `make` to use it
* A `Dockerfile` script to package your application into a [Docker](https://www.docker.com/) container. You do not need to have Docker installed if you do not want to use it
* `.gitignore` and `.dockerignore` files to help keep your working set clean
* A `.github` folder which contains a simple CI pipeline ready to build your library if you commit it to a [GitHub](https://github.com/) repository

In future, there will be scripts to help you set up Azure CI pipelines & AKS clusters, deploy to Kubernetes, and so forth.

## 4. Build, Test and Run the generated application

```shell
$ dotnet build HelloTugboat.sln
...

```

```shell
$ dotnet test HelloTugboat.sln
...

```

Now fire up a browser and point it to https://localhost:5001/swagger/index.html and you will be presented with the API for a simple calculator which knows how to add two numbers.

Try it out. You are exercising a web-based calculator!

You now have is a fully functional .NET application exposing its functionality via a WebApi front end.

## 5. Make it your own

Take your time and look over the various projects in the solution. Add your own code, tests and controllers. Rebuilding and running the application will extend it and make it your own!

Play with various packaging and deployment options: Package and run your application from a docker container, or deploy it to Kubernetes and scale it out there.

## 6. Learn more

The application generated here is a sophisticated starting point.

It has built-in support for configuration, extension, tests, CI/CD, packaging and deployment.

Follow the [documentation](https://johnazariah.github.io/tugboat/) to learn more.
