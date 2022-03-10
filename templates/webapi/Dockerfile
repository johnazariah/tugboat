# server build container
FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
ARG config=Release
COPY . "/src"
RUN dotnet restore "/src/GeneratedProjectName/GeneratedProjectName._PROJ_SUFFIX_"
RUN dotnet build --no-restore "/src/GeneratedProjectName/GeneratedProjectName._PROJ_SUFFIX_" -c ${config}
RUN dotnet test --no-build "/src/GeneratedProjectName/GeneratedProjectName._PROJ_SUFFIX_" -c ${config}
RUN dotnet publish --no-build  "/src/GeneratedProjectName/GeneratedProjectName._PROJ_SUFFIX_" -c ${config} -o /app
COPY wwwroot /app/wwwroot

# container to run the server from
FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS release
WORKDIR /app
EXPOSE 8080 80

# The following ENV settings are the build-time defaults.
# You can pass different run-time values for any/all of them by using the '-e ENV_xxx=value' when invoking 'docker run'.

# This is the app-insights key used to log diagnostics.
# It is _strongly_ recommended that you supply a run-time value here when running in Azure.
ENV APPLICATIONINSIGHTS_CONNECTION_STRING           ""

COPY --from=build /app .

ENTRYPOINT ["dotnet", "GeneratedProjectName.dll"]
