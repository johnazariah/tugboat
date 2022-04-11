# server build container
FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
ARG config=Release
COPY . "/code"
RUN dotnet restore "/code/src/appl.sln"
RUN dotnet build --no-restore "/code/src/appl.sln" -c ${config}
RUN dotnet test --no-build "/code/src/appl.sln" -c ${config}
RUN dotnet publish --no-build  "/code/src/appl/appl._PROJ_SUFFIX_" -c ${config} -o /app
COPY wwwroot /app/wwwroot

# container to run the server from
FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS release
WORKDIR /app
EXPOSE 8080 80

# The following ENV settings are the build-time defaults.
# You can pass different run-time values for any/all of them by using the '-e ENV_xxx=value' when invoking 'docker run'.

# This is the app-insights key used to log diagnostics.
# It is _strongly_ recommended that you supply a run-time value here when running in Azure.
ENV ENV_APPINSIGHTS_KEY           ""

COPY --from=build /app .

ENTRYPOINT ["dotnet", "appl.dll"]
