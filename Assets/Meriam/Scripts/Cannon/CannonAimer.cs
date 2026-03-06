using Meriam.Interfaces;
using Meriam.ScriptableObjects;
using UnityEngine;

namespace Meriam.Cannon
{
    /// <summary>
    /// Controlled by Player 1 (Anak Sulung).
    /// Rotates the meriam buluh barrel pivot within [MinAngle, MaxAngle].
    /// Locks aiming during the cooldown after a shot.
    /// </summary>
    public class CannonAimer : MonoBehaviour, IAimable
    {
        [SerializeField] private Transform barrelPivot;
        [SerializeField] private GameConfigSO config;

        public float CurrentAngle { get; private set; }
        public float MinAngle => config != null ? config.minAimAngle : 0f;
        public float MaxAngle => config != null ? config.maxAimAngle : 75f;
        public bool IsLocked { get; set; }

        // Called from tests to bypass Awake dependency resolution
        public void InitializeForTesting(GameConfigSO testConfig)
        {
            config = testConfig;
            CurrentAngle = 0f;
            IsLocked = false;
        }

        public void AdjustAim(float deltaAngle)
        {
            if (IsLocked) return;
            SetAimAngle(CurrentAngle + deltaAngle);
        }

        public void SetAimAngle(float angle)
        {
            if (IsLocked) return;
            CurrentAngle = Mathf.Clamp(angle, MinAngle, MaxAngle);
            ApplyRotation();
        }

        private void ApplyRotation()
        {
            if (barrelPivot != null)
                barrelPivot.localRotation = Quaternion.Euler(0f, 0f, CurrentAngle);
        }
    }
}
