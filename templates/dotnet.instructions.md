---
applyTo: "**/*.cs,**/*.csproj,**/*.fsproj,**/*.vbproj"
---
# .NET-specific Copilot guidance

- Check the target framework and existing project conventions before proposing changes.
- Follow the repository's existing dependency injection, logging, exception handling and test patterns.
- Do not assume modern ASP.NET Core conventions apply to .NET Framework, WebForms, or older application types.
- Identify affected projects and test coverage before implementing changes.
- Avoid adding packages or changing target frameworks without explicit approval.
- Prefer existing architecture and project conventions to generic examples.
