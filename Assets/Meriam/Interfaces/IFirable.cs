namespace Meriam.Interfaces
{
    /// <summary>
    /// Implemented by CannonFirer. Player 2 triggers the fire after loading.
    /// Produces a loud boom sound and launches a projectile (bola meriam).
    /// </summary>
    public interface IFirable
    {
        bool CanFire { get; }
        float CooldownDuration { get; }
        void Fire();
        event System.Action OnFired;
        event System.Action OnCooldownComplete;
    }
}
