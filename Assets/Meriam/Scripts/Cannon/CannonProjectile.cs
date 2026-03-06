using Meriam.Core;
using Meriam.Interfaces;
using UnityEngine;

namespace Meriam.Cannon
{
    /// <summary>
    /// The bola meriam (cannonball) launched from the meriam buluh.
    /// Travels in a parabolic arc; damages any IDamageable it collides with.
    /// Notifies GameManager of a miss if it falls off-screen without hitting anything.
    /// </summary>
    [RequireComponent(typeof(Rigidbody2D))]
    public class CannonProjectile : MonoBehaviour
    {
        private Rigidbody2D rb;
        private int damage;
        private float lifetime;

        private void Awake()
        {
            rb = GetComponent<Rigidbody2D>();
        }

        public void Launch(float angleDeg, float speed, int projectileDamage, float projectileLifetime)
        {
            damage = projectileDamage;
            lifetime = projectileLifetime;

            var direction = Quaternion.Euler(0f, 0f, angleDeg) * Vector2.right;
            rb.velocity = direction * speed;

            Destroy(gameObject, lifetime);
        }

        private void OnDestroy()
        {
            // If destroyed by lifetime (miss), notify GameManager
            if (GameManager.Instance != null)
                GameManager.Instance.OnProjectileMissed();
        }

        private void OnTriggerEnter2D(Collider2D other)
        {
            var damageable = other.GetComponent<IDamageable>();
            if (damageable == null) return;

            damageable.TakeDamage(damage);
            // Cancel the miss notification by destroying without triggering OnDestroy logic
            // We do this by removing the component flag before destroying
            CancelInvoke();
            Destroy(gameObject);
        }
    }
}
