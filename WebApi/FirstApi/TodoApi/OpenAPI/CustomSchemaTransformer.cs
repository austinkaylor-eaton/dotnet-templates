using Microsoft.AspNetCore.OpenApi;
using Microsoft.OpenApi;

namespace TodoApi.OpenAPI;

/// <summary>
/// A custom implementation of <see cref="IOpenApiSchemaTransformer"/> that transforms the OpenAPI schema for the API by adding custom schema transformations.
/// </summary>
public class CustomSchemaTransformer : IOpenApiSchemaTransformer
{
    /// <inheritdoc />
    public Task TransformAsync(OpenApiSchema schema, OpenApiSchemaTransformerContext context, CancellationToken cancellationToken)
    {
        return Task.CompletedTask;
    }
}