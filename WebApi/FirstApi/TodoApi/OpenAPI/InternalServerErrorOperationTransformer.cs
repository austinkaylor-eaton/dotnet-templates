using System.Text.Json.Nodes;

using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.OpenApi;
using Microsoft.OpenApi;

namespace TodoApi.OpenAPI;

/// <summary>
/// A custom implementation of <see cref="IOpenApiOperationTransformer"/> that transforms the OpenAPI operation
/// for the API by adding a 500 Internal Server Error response to each operation.
/// </summary>
/// <remarks>
/// This transformer ensures that every API operation includes a standard response for unexpected server errors. <br/>
/// <see href="https://learn.microsoft.com/en-us/aspnet/core/fundamentals/openapi/customize-openapi?view=aspnetcore-10.0#use-operation-transformers">Microsoft Learn - Use operation transformers </see>
/// </remarks>
public class InternalServerErrorOperationTransformer : IOpenApiOperationTransformer
{
    /// <inheritdoc />
    public async Task TransformAsync(OpenApiOperation operation, OpenApiOperationTransformerContext context, CancellationToken cancellationToken)
    {
        // Generate schema for error responses
        // see -> https://learn.microsoft.com/en-us/aspnet/core/fundamentals/openapi/customize-openapi?view=aspnetcore-10.0#support-for-generating-openapischemas-in-transformers
        /*var errorSchema = await context.GetOrCreateSchemaAsync(typeof(ProblemDetails), null, cancellationToken);
        context.Document?.AddComponent("Error", errorSchema);*/

       operation.Responses?.Add("500", new OpenApiResponse
        {
            Description = "Internal Server Error",
            Content = new Dictionary<string, OpenApiMediaType>
            {
                ["application/problem+json"] = new()
                {
                    Schema = await context.GetOrCreateSchemaAsync(typeof(ProblemDetails), null, cancellationToken),
                    Examples = new Dictionary<string, IOpenApiExample>
                    {
                        ["500-example"] = new OpenApiExample
                        {
                            Summary = "A typical 500 Internal Server Error response",
                            Value = new JsonObject
                            {
                                ["type"] = "https://tools.ietf.org/html/rfc9110#section-15.6.1",
                                ["title"] = "System.ApplicationException",
                                ["status"] = 500,
                                ["detail"] = "Sample exception.",
                                ["traceId"] = "00-41980fe4d73fce005dbd8b740a4a756c-31621aaee9f1edc3-00",
                                ["exception"] = new JsonObject
                                {
                                    ["details"] = "System.ApplicationException: Sample exception.\r\n   at TodoApi.Controllers.TodoItemsController.Throw()",
                                    ["path"] = "/api/TodoItems/Throw",
                                    ["endpoint"] = "TodoApi.Controllers.TodoItemsController.Throw (TodoApi)",
                                    ["routeValues"] = new JsonObject
                                    {
                                        ["action"] = "Throw",
                                        ["controller"] = "TodoItems"
                                    }
                                }
                            }
                        }
                    }
                }
            }
        });

        await Task.CompletedTask;
    }
}