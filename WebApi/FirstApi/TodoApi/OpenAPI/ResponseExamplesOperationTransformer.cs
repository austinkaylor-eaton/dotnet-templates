using System.Text.Json;
using Microsoft.AspNetCore.OpenApi;
using Microsoft.OpenApi;

namespace TodoApi.OpenAPI;

/// <summary>
/// An OpenAPI operation transformer that adds example responses to operations
/// by loading them from Examples.json, keyed by endpoint name (operationId).
/// </summary>
public class ResponseExamplesOperationTransformer : IOpenApiOperationTransformer
{
    private readonly OperationIdExamples? _examples;

    /// <summary>
    /// Initializes a new instance of the <see cref="ResponseExamplesOperationTransformer"/> class.
    /// </summary>
    /// <param name="env">The host environment.</param>
    public ResponseExamplesOperationTransformer(IHostEnvironment env)
    {
        // Load once; the transformer is registered as a singleton-like service per OpenAPI doc build
        var path = Path.Combine(env.ContentRootPath, "OpenAPI", "Examples.json");
        if (!File.Exists(path))
        {
            return;
        }

        var json = File.ReadAllText(path);
        var parsed = JsonSerializer.Deserialize<OperationIdExamples>(json);
        if (parsed is not null)
        {
            _examples = parsed;
        }
    }

    /// <inheritdoc/>
    public Task TransformAsync(
        OpenApiOperation operation,
        OpenApiOperationTransformerContext context,
        CancellationToken cancellationToken)
    {
        // if Examples.json is empty,
        // the operationId is empty,
        // the operation's API responses are empty,
        // or we can't get endpoint examples from Examples.json for the given operationId,
        // skip this API operation
        if (_examples is null || operation.OperationId is null || operation.Responses is null || !_examples.TryGetStatusCodesForOperationId(operation.OperationId, out var statusCodes))
        {
            return Task.CompletedTask;
        }

        if (statusCodes is null)
        {
            return Task.CompletedTask;
        }

        foreach ((string statusCode, IOpenApiResponse response) in operation.Responses)
        {
            if (!statusCodes.TryGetMediaTypesForStatusCode(statusCode, out var mediaTypes)
                || mediaTypes is null
                || response.Content is null)
            {
                continue;
            }

            foreach ((string mediaTypeKey, OpenApiMediaType value) in response.Content)
            {
                if (!mediaTypes.TryGetApiExampleForMediaType(mediaTypeKey, out var example) || example is null)
                {
                    continue;
                }

                value.Examples ??= new Dictionary<string, IOpenApiExample>();
                value.Examples["example"] = new OpenApiExample
                {
                    Summary = example.Summary,
                    Value = example.Value
                };
            }
        }

        return Task.CompletedTask;
    }
}