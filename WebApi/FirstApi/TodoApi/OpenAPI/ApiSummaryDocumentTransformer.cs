using Microsoft.AspNetCore.OpenApi;
using Microsoft.OpenApi;

namespace TodoApi.OpenAPI;

/// <summary>
/// A custom implementation of <see cref="IOpenApiDocumentTransformer"/> that transforms the OpenAPI document
/// for the API by adding a summary, version, and other important top-level information
/// </summary>
/// <remarks>
/// <see href="https://learn.microsoft.com/en-us/aspnet/core/fundamentals/openapi/customize-openapi?view=aspnetcore-10.0#use-document-transformers"> Microsoft Learn - Customize OpenAPI documents with document transformers</see>
/// </remarks>
public class ApiSummaryDocumentTransformer : IOpenApiDocumentTransformer
{
    /// <inheritdoc />
    public Task TransformAsync(OpenApiDocument document, OpenApiDocumentTransformerContext context, CancellationToken cancellationToken)
    {
        try
        {
            // Add a summary to the OpenAPI document
            document.Info.Summary = "This is a sample API for managing Todo items.";

            // Add a version to the OpenAPI document
            document.Info.Version = "1.0.0";

            // Add a description to the OpenAPI document
            document.Info.Description = "This API allows you to create, read, update, and delete Todo items.";

            // Add contact information to the OpenAPI document
            document.Info.Contact = new OpenApiContact
            {
                Name = "Todo API Support",
                Email = "AustinJKaylor@eaton.com"
            };
            return Task.CompletedTask;
        }
        catch (Exception exception)
        {
            return Task.FromException(exception);
        }
    }
}