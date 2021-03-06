# Orleans UniversalSilo Quick Start

Here's how you can quickly get started with Orleans:

**1. Install the templates**

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
Orleans: Silo And Client                          orleans-silo-and-client      [C#], F#          Orleans/Contrib/Universal Silo/Silo And Client
Orleans: Standalone Client                        orleans-client               [C#], F#          Orleans/Contrib/Universal Silo/Standalone Client
Orleans: Standalone Silo                          orleans-silo                 [C#], F#          Orleans/Contrib/Universal Silo/Standalone Silo
Orleans: WebAPI Direct Client                     orleans-webapi               [C#], F#          Orleans/Contrib/Universal Silo/WebApi Direct Client
...
Solution File                                     sln                                            Solution
Protocol Buffer File                              proto                                          Web/gRPC

Examples:
    dotnet new mvc --auth Individual
    dotnet new react
    dotnet new --help

```

**2. Create an application with a name like `HelloTugboat`.**

```shell
$ dotnet new orleans-webapi --name HelloTugboat
The template "Orleans: WebAPI Direct Client" was created successfully.
```

This will create a fully-functional **C#** application in the `HelloTugboat` folder.

You can also choose to generate the project in **F#** by using the following command:

```shell
$ dotnet new orleans-webapi --name HelloTugboat --language F#
The template "Orleans: WebAPI Direct Client" was created successfully.
```


**3. Inspect the sample app**

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
drwxr-xr-x 1 johnaz 4096    0 Apr 30 09:51 grains/
drwxr-xr-x 1 johnaz 4096    0 Apr 30 09:50 appl-tests/
drwxr-xr-x 1 johnaz 4096    0 Apr 30 09:50 HelloTugboat/
-rw-r--r-- 1 johnaz 4096 2578 Apr 30 09:50 HelloTugboat.sln
-rw-r--r-- 1 johnaz 4096 2720 Apr 30 09:50 Makefile
-rw-r--r-- 1 johnaz 4096  223 Apr 30 09:50 tye.yaml
```

You will notice that it contains:
* A _console application_ project named `HelloTugboat` which is the **host application**
* A _class library_ project for **grains** where the grain interfaces and implementations are held
* A _class library_ project for **appl-controllers** where controllers are provided to expose grain methods over WebAPI
* A _xunit test_ project where grains can be tested in a test cluster, with examples of how to do **unit-** and **property-based-** testing
* A _solution file_ to coordinate the projects together
* A `Makefile` script to help you with the incantations to use whilst developing. You do not need to know `make` to use it
* A `Dockerfile` script to package your application into a [Docker](https://www.docker.com/) container. You do not need to have Docker installed if you do not want to use it
* `.gitignore` and `.dockerignore` files to help keep your working set clean
* A `.github` folder which contains a simple CI pipeline ready to build your library if you commit it to a [GitHub](https://github.com/) repository

[Experimental]
* A `tye.yaml` script to build, run and deploy your application via [Tye](https://github.com/dotnet/tye)
* A `docker-compose.yml` script to orchestrate a multi-node cluster on your local machine using [Docker Compose](https://docs.docker.com/compose/)

In future, there will be scripts to help you set up Azure CI pipelines & AKS clusters, deploy to Kubernetes, and so forth.

**4. Build, Test and Run the sample app.**

```shell
$ dotnet build HelloTugboat.sln
Microsoft (R) Build Engine version 16.5.0+d4cbfca49 for .NET Core
Copyright (C) Microsoft Corporation. All rights reserved.

  Restore completed in 1.61 sec for ...\HelloTugboat\appl-controllers\appl-controllers.csproj.
  Restore completed in 2.43 sec for ...\HelloTugboat\HelloTugboat\HelloTugboat.csproj.
  Restore completed in 2.45 sec for ...\HelloTugboat\appl-tests\appl-tests.csproj.
  Orleans.CodeGenerator - command-line = SourceToSource ...\HelloTugboat\grains\obj\Debug\netcoreapp3.1\grains.orleans.g.args.txt
  grains -> ...\HelloTugboat\grains\bin\Debug\netcoreapp3.1\grains.dll
  appl-controllers -> ...\HelloTugboat\appl-controllers\bin\Debug\netcoreapp3.1\appl-controllers.dll
  appl-tests -> ...\HelloTugboat\appl-tests\bin\Debug\netcoreapp3.1\appl-tests.dll
  HelloTugboat -> ...\HelloTugboat\HelloTugboat\bin\Debug\netcoreapp3.1\HelloTugboat.dll

Build succeeded.
    0 Warning(s)
    0 Error(s)

Time Elapsed 00:00:16.81
```

```shell
$ dotnet test HelloTugboat.sln
Test run for ...\HelloTugboat\appl-tests\bin\Debug\netcoreapp3.1\appl-tests.dll(.NETCoreApp,Version=v3.1)
Microsoft (R) Test Execution Command Line Tool Version 16.5.0
Copyright (c) Microsoft Corporation.  All rights reserved.

Starting test execution, please wait...

A total of 1 test files matched the specified pattern.

Test Run Successful.
Total tests: 4
     Passed: 4
 Total time: 16.8750 Seconds
```

Don't forget to _allow_ the firewall configuration in the next step.

```shell
$ dotnet run --project HelloTugboat/HelloTugboat.csproj
info: SiloConfigurator[0]
      Clustering mode from environment is: HostLocal
info: SiloConfigurator[0]
      Connection string from environment is:
info: SiloConfigurator[0]
      Blanking connection string because we are running with HostLocal clustering
info: SiloConfigurator[0]
      Finally configuring with clustering mode [HostLocal] with connection string []
info: SiloConfigurator[0]
      Persistence mode from environment is: InMemory
info: SiloConfigurator[0]
      Connection string from environment is:
info: SiloConfigurator[0]
      Finally configuring with persistence mode [InMemory] with connection string []
info: SiloConfigurator[0]
      Using the loopback address for [HostLocal]
info: SiloConfigurator[0]
      Development Clustering running on [127.0.0.1]:[11111]
info: SiloConfigurator[0]
      Configuring Endpoints and Silo Address for clustering mode HostLocal [127.0.0.1:(11111, 30000)]
info: SiloConfigurator[0]
      Configuring Persistence for InMemory []
...
...
-------------- Started silo S127.0.0.1:11111:325957930, ConsistentHashCode 26F31827 --------------
info: Microsoft.Hosting.Lifetime[0]
      Now listening on: http://localhost:5000
info: Microsoft.Hosting.Lifetime[0]
      Now listening on: https://localhost:5001
info: Orleans.Hosting.SiloHostedService[0]
      Starting Orleans Silo.
...
...
info: Orleans.Hosting.SiloHostedService[0]
      Orleans Silo started.
info: Microsoft.Hosting.Lifetime[0]
      Application started. Press Ctrl+C to shut down.
info: Microsoft.Hosting.Lifetime[0]
      Hosting environment: Production
info: Microsoft.Hosting.Lifetime[0]
      Content root path: ...\HelloTugboat\HelloTugboat
...
...
```

Now fire up a browser and point it to https://localhost:5001/swagger/index.html and you will be presented with the API for a simple calculator which knows how to add two numbers.

Try it out. You are exercising a grain-based calculator!

You now have is a fully functional Orleans-based application exposing its functionality via a WebApi front end.