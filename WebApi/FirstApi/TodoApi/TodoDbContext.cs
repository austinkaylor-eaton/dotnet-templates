using Microsoft.EntityFrameworkCore;

using TodoApi.Models;

namespace TodoApi;

/// <summary>
/// Represents the database context for the API, providing access to the <see cref="TodoItem"/> entities.
/// </summary>
public class TodoContext : DbContext
{
    /// <inheritdoc/>
    public TodoContext(DbContextOptions<TodoContext> options)
        : base(options)
    {
    }

    /// <summary>
    /// Gets or sets the <see cref="TodoItem"/> entities.
    /// </summary>
    public DbSet<TodoItem> TodoItems { get; set; } = null!;
}