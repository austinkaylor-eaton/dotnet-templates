namespace Eaton.AustinKaylor.Templates.Item.Patterns.Builder;

/// <summary>
/// Represents the entity created by the builder pattern.
/// </summary>
public class Order
{
    /// <summary>
    /// Gets the entity identifier.
    /// </summary>
    public int Id { get; }

    /// <summary>
    /// Gets the entity name.
    /// </summary>
    public string Name { get; }

    private Order(int id, string name)
    {
        Id = id;
        Name = name;
    }

    /// <summary>
    /// Provides a fluent builder for <see cref="Order"/>.
    /// </summary>
    /// <example>
    /// <code>
    /// var entity = new Order.Builder()
    ///     .WithId(1)
    ///     .WithName("Sample")
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
        public Builder WithId(int value)
        {
            id = value;
            return this;
        }

        /// <summary>
        /// Sets the name.
        /// </summary>
        /// <param name="value">The name value.</param>
        /// <returns>The current builder instance.</returns>
        public Builder WithName(string value)
        {
            name = value;
            return this;
        }

        /// <summary>
        /// Builds an <see cref="Order"/> with the configured values.
        /// </summary>
        /// <returns>A fully constructed <see cref="Order"/>.</returns>
        /// <exception cref="InvalidOperationException">
        /// Thrown when required values are missing.
        /// </exception>
        /// <example>
        /// <code>
        /// var entity = new Order.Builder()
        ///     .WithId(1)
        ///     .WithName("Sample")
        ///     .Build();
        /// </code>
        /// </example>
        public Order Build()
        {
            return new Order(id, name ?? string.Empty);
        }
    }
}
