using Microsoft.AspNetCore.Mvc;

namespace TodoApi.Controllers;

/// <summary>
/// Controller for performing basic mathematical operations.
/// </summary>
[Route("api/[controller]/[action]")]
[ApiController]
public class ValuesController : ControllerBase
{
    /// <summary>
    /// Divides two numbers.
    /// </summary>
    /// <param name="numerator">The numerator.</param>
    /// <param name="denominator">The denominator.</param>
    /// <returns>The result of the division.</returns>
    /// <example>GET: api/values/divide/1/2</example>
    [HttpGet("{numerator:double}/{denominator:double}")]
    [ProducesResponseType(200, Description = "The numerator was successfully divided by the denominator.")]
    [ProducesResponseType(400, Type = typeof(ProblemDetails), Description = "The denominator was zero.")]
    public IActionResult Divide(double numerator, double denominator)
    {
        if (denominator == 0)
        {
            return BadRequest();
        }

        return Ok(numerator / denominator);
    }

    /// <summary>
    /// Calculates the square root of a number.
    /// </summary>
    /// <param name="radicand">The number to calculate the square root of.</param>
    /// <returns>The square root of the number.</returns>
    /// <example>GET: api/values/squareroot/4</example>
    [HttpGet("{radicand:double}")]
    [ProducesResponseType(200, Type = typeof(double),  Description = "The square root of the radicand was successfully calculated.")]
    [ProducesResponseType(400, Type = typeof(ProblemDetails), Description = "The radicand was negative.")]
    public IActionResult Squareroot(double radicand)
    {
        if (radicand < 0)
        {
            return BadRequest();
        }

        return Ok(Math.Sqrt(radicand));
    }
}