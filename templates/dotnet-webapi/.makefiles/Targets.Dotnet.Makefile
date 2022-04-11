# Dotnet Commands

dotnet-publish :
	dotnet publish --no-build src/appl/appl.csproj -c $(proj_config) -o out/appl
	@echo Published DotNet Project

dotnet-test : dotnet-build
	dotnet test --no-build src/appl.sln -c $(proj_config)
	@echo Tested DotNet Solution

dotnet-build : dotnet-restore
	dotnet build --no-restore src/appl.sln -c $(proj_config)
	@echo Built DotNet Solution

dotnet-restore :
	dotnet restore src/appl.sln
	@echo Restored DotNet Solution

dotnet-clean:
	- rm -rf out/appl
	dotnet clean src/appl.sln
	@echo Cleaned DotNet Solution

dotnet-run :
	dotnet 'out/appl/appl.dll' -WorkingDirectory 'out/appl'
	@echo Launched DotNet Project

dotnet-all: dotnet-clean dotnet-test dotnet-publish dotnet-run
	@echo
