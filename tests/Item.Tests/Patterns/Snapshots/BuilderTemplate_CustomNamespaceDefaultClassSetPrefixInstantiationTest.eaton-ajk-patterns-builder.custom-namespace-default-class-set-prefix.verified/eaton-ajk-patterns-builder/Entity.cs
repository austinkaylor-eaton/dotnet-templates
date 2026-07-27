namespace My.App.Models;

/// <summary>
/// Represents the entity created by the builder pattern.
/// </summary>
public class Entity
{
    /// <summary>
    /// Gets the entity identifier.
    /// </summary>
    public int Id { get; }

    /// <summary>
    /// Gets the entity name.
    /// </summary>
    public string Name { get; }

    private Entity(int id, string name)
    {
        Id = id;
        Name = name;
    }

    /// <summary>
    /// Provides a fluent builder for <see cref="Entity"/>.
    /// </summary>
    /// <example>
    /// <code>
    /// var entity = new Entity.Builder()
    ///     .SetId(1)
    ///     .SetName("Sample")
    ///     .Build();
    /// </code>
    /// </example>
    public sealed class Builder
    {
        private int id;
        private string? name;

        /// <summary>
        /// Sets the identifier.
        /// </summary>
        /// <param name="value">The identifier value.</param>
        /// <returns>The current builder instance.</returns>
        public Builder SetId(int value)
        {
            id = value;
            return this;
        }

        /// <summary>
        /// Sets the name.
        /// </summary>
        /// <param name="value">The name value.</param>
        /// <returns>The current builder instance.</returns>
        public Builder SetName(string value)
        {
            name = value;
            return this;
        }

        /// <summary>
        /// Builds an <see cref="Entity"/> with the configured values.
        /// </summary>
        /// <returns>A fully constructed <see cref="Entity"/>.</returns>
        /// <exception cref="InvalidOperationException">
        /// Thrown when required values are missing.
        /// </exception>
        /// <example>
        /// <code>
        /// var entity = new Entity.Builder()
        ///     .SetId(1)
        ///     .SetName("Sample")
        ///     .Build();
        /// </code>
        /// </example>
        public Entity Build()
        {
            return new Entity(id, name ?? string.Empty);
        }
    }
}
