using UnityEngine;

namespace Meriam.ScriptableObjects
{
    /// <summary>
    /// Data for a single target type in the Raya night scene.
    /// Examples: Pelita (oil lamp), Kelapa (coconut), Periuk (clay pot),
    ///           Belon (balloon), Pasu Bunga (flower pot).
    /// </summary>
    [CreateAssetMenu(menuName = "Meriam/Config/TargetConfig", fileName = "TargetConfig")]
    public class TargetConfigSO : ScriptableObject
    {
        [Header("Identity")]
        public string targetId;

        [Tooltip("Malay name shown in UI, e.g. 'Pelita', 'Kelapa'.")]
        public string displayNameMalay;

        [Header("Stats")]
        public int baseHealth = 1;
        public int scoreValue = 100;

        [Header("Prefab")]
        public GameObject prefab;

        [Header("Behaviour")]
        public TargetType type;

        [Tooltip("Does the target swing or sway? True for hanging targets like lanterns.")]
        public bool isSwinging;

        [Tooltip("Does the target move across the yard? True for rolling coconuts.")]
        public bool isMoving;

        public float moveSpeed = 1f;
    }

    public enum TargetType
    {
        Stationary,   // Periuk, Pasu Bunga
        Swinging,     // Pelita (oil lamp on string), Tanglung (lantern)
        Rolling,      // Kelapa (coconut)
        Floating,     // Belon (balloon) drifts upward slowly
    }
}
