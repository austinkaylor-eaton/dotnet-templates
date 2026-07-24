## Template Naming and Identity Conventions

Use these conventions to keep template names predictable for authors,
discoverable for users, and consistent in `dotnet new list` output.

## Goals

- Keep every template easy to find from the CLI
- Make folder names, identities, and package metadata line up
- Avoid collisions between item, project, and solution templates
- Make future automation simpler by using repeatable patterns

## Core Naming Rules

| Concept | Convention | Example |
| ------- | ---------- | ------- |
| Template identity | `Eaton.Templates.<Type>.<Name>.CSharp` | `Eaton.Templates.Project.WebApi.CSharp` |
| Template short name | `eaton-<name>` | `eaton-webapi` |
| Template group identity | `Eaton.Templates.<Type>.<Family>.CSharp` | `Eaton.Templates.Project.WebApi.CSharp` |
| NuGet package ID | `Eaton.AustinKaylor.Templates` | `Eaton.AustinKaylor.Templates` |
| Template folder name | kebab-case | `eaton-webapi` |
| Source project name | PascalCase | `Eaton.WebApi` |
| Symbols / parameters | PascalCase keys, kebab-case CLI names | `ClassName` and `--class-name` |

## Template Identity

The `identity` field in `template.json` must be globally unique.

Pattern:

```text
Eaton.Templates.<Type>.<Name>.CSharp
```

### Identity Segments

| Segment | Meaning | Allowed Values / Style |
| ------- | ------- | ---------------------- |
| `Eaton` | Organization / brand prefix | Fixed |
| `Templates` | Marks the artifact as a template | Fixed |
| `<Type>` | Template category | `Item`, `Project`, `Solution` |
| `<Name>` | Template purpose or family | PascalCase, concise, descriptive |
| `CSharp` | Language | Fixed for C# templates |

### Good Examples

- `Eaton.Templates.Item.Class.CSharp`
- `Eaton.Templates.Item.Interface.CSharp`
- `Eaton.Templates.Project.WebApi.CSharp`
- `Eaton.Templates.Project.Console.CSharp`
- `Eaton.Templates.Solution.Monolith.CSharp`

### Avoid

- `class-template`
- `Eaton.WebApi`
- `Eaton.Template.Project.WebApi`
- `Eaton.Templates.project.webapi.csharp`

Use PascalCase inside the identity so the meaning is obvious and consistent.

## Template Short Names

The `shortName` is what users type with `dotnet new`.

Pattern:

```text
eaton-<name>
```

### Rules

- Use lowercase letters only
- Separate words with hyphens
- Keep it short and memorable
- Prefer the template purpose over the technical implementation
- Do not include the type unless it improves clarity

### Good Examples

- `eaton-class`
- `eaton-interface`
- `eaton-webapi`
- `eaton-console`
- `eaton-monolith`

### Avoid

- `EatonClass`
- `eaton_webapi`
- `webapi-template`
- `template-eaton-class`
- `eaton-project-webapi` unless needed to avoid a collision

### Guidance for Ambiguity

If two templates would otherwise have the same short name, add the smallest
useful qualifier.

Examples:

- `eaton-webapi`
- `eaton-webapi-auth`
- `eaton-webapi-minimal`

## Group Identity

Use `groupIdentity` to connect variants of the same template family.

This is useful when you have multiple choices for the same conceptual template,
such as:

- authenticated vs unauthenticated
- minimal API vs controller API
- net8.0 vs net9.0 baselines

Pattern:

```text
Eaton.Templates.<Type>.<Family>.CSharp
```

Examples:

- `Eaton.Templates.Project.WebApi.CSharp`
- `Eaton.Templates.Project.Console.CSharp`

Use the same `groupIdentity` for related variants, and different `identity`
values for each specific template.

## Template Display Name

The `name` field is what users see in template listings.

Pattern:

```text
Eaton <Template Purpose>
```

Examples:

- `Eaton Class`
- `Eaton Interface`
- `Eaton Web API`
- `Eaton Console App`
- `Eaton Monolith Solution`

### Rules

- Use title case
- Keep it human-readable
- Avoid repeating `C#` unless the repo contains multiple languages
- Avoid implementation details that belong in `description`

## Template Description

The `description` field should explain what gets created.

### Rules

- Start with an action verb such as `Creates` or `Generates`
- Keep it one sentence when possible
- Mention the most important differentiator

### Good Examples

- `Creates a new C# class with XML documentation comments.`
- `Creates a minimal ASP.NET Core Web API with health checks.`
- `Creates a multi-project monolith solution with domain layers.`

### Avoid

- `Class template`
- `A template for stuff`
- `This is the best template ever for creating projects`

## Folder Naming

Template folders should match the short name whenever practical.

Patterns:

- `templates/item/eaton-class/`
- `templates/item/eaton-interface/`
- `templates/project/eaton-webapi/`
- `templates/project/eaton-console/`
- `templates/solution/eaton-monolith/`

### Rules

- Use kebab-case
- Keep folder names aligned with `shortName`
- Avoid spaces and underscores
- Avoid version numbers in folder names

### Good Examples

- `eaton-class`
- `eaton-webapi`
- `eaton-monolith`

### Avoid

- `EatonClass`
- `eaton_webapi`
- `web api`
- `eaton-webapi-v2`

If a major redesign is needed, create a new template rather than hiding version
semantics in the folder name.

## Source File and Project Naming

