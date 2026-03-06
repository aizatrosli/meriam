namespace Meriam.Interfaces
{
    /// <summary>
    /// Implemented by the cannon barrel. Player 1 (Anak Sulung) controls aiming.
    /// Angle 0 = horizontal, positive = upward.
    /// </summary>
    public interface IAimable
    {
        float CurrentAngle { get; }
        float MinAngle { get; }
        float MaxAngle { get; }
        bool IsLocked { get; }
        void AdjustAim(float deltaAngle);
        void SetAimAngle(float angle);
    }
}
