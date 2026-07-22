namespace TodoApi.Models;

/// <summary>
/// Represents an item on a list that needs done
/// </summary>
public class TodoItem
{
    /// <summary>
    /// The unique identifier for the task
    /// </summary>
    public Guid Id { get; set; } = Guid.CreateVersion7();

    /// <summary>
    /// The name of the task that needs done
    /// </summary>
    /// <example>Pet that dog</example>
    public string? Name { get; set; }

    /// <summary>
    /// If the task has been completed
    /// </summary>
    public bool IsComplete { get; set; }

    /// <summary>
    /// A secret note for the task
    /// </summary>
    public string? Secret { get; set; }
}