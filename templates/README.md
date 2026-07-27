## Eaton.AustinKaylor.Templates

`Eaton.AustinKaylor.Templates` is a `dotnet new` template pack for reusable
C# scaffolding patterns.

## Quick Start

Install the package:

```powershell
dotnet new install Eaton.AustinKaylor.Templates
```

Update to the latest version:

```powershell
dotnet new update Eaton.AustinKaylor.Templates
```

Uninstall the package:

```powershell
dotnet new uninstall Eaton.AustinKaylor.Templates
```

List installed templates:

```powershell
dotnet new list
```

## Use the Builder Item Template

Create a new builder-pattern item using the included template:

```powershell
dotnet new eaton-ajk-patterns-builder --name Order --namespace My.App.Models
```

Example with custom symbol values:

```powershell
dotnet new eaton-ajk-patterns-builder --name Customer --namespace My.App.Models --class-name Customer --builder-prefix Set
```

## Current Templates in This Package

| Short Name                    | Type   | Description                                |
| ----------------------------- | ------ | ------------------------------------------ |
| `eaton-ajk-patterns-builder`  | `item` | Creates a C# builder pattern example item. |

### Template Parameters

| Parameter          | Short  | Description                              | Default                                          |
| ------------------ | ------ | ---------------------------------------- | ------------------------------------------------ |
| `--namespace`      | `--ns` | Namespace for the generated item.        | `Eaton.AustinKaylor.Templates.Item.Patterns.Builder` |
| `--class-name`     | `-c`   | Class name and output file name.         | `Entity`                                         |
| `--builder-prefix` | `--bp` | Builder method prefix (`With` or `Set`). | `With`                                           |

## Learn More

- Repository overview: [`README.md`](../README.md)
- Template catalog: [`docs/template-catalog.md`](../docs/template-catalog.md)
- Template authoring guide: [`docs/authoring-guide.md`](../docs/authoring-guide.md)
- Release and packaging workflow: [`docs/release-process.md`](../docs/release-process.md)
