using System.Diagnostics;
using Microsoft.AspNetCore.Http.Features;

namespace TodoApi;

/// <summary>
/// Configures problem details to include request context information.
/// </summary>
public class ProblemDetailsCustomizer
{
    /// <summary>
    /// Customizes the problem details with additional request information.
    /// </summary>
    /// <param name="context">The problem details context containing HTTP context and problem details.</param>
    /// <remarks>
    /// Adds the following details to the problem response:
    /// - Instance: The HTTP method and request path
    /// - RequestId: The HTTP trace identifier
    /// - TraceId: The diagnostic trace ID from the current activity
    /// </remarks>
    public void Customize(ProblemDetailsContext context)
    {
        context.ProblemDetails.Instance =
            $"{context.HttpContext.Request.Method} {context.HttpContext.Request.Path}";

        context.ProblemDetails.Extensions.TryAdd("requestId", context.HttpContext.TraceIdentifier);

        Activity? activity = context.HttpContext.Features.Get<IHttpActivityFeature>()?.Activity;
        context.ProblemDetails.Extensions.TryAdd("traceId", activity?.Id);
    }
}