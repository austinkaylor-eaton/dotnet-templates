using System.Text.Json.Nodes;
using System.Text.Json.Serialization;

namespace TodoApi.OpenAPI;

/// <summary>
/// Represents an example for an API response, including a summary and a JSON value.
/// </summary>
public class ApiExample
{
    /// <summary>
    /// A brief summary about the example.
    /// </summary>
    [JsonPropertyName("summary")]
    public string? Summary { get; set; }

    /// <summary>
    /// The JSON value of the example.
    /// </summary>
    [JsonPropertyName("value")]
    public JsonNode? Value { get; set; }
}

/// <summary>
/// Represents a collection of examples by media type (e.g., "application/json").
/// </summary>
public class StatusCodeMediaTypes : Dictionary<string, ApiExample>
{
    /// <summary>
    /// Tries to get the example for a given media type.
    /// </summary>
    /// <param name="mediaType">The media type of the response (e.g., "application/json").</param>
    /// <param name="mediaTypeExample">The example for the media type, if found.</param>
    /// <returns>True if the example was found; otherwise, false.</returns>
    public bool TryGetApiExampleForMediaType(string mediaType, out ApiExample? mediaTypeExample)
    {
        return base.TryGetValue(mediaType, out mediaTypeExample);
    }
}

/// <summary>
/// Represents a collection of examples by status code (e.g., "200", "400").
/// </summary>
public class OperationStatusCodes : Dictionary<string, StatusCodeMediaTypes>
{
    /// <summary>
    /// Tries to get the examples for a given status code.
    /// </summary>
    /// <param name="statusCode">The status code of the response.</param>
    /// <param name="statusCodeExamples">The examples for the status code, if found.</param>
    /// <returns>True if the examples were found; otherwise, false.</returns>
    public bool TryGetMediaTypesForStatusCode(string statusCode, out StatusCodeMediaTypes? statusCodeExamples)
    {
        return base.TryGetValue(statusCode, out statusCodeExamples);
    }
}

/// <summary>
/// Represents examples organized by operationId (endpoint name).
/// </summary>
public class OperationIdExamples : Dictionary<string, OperationStatusCodes>
{
    /// <summary>
    /// Tries to get the examples for a given endpoint (operationId).
    /// </summary>
    /// <param name="operationId">The operationId of the endpoint.</param>
    /// <param name="operationIdExamples">The examples for the endpoint, if found.</param>
    /// <returns>True if the examples were found; otherwise, false.</returns>
    public bool TryGetStatusCodesForOperationId(string operationId, out OperationStatusCodes? operationIdExamples)
    {
        return base.TryGetValue(operationId, value: out operationIdExamples);
    }
}



