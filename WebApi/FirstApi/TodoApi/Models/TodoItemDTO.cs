namespace TodoApi.Models;

/// <summary>
/// A <see href="">data transfer object</see> for the <see cref="TodoItem"/> entity.
/// </summary>
/// <example>
/// <code>
/// var todoItem = TodoItemDTO.CreateBuilder()
///     .WithId(Guid.NewGuid())
///     .WithName("Learn C#")
///     .WithIsComplete(false)
///     .Build();
/// </code>
/// </example>
public class TodoItemDTO
{
    /// <inheritdoc cref="TodoItem.Id"/>
    public Guid Id { get; init; }

    /// <inheritdoc cref="TodoItem.Name"/>
    public string? Name { get; init; }

    /// <inheritdoc cref="TodoItem.IsComplete"/>
    public bool IsComplete { get; init; }

    /// <summary>
    /// Creates a new builder instance for constructing <see cref="TodoItemDTO"/> objects.
    /// </summary>
    /// <returns>A new <see cref="Builder"/> instance.</returns>
    public static Builder CreateBuilder()
    {
        return new Builder();
    }

    /// <summary>
    /// Explicitly converts a <see cref="TodoItemDTO"/> instance to a <see cref="TodoItem"/> entity.
    /// </summary>
    /// <param name="dto">The <see cref="TodoItemDTO"/> instance to convert.</param>
    /// <returns>A new <see cref="TodoItem"/> entity.</returns>
    public static explicit operator TodoItem(TodoItemDTO dto)
    {
        return new TodoItem { Id = dto.Id, Name = dto.Name, IsComplete = dto.IsComplete };
    }

    /// <summary>
    /// Explicitly converts a <see cref="TodoItem"/> entity to a <see cref="TodoItemDTO"/> instance.
    /// </summary>
    /// <param name="entity">The <see cref="TodoItem"/> entity to convert.</param>
    /// <returns>A new <see cref="TodoItemDTO"/> instance.</returns>
    public static explicit operator TodoItemDTO(TodoItem entity)
    {
        return new TodoItemDTO { Id = entity.Id, Name = entity.Name, IsComplete = entity.IsComplete };
    }

    /// <summary>
    /// Builder class for fluent construction of <see cref="TodoItemDTO"/> instances.
    /// </summary>
    /// <example>
    /// <code>
    /// var todoItem = TodoItemDTO.CreateBuilder()
    ///     .WithId(Guid.NewGuid())
    ///     .WithName("Learn C#")
    ///     .WithIsComplete(false)
    ///     .Build();
    /// </code>
    /// </example>
    public class Builder
    {
        private Guid _id = Guid.Empty;
        private string? _name;
        private bool _isComplete;

        /// <summary>
        /// Sets the ID for the TodoItemDTO being built.
        /// </summary>
        /// <param name="id">The ID value.</param>
        /// <returns>This builder instance for method chaining.</returns>
        public Builder WithId(Guid id)
        {
            _id = id;
            return this;
        }

        /// <summary>
        /// Sets the name for the TodoItemDTO being built.
        /// </summary>
        /// <param name="name">The name value.</param>
        /// <returns>This builder instance for method chaining.</returns>
        public Builder WithName(string? name)
        {
            _name = name;
            return this;
        }

        /// <summary>
        /// Sets the completion status for the TodoItemDTO being built.
        /// </summary>
        /// <param name="isComplete">The completion status.</param>
        /// <returns>This builder instance for method chaining.</returns>
        public Builder WithIsComplete(bool isComplete)
        {
            _isComplete = isComplete;
            return this;
        }

        /// <summary>
        /// Builds and returns a new <see cref="TodoItemDTO"/> instance with the configured values.
        /// </summary>
        /// <returns>A new TodoItemDTO instance.</returns>
        public TodoItemDTO Build()
        {
            return new TodoItemDTO
            {
                Id = _id,
                Name = _name,
                IsComplete = _isComplete
            };
        }
    }
}

