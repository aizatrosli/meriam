using System;
using System.Collections;
using Meriam.Interfaces;
using Meriam.ScriptableObjects;
using UnityEngine;

namespace Meriam.Cannon
{
    /// <summary>
    /// Controlled by Player 2 (Anak Bongsu).
    /// When the meriam is loaded, Player 2 presses fire to launch the bola meriam.
    /// Locks the barrel (CannonAimer) during the post-shot cooldown.
    /// Plays a loud BOOM - the signature Raya night sound.
    /// </summary>
    public class CannonFirer : MonoBehaviour, IFirable
    {
        [SerializeField] private CannonAimer aimer;
        [SerializeField] private CannonLoader loader;
        [SerializeField] private Transform muzzlePoint;
        [SerializeField] private GameConfigSO config;
        [SerializeField] private AudioSource audioSource;
        [SerializeField] private AudioClip fireSound;

        public bool CanFire => loader != null && loader.IsLoaded && !aimer.IsLocked;
        public float CooldownDuration => config != null ? config.cannonCooldownDuration : 1.5f;

        public event Action OnFired;
        public event Action OnCooldownComplete;

        public void Fire()
        {
            if (!CanFire) return;

            aimer.IsLocked = true;

            var projectile = Instantiate(
                config.cannonBallPrefab,
                muzzlePoint.position,
                Quaternion.Euler(0f, 0f, aimer.CurrentAngle));

            var proj = projectile.GetComponent<CannonProjectile>();
            if (proj != null)
                proj.Launch(aimer.CurrentAngle, config.projectileSpeed, config.projectileDamage, config.projectileLifetime);

            loader.CancelLoading();

            if (audioSource != null && fireSound != null)
                audioSource.PlayOneShot(fireSound);

            OnFired?.Invoke();
            StartCoroutine(CooldownRoutine());
        }

        private IEnumerator CooldownRoutine()
        {
            yield return new WaitForSeconds(CooldownDuration);
            aimer.IsLocked = false;
            OnCooldownComplete?.Invoke();
        }
    }
}
