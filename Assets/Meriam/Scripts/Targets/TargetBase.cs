using Meriam.Core;
using Meriam.Interfaces;
using Meriam.ScriptableObjects;
using UnityEngine;

namespace Meriam.Targets
{
    /// <summary>
    /// Abstract base for all Raya night targets placed in the kampung yard.
    /// Examples: Pelita (oil lamp), Kelapa (coconut), Periuk (clay pot),
    ///           Tanglung (lantern), Belon (balloon), Pasu Bunga (flower pot).
    /// </summary>
    public abstract class TargetBase : MonoBehaviour, IDamageable
    {
        [SerializeField] protected TargetConfigSO config;

        private int currentHealth;

        public int MaxHealth => config != null ? config.baseHealth : 1;
        public int CurrentHealth => currentHealth;
        public bool IsAlive => currentHealth > 0;

        protected virtual void Awake()
        {
            currentHealth = MaxHealth;
        }

        public void Initialize(float healthMultiplier = 1f)
        {
            currentHealth = Mathf.Max(1, Mathf.RoundToInt(MaxHealth * healthMultiplier));
        }

        public void TakeDamage(int amount)
        {
            if (!IsAlive || amount <= 0) return;

            currentHealth -= amount;
            OnHit();

            if (currentHealth <= 0)
                OnDeath();
        }

        protected virtual void OnHit()
        {
            // Override in subclasses for hit VFX (e.g. pelita flickers, pot wobbles)
        }

        public virtual void OnDeath()
        {
            int scoreValue = config != null ? config.scoreValue : 100;
            GameManager.Instance?.OnTargetDefeated(scoreValue);

            SpawnDeathEffect();
            Destroy(gameObject);
        }

        protected virtual void SpawnDeathEffect()
        {
            // Override to play themed destruction effects:
            // - Pelita: extinguish + smoke puff
            // - Kelapa: tumble/roll away
            // - Belon: pop + confetti
        }
    }
}
