using UnityEngine;

namespace Meriam.ScriptableObjects
{
    /// <summary>
    /// Top-level tuning data for the whole Meriam Raya game.
    /// Tweak values in the Unity Inspector without touching code.
    /// </summary>
    [CreateAssetMenu(menuName = "Meriam/Config/GameConfig", fileName = "GameConfig")]
    public class GameConfigSO : ScriptableObject
    {
        [Header("Game Rules")]
        public int startingLives = 3;
        public int roundCount = 5;

        [Header("Cannon - Aiming (Player 1 / Anak Sulung)")]
        [Tooltip("Degrees per second that Player 1 can rotate the cannon barrel.")]
        public float cannonAimSpeed = 60f;
        public float minAimAngle = 0f;
        public float maxAimAngle = 75f;

        [Header("Cannon - Loading (Player 2 / Anak Bongsu)")]
        [Tooltip("Seconds Player 2 must hold the load button to fully pack the meriam.")]
        public float cannonLoadDuration = 2f;
        [Tooltip("Seconds after firing before the cannon can be loaded again.")]
        public float cannonCooldownDuration = 1.5f;

        [Header("Projectile (Bola Meriam)")]
        public float projectileSpeed = 15f;
        public float projectileLifetime = 4f;
        public int projectileDamage = 1;
        public GameObject cannonBallPrefab;

        [Header("Rounds")]
        public RoundConfigSO[] rounds;
    }
}
