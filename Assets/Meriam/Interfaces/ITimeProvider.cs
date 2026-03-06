namespace Meriam.Interfaces
{
    /// <summary>
    /// Abstraction over Unity's Time.deltaTime to allow deterministic EditMode testing
    /// of time-dependent components such as CannonLoader and CannonFirer.
    /// </summary>
    public interface ITimeProvider
    {
        float DeltaTime { get; }
    }
}
