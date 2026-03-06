using UnityEngine;

namespace Meriam.Targets
{
    /// <summary>
    /// Kelapa - coconut placed on a post or stacked in the yard.
    /// When hit it tumbles and rolls away with a satisfying thunk.
    /// </summary>
    public class TargetKelapa : TargetBase
    {
        [SerializeField] private Rigidbody2D rb;
        [SerializeField] private float rollForce = 5f;

        protected override void OnHit()
        {
            base.OnHit();
            if (rb != null)
            {
                rb.isKinematic = false;
                rb.AddForce(Vector2.right * rollForce, ForceMode2D.Impulse);
                rb.AddTorque(rollForce * 0.5f);
            }
        }

        protected override void SpawnDeathEffect()
        {
            // Kelapa rolls off screen; handled by OnHit physics + Destroy after delay
            Invoke(nameof(DelayedDestroy), 1.5f);
        }

        public override void OnDeath()
        {
            int scoreValue = config != null ? config.scoreValue : 100;
            Meriam.Core.GameManager.Instance?.OnTargetDefeated(scoreValue);
            SpawnDeathEffect();
            // Don't Destroy immediately - let it roll first
        }

        private void DelayedDestroy() => Destroy(gameObject);
    }
}
