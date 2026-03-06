using UnityEngine;

namespace Meriam.Targets
{
    /// <summary>
    /// Pelita - traditional oil lamp hung on a string.
    /// Swings gently; when hit, the flame extinguishes with a smoke puff.
    /// Common sight in kampung during Ramadan / Raya night.
    /// </summary>
    public class TargetPelita : TargetBase
    {
        [SerializeField] private GameObject flameObject;
        [SerializeField] private GameObject smokeVFXPrefab;
        [SerializeField] private float swingAmplitude = 15f;
        [SerializeField] private float swingFrequency = 0.8f;

        private float swingOffset;

        protected override void Awake()
        {
            base.Awake();
            swingOffset = Random.Range(0f, Mathf.PI * 2f);
        }

        private void Update()
        {
            if (!IsAlive) return;
            float angle = swingAmplitude * Mathf.Sin(Time.time * swingFrequency * Mathf.PI * 2f + swingOffset);
            transform.localRotation = Quaternion.Euler(0f, 0f, angle);
        }

        protected override void OnHit()
        {
            base.OnHit();
            // Briefly dim the flame on hit
            if (flameObject != null)
                flameObject.GetComponent<Light>()?.gameObject.SetActive(false);
        }

        protected override void SpawnDeathEffect()
        {
            if (flameObject != null) flameObject.SetActive(false);
            if (smokeVFXPrefab != null)
                Instantiate(smokeVFXPrefab, transform.position, Quaternion.identity);
        }
    }
}
