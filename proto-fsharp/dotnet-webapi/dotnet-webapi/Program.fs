﻿namespace GeneratedProjectName.WebApi

open Microsoft.Extensions.Configuration
open Microsoft.Extensions.DependencyInjection
open Microsoft.Extensions.Diagnostics.HealthChecks
open Microsoft.Extensions.Hosting
open Microsoft.Extensions.Logging
open Microsoft.Extensions.FileProviders
open Microsoft.OpenApi.Models
open Microsoft.AspNetCore.Builder
open Microsoft.AspNetCore.Diagnostics.HealthChecks
open Microsoft.AspNetCore.Hosting
open Microsoft.AspNetCore.Http
open Microsoft.AspNetCore.ResponseCompression
open System
open System.Collections.Generic
open System.IO
open System.IO.Compression
open System.Reflection
open System.Text.Json.Serialization

[<AutoOpen>]
module WebApiConfigurator =
    let private healthResultStatusCodes =
        [
            (HealthStatus.Healthy,   StatusCodes.Status200OK);
            (HealthStatus.Degraded,  StatusCodes.Status200OK);
            (HealthStatus.Unhealthy, StatusCodes.Status503ServiceUnavailable)
        ]
        |> dict

    let private Version = "v1"                                                                    // revision this appropriately
    let private Title = "My .NET API"                                                             // title this application
    let private Description = "An application with a .NET backend and a WebAPI interface"         // describe this application
    let private TermsOfService = new Uri("http://127.0.0.1")                                      // replace with <Your TOS Uri>
    let private Contact_Name = "A Sagacious Developer"                                            // replace with <Your Name>
    let private Contact_Email = "<Your Email>"                                                    // replace with <Your Email>
    let private Contact_Url = new Uri("http://127.0.0.1")                                         // replace with <Your Uri>
    let private License_Name = "A generous license"                                               // replace with <Your License Name>
    let private License_Url = new Uri("http://127.0.01")                                          // replace with <Your License Uri>
    let private Contact = new OpenApiContact(Name = Contact_Name, Email = Contact_Email, Url = Contact_Url)
    let private License = new OpenApiLicense(Name = License_Name, Url = License_Url)

    let apiInfo =
        OpenApiInfo(
            Version = Version,
            Title = Title,
            Description = Description,
            TermsOfService = TermsOfService,
            Contact = Contact,
            License = License)

    let useHttpsRedirection = false

    type IHostBuilder with
        /// Configure the WebApi Host
        member this.ConfigureWebApi() : IHostBuilder =
            let configureApp (webHostBuilderContext : WebHostBuilderContext) (applicationBuilder : IApplicationBuilder) =
                let hostEnv = webHostBuilderContext.HostingEnvironment
                let swaggerUri  = "./v1/swagger.json"
                let swaggerName = sprintf "%s %s" apiInfo.Title apiInfo.Version

                let builder =
                    match hostEnv.IsDevelopment() with
                    | false -> applicationBuilder
                    | true  -> applicationBuilder.UseDeveloperExceptionPage()

                if useHttpsRedirection then
                    ignore <| builder.UseHttpsRedirection()

                builder                    
                    .UseFileServer(new FileServerOptions(FileProvider =  new PhysicalFileProvider(Path.Combine(Directory.GetCurrentDirectory(), "wwwroot")), RequestPath = ""))
                    .UseSwagger()
                    .UseSwaggerUI(fun options -> options.SwaggerEndpoint(swaggerUri, swaggerName))
                    .UseResponseCompression()
                    .UseRouting()
                    .UseAuthorization()
                    .UseEndpoints(fun endpoints ->
                        endpoints.MapControllers()
                        |> ignore

                        endpoints.MapHealthChecks(
                            "/health",
                            new HealthCheckOptions(
                                AllowCachingResponses = false,
                                ResultStatusCodes = healthResultStatusCodes
                            ))
                        |> ignore)
                |> ignore

            let configureServices (hostBuilderContext : HostBuilderContext) (services : IServiceCollection) =
                services
                    .AddControllers()
                    .AddJsonOptions(fun options -> options.JsonSerializerOptions.Converters.Add(new JsonStringEnumConverter()))
                |> ignore

                let xmlFile = sprintf "%s.xml" (Assembly.GetEntryAssembly().GetName().Name)
                let xmlPath = Path.Combine (AppDomain.CurrentDomain.BaseDirectory, xmlFile)
                services.AddSwaggerGen(fun options ->
                    options.SwaggerDoc (apiInfo.Version, apiInfo)
                    options.EnableAnnotations()
                    options.IncludeXmlComments(xmlPath))
                |> ignore

                services
                    .AddHealthChecks()
                |> ignore

                services
                    .AddResponseCompression()
                    .Configure(fun (options : BrotliCompressionProviderOptions) ->
                        options.Level <- CompressionLevel.Optimal)
                    .Configure(fun (options : GzipCompressionProviderOptions) ->
                        options.Level <- CompressionLevel.Optimal)
                |> ignore

            this
                .ConfigureWebHostDefaults(fun webHostBuilder ->
                    webHostBuilder
                        .Configure(configureApp)
                        .UseSetting(WebHostDefaults.ApplicationKey, Assembly.GetEntryAssembly().GetName().Name)
                        |> ignore)
                .ConfigureServices(configureServices)

module Program =
    /// This is the entry point to the silo.
    [<EntryPoint>]
    let Main args =
        (Host.CreateDefaultBuilder args)
            .ConfigureHostConfiguration(fun builder -> ignore <| builder.SetBasePath(Directory.GetCurrentDirectory()))
            .ConfigureWebApi()
            .Build()
            .Run()
        0
