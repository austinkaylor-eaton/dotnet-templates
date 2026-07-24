## Template Catalog

This document is the canonical inventory of templates in this repository.

Use it to answer these questions quickly:

- Which templates exist today?
- What type of template is each one?
- What framework or baseline does it target?
- What lifecycle stage is it in?
- Which package version first introduced it?

## How to Use This Catalog

- Add one row per template
- Update the row when a template is first published
- Keep `short name`, `type`, and `baseline/framework` aligned with the template's
  `template.json`
- Update the `status` when the template moves through its lifecycle
- Treat this file as release-facing documentation and update it in the same pull
  request as the template change

## Status Values

Use these status values consistently:

| Status       | Meaning                                                    |
|--------------|------------------------------------------------------------|
| `draft`      | Early work in progress; not ready for general use          |
| `ready`      | Authoring and validation are complete; waiting for release |
| `published`  | Included in a published package                            |
| `deprecated` | Still available, but no longer recommended for new use     |

## Catalog Columns

| Column                       | Description                                          |
|------------------------------|------------------------------------------------------|
| `short name`                 | The `dotnet new` short name, such as `eaton-webapi`  |
| `type`                       | Template category: `item`, `project`, or `solution`  |
| `language`                   | Template language, currently `C#`                    |
| `baseline/framework`         | The primary target framework, platform, or baseline  |
| `status`                     | Current lifecycle status from the table above        |
| `package version introduced` | The first package version that included the template |

## Current Catalog

| short name                   | type | language | baseline/framework | status  | package version introduced |
|------------------------------|------|----------|--------------------|---------|----------------------------|
| _No templates published yet_ | -    | -        | -                  | `draft` | -                          |

## Example Entries

Use entries like these once templates are added:

| short name       | type       | language | baseline/framework | status      | package version introduced |
|------------------|------------|----------|--------------------|-------------|----------------------------|
| `eaton-class`    | `item`     | `C#`     | `net8.0+`          | `published` | `0.1.0`                    |
| `eaton-webapi`   | `project`  | `C#`     | `net8.0`           | `published` | `0.2.0`                    |
| `eaton-monolith` | `solution` | `C#`     | `net9.0`           | `ready`     | -                          |

## Maintenance Rules

- Keep rows sorted by `short name` unless a different ordering becomes more
  useful
- Do not remove deprecated templates; mark them as `deprecated` instead
- If a template changes significantly but keeps the same identity, update the
  existing row rather than adding a duplicate
- If a template is replaced by a new template with a different identity or
  `shortName`, add a new row and deprecate the old one

## Related Documents

- [docs/architecture.md](architecture.md)
- [docs/authoring-guide.md](authoring-guide.md)
- [docs/naming-conventions.md](naming-conventions.md)
- [docs/release-process.md](release-process.md)
