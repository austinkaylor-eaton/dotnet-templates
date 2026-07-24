# Template naming and identity conventions
Use a predictable scheme across all template types:

- **identity:** `Eaton.Templates.<Type>.<Name>.CSharp`
- **shortName:** concise CLI-friendly names like `eaton-webapi`, `eaton-class`
- **groupIdentity:** same for related variants (e.g., auth/no-auth versions)
- **package id (NuGet):** `Eaton.AustinKaylor.Templates`
- **tags:**
  - type: item, project, solution
  - language: C#
  This keeps `dotnet new list` clean and helps users understand what to install.