Inside the template source, use normal .NET naming conventions.

### C# Files

- Use PascalCase for file names that map to types
- Match the primary type name when possible

Examples:

- `Class.cs`
- `UserService.cs`
- `HealthController.cs`

### Projects

- Use PascalCase for project names
- Prefer organization-prefixed names for reusable starters
- Keep generated defaults sensible

Examples:

- `Eaton.WebApi.csproj`
- `Eaton.Console.csproj`
- `Eaton.Monolith.Api.csproj`

### Solutions

- Use PascalCase and dots for logical boundaries

Examples:

- `Eaton.Monolith.sln`
- `Eaton.WebApi.Starter.sln`

## Symbol Naming

Symbols defined in `template.json` must be easy to understand.

### Symbol Key Rules

- Use PascalCase for symbol keys
- Use descriptive names
- Avoid abbreviations unless they are industry standard
- Name booleans as a feature toggle or state

### Good Examples

- `ClassName`
- `Namespace`
- `Description`
- `TargetFramework`
- `EnableAuth`
- `IncludeTests`

### Avoid

- `cn`
- `ns`
- `tfm1`
- `flag`

### CLI Parameter Rules

When exposed through `dotnetcli.host.json`:

- Use kebab-case for `longName`
- Use short, memorable aliases for `shortName`
- Keep aliases unambiguous

Examples:

| Symbol ID | longName | shortName |
| --------- | -------- | --------- |
| `ClassName` | `class-name` | `c` |
| `Namespace` | `namespace` | `ns` |
| `TargetFramework` | `target-framework` | `tfm` |
| `EnableAuth` | `enable-auth` | `auth` |

## Tags and Classifications

Use tags consistently so the CLI can categorize templates correctly.

Required tags:

```json
{
  "tags": {
    "language": "C#",
    "type": "item"
  }
}
```

### Allowed `type` Values

- `item`
- `project`
- `solution`

### Classification Guidance

Use `classifications` to help users browse templates.

Examples:

- `Common`
- `Web`
- `API`
- `Architecture`
- `Clean Architecture`
- `Minimal API`

Keep classifications short and user-facing.

## NuGet Package Naming

The package that distributes templates should use a stable, organization-owned
name.

Current package ID:

```text
Eaton.AustinKaylor.Templates
```

### Rules

- Keep the package ID stable over time
- Use PascalCase with dots as separators
- Do not encode template type in the package ID unless you intentionally split
  distribution into multiple packages

### Future Split Packages

If the repo ever publishes separate packs, use one of these patterns:

- `Eaton.AustinKaylor.Templates.Items`
- `Eaton.AustinKaylor.Templates.Projects`
- `Eaton.AustinKaylor.Templates.Solutions`

Do not introduce split package names unless release cadence or ownership makes
it necessary.

## Recommended Mapping by Template Type

| Template Type | Folder | identity | shortName | name |
| ------------- | ------ | -------- | --------- | ---- |
| Item | `templates/item/eaton-class/` | `Eaton.Templates.Item.Class.CSharp` | `eaton-class` | `Eaton Class` |
| Item | `templates/item/eaton-interface/` | `Eaton.Templates.Item.Interface.CSharp` | `eaton-interface` | `Eaton Interface` |
| Project | `templates/project/eaton-webapi/` | `Eaton.Templates.Project.WebApi.CSharp` | `eaton-webapi` | `Eaton Web API` |
| Project | `templates/project/eaton-console/` | `Eaton.Templates.Project.Console.CSharp` | `eaton-console` | `Eaton Console App` |
| Solution | `templates/solution/eaton-monolith/` | `Eaton.Templates.Solution.Monolith.CSharp` | `eaton-monolith` | `Eaton Monolith Solution` |

## Example `template.json`

```json
{
  "$schema": "http://json.schemastore.org/template",
  "author": "Austin Kaylor",
  "name": "Eaton Web API",
  "identity": "Eaton.Templates.Project.WebApi.CSharp",
  "groupIdentity": "Eaton.Templates.Project.WebApi.CSharp",
  "shortName": "eaton-webapi",
  "description": "Creates a minimal ASP.NET Core Web API with health checks.",
  "classifications": ["Web", "API", "Minimal API"],
  "tags": {
    "language": "C#",
    "type": "project"
  }
}
```

## Validation Checklist

Before publishing a new template, verify the following:

- [ ] `identity` uses `Eaton.Templates.<Type>.<Name>.CSharp`
- [ ] `shortName` is lowercase kebab-case and starts with `eaton-`
- [ ] `groupIdentity` matches the template family
- [ ] `name` is human-readable and uses title case
- [ ] Folder name aligns with `shortName`
- [ ] Symbol IDs use PascalCase
- [ ] CLI parameter names use kebab-case
- [ ] `tags.language` is `C#`
- [ ] `tags.type` is one of `item`, `project`, or `solution`
- [ ] Package references use `Eaton.AustinKaylor.Templates`

## Summary

Use these defaults unless there is a strong reason not to:

- **identity:** `Eaton.Templates.<Type>.<Name>.CSharp`
- **shortName:** `eaton-<name>`
- **groupIdentity:** `Eaton.Templates.<Type>.<Family>.CSharp`
- **package ID:** `Eaton.AustinKaylor.Templates`
- **folder name:** match `shortName`
- **symbol IDs:** PascalCase
- **CLI parameter names:** kebab-case

Consistent naming makes templates easier to author, test, publish, and consume.
