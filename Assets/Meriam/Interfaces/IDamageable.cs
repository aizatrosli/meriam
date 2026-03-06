namespace Meriam.Interfaces
{
    /// <summary>
    /// Implemented by any game object that can be hit by a meriam projectile.
    /// Targets in the Raya night scene: oil lamps, coconuts, pots, etc.
    /// </summary>
    public interface IDamageable
    {
        int MaxHealth { get; }
        int CurrentHealth { get; }
        bool IsAlive { get; }
        void TakeDamage(int amount);
        void OnDeath();
    }
}
