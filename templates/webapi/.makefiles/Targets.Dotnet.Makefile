# Dotnet Commands

dotnet-publish :
	dotnet publish --no-build $(project)/$(project).csproj -c $(proj_config) -o out/$(project)
	@echo Built DotNet projects

dotnet-test : dotnet-build
	dotnet test --no-build $(project).sln -c $(proj_config)
	@echo Built DotNet projects

dotnet-build : dotnet-restore
	dotnet build --no-restore $(project).sln -c $(proj_config)
	@echo Built DotNet projects

dotnet-restore :
	dotnet restore $(project).sln
	@echo Built DotNet projects

dotnet-clean:
	- rm -rf out/$(project)
	dotnet clean $(project).sln

dotnet-run :
	dotnet 'out/$(project)/$(project).dll' -WorkingDirectory 'out/$(project)'
	@echo Launched DotNet projects

dotnet-all: dotnet-clean dotnet-test dotnet-test dotnet-publish dotnet-run
	@echo
