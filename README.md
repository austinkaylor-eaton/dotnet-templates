## dotnet-templates

This repository is the source of truth for reusable `dotnet new` templates.

It is designed to support multiple template types over time, including:

- [item templates](https://learn.microsoft.com/en-us/dotnet/core/tutorials/cli-templates-create-item-template)
- [project templates](https://learn.microsoft.com/en-us/dotnet/core/tutorials/cli-templates-create-project-template)
- [solution templates](https://github.com/jasontaylordev/CleanArchitecture)

The repository separates template source, automation, artifacts, and
documentation so templates can be authored, tested, packaged, and published in
a predictable way.

## Repository Layout

| Path                                                   | Purpose                                                     |
|--------------------------------------------------------|-------------------------------------------------------------|
| [templates/](templates/)                               | Template source organized by template type                  |
| [automation/scripts/](automation/scripts/)             | Planned validation, packaging, install, and publish scripts |
| [automation/ci/](automation/ci/)                       | CI/CD pipeline definitions                                  |
| [artifacts/logs/](artifacts/logs/)                     | Validation and packaging logs                               |
| [artifacts/nuget_packages/](artifacts/nuget_packages/) | Generated `.nupkg` outputs                                  |
| [local_testing/](local_testing/)                       | Safe sandbox for generated template output                  |
| [docs/](docs/)                                         | Canonical repository guidance                               |

## Documentation Map

Use these documents as the primary entry points for working in the repository:

| Document                                                 | Purpose                                                         |
|----------------------------------------------------------|-----------------------------------------------------------------|
| [docs/architecture.md](docs/architecture.md)             | Repository structure, system design, and document ownership     |
| [docs/authoring-guide.md](docs/authoring-guide.md)       | How to create, configure, and test templates                    |
| [docs/naming-conventions.md](docs/naming-conventions.md) | Identity, `shortName`, folder, symbol, and package naming rules |
| [docs/release-process.md](docs/release-process.md)       | Versioning, packaging, publishing, and release workflow         |
| [docs/template-catalog.md](docs/template-catalog.md)     | Template inventory and lifecycle status tracking                |

## Expected Workflow

At a high level, template work in this repository follows this flow:

1. Author or update a template under [templates/](templates/)
2. Validate it locally using [local_testing/](local_testing/)
3. Update any relevant documentation
4. Package templates into [artifacts/nuget_packages/](artifacts/nuget_packages/)
5. Publish the template pack

The detailed instructions for each phase live in the docs set above.

## Local Testing

Use [local_testing/](local_testing/) for disposable test output while validating templates.

This folder is git-ignored so you can safely:

- generate throwaway projects
- restore and build generated output
- verify symbol replacement and file renaming
- test install and uninstall flows

## Current State

The repository structure and documentation are in place.

Automation scripts in [automation/scripts/](automation/scripts/) cover install, uninstall, validate,
pack, and publish. A shared helpers module lives at
[automation/scripts/shared.ps1](automation/scripts/shared.ps1).

## Reference Material

- [Custom templates for dotnet new](https://learn.microsoft.com/en-us/dotnet/core/tools/custom-templates)
- [How to create your own template for dotnet new](https://devblogs.microsoft.com/dotnet/how-to-create-your-own-templates-for-dotnet-new/)
- [Microsoft Learn Tutorial: Create an item template](https://learn.microsoft.com/en-us/dotnet/core/tutorials/cli-templates-create-item)
- [Microsoft Learn Tutorial: Create a project template](https://learn.microsoft.com/en-us/dotnet/core/tutorials/cli-templates-create-project)
- [Microsoft Learn Tutorial: Create a template pack](https://learn.microsoft.com/en-us/dotnet/core/tutorials/cli-templates-create-template-pack)
- [dotnet template samples repository](https://github.com/dotnet/templating/tree/main/dotnet-template-samples)
- [dotnet/templating wiki](https://github.com/dotnet/templating/wiki)
- [Template sample for Visual Studio integration](https://github.com/sayedihashimi/template-sample)
- [dotnet SDK item templates](https://github.com/dotnet/sdk/tree/main/template_feed/Microsoft.DotNet.Common.ItemTemplates/content)
- [dotnet SDK project templates](https://github.com/dotnet/sdk/tree/main/template_feed/Microsoft.DotNet.Common.ProjectTemplates.11.0/content)
