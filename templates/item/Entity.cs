namespace Eaton.AustinKaylor.Templates.Item;

public class Entity
{
    public int Id { get; }
    public string Name { get; }
}

public interface IEntityBuilder
{
    void WithId(int id);
    void WithName(string name);
}

public sealed class EntityBuilder : IEntityBuilder
{
    private int _id;
    private string _name;

    public void WithId(int id)
    {
        _id = id;
    }

    public void WithName(string name)
    {
        _name = name;
    }

    public Entity Build()
    {
        return new Entity(_id, _name);
    }
}

