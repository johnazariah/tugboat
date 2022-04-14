using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Diagnostics.HealthChecks;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.FileProviders;
using Microsoft.OpenApi.Models;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Diagnostics.HealthChecks;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.ResponseCompression;
using System;
using System.Collections.Generic;
using System.IO;
using System.IO.Compression;
using System.Reflection;
using System.Text.Json.Serialization;

namespace GeneratedProjectName.WebApi
{
    /// <summary>
    /// Override methods in this class to take over how the web-api host is configured
    /// </summary>
    static class WebApiConfigurator
    {
        private static readonly OpenApiInfo apiInfo =
            new OpenApiInfo
            {
                Version = "v1",                                                                // revision this appropriately
                Title = "My .NET API",                                                         // title this application
                Description = "An application with a .NET backend and a WebAPI interface",     // describe this application
                TermsOfService = new Uri("http://127.0.0.1"),                                  // replace with <Your TOS Uri>
                Contact = new OpenApiContact()
                {
                    Name = "A Sagacious Developer",                                            // replace with <Your Name>
                    Email = "<Your Email>",                                                    // replace with <Your Email>
                    Url = new Uri("http://127.0.0.1"),                                         // replace with <Your Uri>
                },
                License = new OpenApiLicense
                {
                    Name = "A generous license",                                               // replace with <Your License Name>
                    Url = new Uri("http://127.0.01"),                                          // replace with <Your License Uri>
                },
            };

        private static bool useHttpsRedirection = false;

        private static Dictionary<HealthStatus, int> healthResultStatusCodes = new Dictionary<HealthStatus, int>()
        {
            [HealthStatus.Healthy  ] = StatusCodes.Status200OK,
            [HealthStatus.Degraded ] = StatusCodes.Status200OK,
            [HealthStatus.Unhealthy] = StatusCodes.Status503ServiceUnavailable
        };

        public static IHostBuilder ConfigureWebApi(this IHostBuilder hostBuilder) =>
            hostBuilder.ConfigureWebHostDefaults(webHostBuilder => 
                webHostBuilder.Configure((webHostBuilderContext, applicationBuilder) => {
                    var hostEnv = webHostBuilderContext.HostingEnvironment;
                    var swaggerUri = "v1/swagger.json";
                    var swaggerName = $"{apiInfo.Title} {apiInfo.Version}";

                    var builder = hostEnv.IsDevelopment() ? applicationBuilder.UseDeveloperExceptionPage() : applicationBuilder;
                    if (useHttpsRedirection) builder.UseHttpsRedirection();

                    builder
                        .UseFileServer(new FileServerOptions() {
                            FileProvider = new PhysicalFileProvider(Path.Combine(Directory.GetCurrentDirectory(), "wwwroot")),
                            RequestPath = "",
                        })
                        .UseSwagger(options => {
                            options.PreSerializeFilters.Add((swagger, httpReq) => {
                                if (httpReq.Headers.ContainsKey("X-Original-URL"))
                                {
                                    var originalUrlParts = httpReq.Headers["X-Original-URL"].ToString().Trim('/').Split("/");
                                    var applicationName = originalUrlParts[0];
                                    var deploymentName = originalUrlParts[1];
                                    var serverUrl = $"https://{httpReq.Headers["X-Forwarded-Host"]}/{applicationName}/{deploymentName}";
                                    swagger.Servers = new List<OpenApiServer> { new OpenApiServer { Url = serverUrl } };
                                }
                            });
                        })
                        .UseSwaggerUI(options => options.SwaggerEndpoint(swaggerUri, swaggerName))
                        .UseResponseCompression()
                        .UseRouting()
                        .UseAuthorization()
                        .UseEndpoints(endpoints => {
                            endpoints.MapControllers();
                            endpoints.MapHealthChecks(
                                "/health",
                                new HealthCheckOptions()
                                {
                                    AllowCachingResponses = false,
                                    ResultStatusCodes = healthResultStatusCodes
                                });
                        });
                    })
                    .UseSetting(WebHostDefaults.ApplicationKey, Assembly.GetEntryAssembly().GetName().Name))
                .ConfigureServices((hostBuilderContext, services) => {
                    services
                        .AddControllers()
                        .AddJsonOptions(options => options.JsonSerializerOptions.Converters.Add(new JsonStringEnumConverter()));

                    var xmlFile = $"{Assembly.GetEntryAssembly().GetName().Name}.xml";
                    var xmlPath = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, xmlFile);
                    services.AddSwaggerGen(options => {
                        options.SwaggerDoc(apiInfo.Version, apiInfo);
                        options.EnableAnnotations();
                        options.IncludeXmlComments(xmlPath);
                    });

                    services
                        .AddHealthChecks();

                    services
                        .AddResponseCompression()
                        .Configure((BrotliCompressionProviderOptions options) => { options.Level = CompressionLevel.Optimal; })
                        .Configure((GzipCompressionProviderOptions options) => { options.Level = CompressionLevel.Optimal; });
                });
    }

    /// <summary>
    ///
    /// This is the entry point to the silo.
    ///
    /// No changes should normally be needed here to start up a silo and a web-api front-end co-hosted in the same executable
    ///
    /// Provide the configuration of the silo to connect by any combination of (in order of override)
    ///    * The default configuration
    ///    * Providing a section in the "appSettings.json"/> file. (If at all possible, do not use this option.)
    ///    * Setting user secrets for managing secrets and connection strings in development
    ///    * Setting environment variables
    ///
    /// </summary>
    class Program
    {
        public static void Main(string[] args) =>
            CreateHostBuilder(args)
            .Build()
            .Run();

        public static IHostBuilder CreateHostBuilder(string[] args) =>
            Host
            .CreateDefaultBuilder(args)
            .ConfigureHostConfiguration(builder => builder.SetBasePath(Directory.GetCurrentDirectory()))
            .ConfigureWebApi();
    }
}
