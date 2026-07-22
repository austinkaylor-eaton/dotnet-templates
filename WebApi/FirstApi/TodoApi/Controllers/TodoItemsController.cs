using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using TodoApi.Models;

namespace TodoApi.Controllers;

/// <summary>
/// Controller for managing <see cref="TodoItem"/> entities.
/// </summary>
/// <param name="context">The database context for accessing TodoItems.</param>
[Route("api/[controller]")]
[ApiController]
public class TodoItemsController(TodoContext context) : ControllerBase
{
    /// <summary>
    /// Retrieves all <see cref="TodoItem"/> entities from the database and returns them as a list of <see cref="TodoItemDTO"/>s.
    /// </summary>
    /// <example>GET: api/TodoItems</example>
    /// <returns>A list of <see cref="TodoItemDTO"/>s.</returns>
    [HttpGet]
    [EndpointName(nameof(GetTodoItems))]
    [ProducesResponseType<IEnumerable<TodoItemDTO>>(StatusCodes.Status200OK, "application/json", Description = "The existing list of TodoItems was successfully retrieved.")]
    public async Task<ActionResult<IEnumerable<TodoItemDTO>>> GetTodoItems()
    {
        return await context.TodoItems
            .Select(todoItem => (TodoItemDTO)todoItem)
            .ToListAsync();
    }

    /// <summary>
    /// Retrieves a specific <see cref="TodoItem"/> entity by its ID and returns it as a <see cref="TodoItemDTO"/>.
    /// </summary>
    /// <param name="id">The ID of the <see cref="TodoItem"/> to retrieve.</param>
    /// <example>GET: api/TodoItems/5</example>
    /// <returns>The requested <see cref="TodoItemDTO"/>.</returns>
    [HttpGet("{id:guid}")]
    [EndpointName(nameof(GetTodoItem))]
    [ProducesResponseType<TodoItemDTO>(StatusCodes.Status200OK, "application/json", Description = "The TodoItem was successfully retrieved.")]
    // [ProducesResponseType<ProblemDetails>(StatusCodes.Status400BadRequest, "application/problem+json", Description = "The id provided in the url was not a properly-formatted GUID.")]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status404NotFound, "application/problem+json", Description = "The TodoItem was not found.")]
    [ProducesResponseType(StatusCodes.Status404NotFound, Description = "The id passed in the url does was not a properly formatted GUID.")]
    public async Task<ActionResult<TodoItemDTO>> GetTodoItem(Guid id)
    {
        var todoItem = await context.TodoItems.FindAsync(id);

        if (todoItem == null)
        {
            return NotFound();
        }

        return (TodoItemDTO)todoItem;
    }

    /// <summary>
    /// Updates a specific <see cref="TodoItem"/> entity by its ID.
    /// </summary>
    /// <param name="id">The ID of the <see cref="TodoItem"/> to update.</param>
    /// <param name="todoItemDto">The updated <see cref="TodoItemDTO"/>.</param>
    /// <example>PUT: api/TodoItems/5</example>
    /// <remarks>To protect from overposting attacks, see https://go.microsoft.com/fwlink/?linkid=2123754</remarks>
    /// <returns>No content if the update is successful.</returns>
    [HttpPut("{id:guid}")]
    [EndpointName(nameof(PutTodoItem))]
    [ProducesResponseType(StatusCodes.Status204NoContent, Description = "The TodoItem was successfully updated.")]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status400BadRequest, "application/problem+json", Description = "The id passed in the url does not match the id passed in the request body.")]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status404NotFound, "application/problem+json", Description = "The TodoItem was not found.")]
    [ProducesResponseType(StatusCodes.Status404NotFound, Description = "The id passed in the url does was not a properly formatted GUID.")]
    public async Task<IActionResult> PutTodoItem(Guid id, TodoItemDTO todoItemDto)
    {
        var todoItem = (TodoItem)todoItemDto;

        if (id != todoItem.Id)
        {
            return BadRequest();
        }

        context.Entry(todoItem).State = EntityState.Modified;

        try
        {
            await context.SaveChangesAsync();
        }
        catch (DbUpdateConcurrencyException)
        {
            if (!TodoItemExists(id))
            {
                return NotFound();
            }

            throw;
        }

        return NoContent();
    }

    /// <summary>
    /// Creates a new <see cref="TodoItem"/> entity.
    /// </summary>
    /// <param name="todoItemDto">The <see cref="TodoItemDTO"/> to create.</param>
    /// <example>POST: api/TodoItems</example>
    /// <remarks>
    /// A url of the newly created <see cref="TodoItem"/> entity can be obtained from the <see cref="CreatedAtActionResult"/> returned by this method.
    /// </remarks>
    /// <returns>The created <see cref="TodoItemDTO"/>.</returns>
    [HttpPost]
    [ProducesResponseType(typeof(TodoItemDTO), StatusCodes.Status201Created, Description = "The TodoItem was successfully created.")]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status400BadRequest, "application/problem+json", Description = "The new TodoItem had invalid data and could not be created.")]
    [EndpointName(nameof(PostTodoItem))]
    public async Task<ActionResult<TodoItemDTO>> PostTodoItem(TodoItemDTO todoItemDto)
    {
        var todoItem = (TodoItem)todoItemDto;

        context.TodoItems.Add(todoItem);
        await context.SaveChangesAsync();

        return CreatedAtAction(nameof(GetTodoItem), new { id = todoItem.Id }, (TodoItemDTO)todoItem);
    }

    /// <summary>
    /// Deletes a specific <see cref="TodoItem"/> entity by its ID.
    /// </summary>
    /// <param name="id">The ID of the <see cref="TodoItem"/> to delete.</param>
    /// <example>DELETE: api/TodoItems/5</example>
    /// <returns>No content if the deletion is successful.</returns>
    [HttpDelete("{id:guid}")]
    [EndpointName(nameof(DeleteTodoItem))]
    [ProducesResponseType(StatusCodes.Status204NoContent, Description = "The TodoItem was successfully deleted.")]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status400BadRequest, "application/problem+json", Description = "The id provided in the url was not a properly-formatted GUID.")]
    [ProducesResponseType<ProblemDetails>(StatusCodes.Status404NotFound, "application/problem+json", Description = "The TodoItem was not found.")]
    public async Task<IActionResult> DeleteTodoItem(Guid id)
    {
        var todoItem = await context.TodoItems.FindAsync(id);
        if (todoItem == null)
        {
            return NotFound();
        }

        context.TodoItems.Remove(todoItem);
        await context.SaveChangesAsync();

        return NoContent();
    }

    /// <summary>
    /// Throws an unhandled exception to demonstrate error handling in the API.
    /// </summary>
    /// <returns>This method does not return a value.</returns>
    /// <exception cref="ApplicationException">Always throws a <see cref="ApplicationException"/>.</exception>
    /// <example>GET: api/TodoItems/Throw</example>
    [HttpGet("Throw")]
    [EndpointName(nameof(Throw))]
    public IActionResult Throw() =>
        throw new ApplicationException("Sample exception.");

    /// <summary>
    /// Checks if a <see cref="TodoItem"/> entity exists in the database by its ID.
    /// </summary>
    /// <param name="id">The ID of the <see cref="TodoItem"/> to check.</param>
    /// <returns><c>true</c> if the <see cref="TodoItem"/> exists; otherwise, <c>false</c>.</returns>
    private bool TodoItemExists(Guid id)
    {
        return context.TodoItems.Any(e => e.Id == id);
    }
}