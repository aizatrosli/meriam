using UnityEngine;

namespace Meriam.Targets
{
    /// <summary>
    /// Belon - colourful balloon tied to a post in the kampung yard.
    /// Floats upward slowly; when hit it pops with confetti.
    /// High-value but hard-to-hit bonus target.
    /// </summary>
    public class TargetBelon : TargetBase
    {
        [SerializeField] private float driftSpeed = 0.3f;
        [SerializeField] private float driftAmplitude = 0.2f;
        [SerializeField] private GameObject popVFXPrefab;

        private Vector3 startPos;

        protected override void Awake()
        {
            base.Awake();
            startPos = transform.position;
        }

        private void Update()
        {
            if (!IsAlive) return;
            // Gentle upward drift with side-sway
            float drift = driftAmplitude * Mathf.Sin(Time.time * 1.2f);
            transform.position = new Vector3(
                startPos.x + drift,
                transform.position.y + driftSpeed * Time.deltaTime,
                startPos.z);
        }

        protected override void SpawnDeathEffect()
        {
            if (popVFXPrefab != null)
                Instantiate(popVFXPrefab, transform.position, Quaternion.identity);
        }
    }
}
