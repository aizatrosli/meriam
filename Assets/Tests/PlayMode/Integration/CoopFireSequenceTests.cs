using System.Collections;
using Meriam.Cannon;
using Meriam.ScriptableObjects;
using NUnit.Framework;
using UnityEngine;
using UnityEngine.TestTools;

namespace Meriam.Tests.PlayMode
{
    /// <summary>
    /// Integration tests for the cooperative firing sequence:
    ///   Player 1 (Anak Sulung) aims -> Player 2 (Anak Bongsu) loads -> fires.
    /// </summary>
    public class CoopFireSequenceTests
    {
        private GameObject cannonGO;
        private CannonAimer aimer;
        private CannonLoader loader;
        private CannonFirer firer;
        private GameConfigSO config;

        [UnitySetUp]
        public IEnumerator SetUp()
        {
            config = ScriptableObject.CreateInstance<GameConfigSO>();
            config.minAimAngle = 0f;
            config.maxAimAngle = 75f;
            config.cannonAimSpeed = 90f;
            config.cannonLoadDuration = 0.2f;   // short for fast tests
            config.cannonCooldownDuration = 0.3f;
            config.projectileSpeed = 15f;
            config.projectileLifetime = 5f;
            config.projectileDamage = 1;

            // Create a simple cannonball prefab for tests
            var ballPrefab = new GameObject("TestBall");
            ballPrefab.AddComponent<Rigidbody2D>();
            var projComp = ballPrefab.AddComponent<CannonProjectile>();
            ballPrefab.AddComponent<CircleCollider2D>().isTrigger = true;
            config.cannonBallPrefab = ballPrefab;

            cannonGO = new GameObject("TestCannon");
            var muzzle = new GameObject("Muzzle");
            muzzle.transform.SetParent(cannonGO.transform);

            aimer = cannonGO.AddComponent<CannonAimer>();
            aimer.InitializeForTesting(config);

            loader = cannonGO.AddComponent<CannonLoader>();
            loader.InitializeForTesting(config);

            firer = cannonGO.AddComponent<CannonFirer>();

            yield return null; // wait one frame for Start()
        }

        [UnityTearDown]
        public IEnumerator TearDown()
        {
            if (cannonGO != null) Object.Destroy(cannonGO);
            if (config != null) Object.Destroy(config);
            // Clean up any stray projectiles
            foreach (var proj in Object.FindObjectsOfType<CannonProjectile>())
                Object.Destroy(proj.gameObject);
            yield return null;
        }

        [UnityTest]
        public IEnumerator FullCoopSequence_AimThenLoadThenFire_SpawnsProjectile()
        {
            // Player 1 aims
            aimer.SetAimAngle(45f);
            Assert.AreEqual(45f, aimer.CurrentAngle, 0.1f);
            yield return null;

            // Player 2 loads (force for test speed)
            loader.ForceLoad();
            Assert.IsTrue(loader.IsLoaded);
            yield return null;

            // Player 2 fires
            int before = Object.FindObjectsOfType<CannonProjectile>().Length;
            firer.Fire();
            yield return null;
            int after = Object.FindObjectsOfType<CannonProjectile>().Length;

            Assert.AreEqual(before + 1, after, "Expected one new projectile after firing.");
        }

        [UnityTest]
        public IEnumerator Fire_WithoutLoading_SpawnsNoProjectile()
        {
            Assert.IsFalse(loader.IsLoaded);

            int before = Object.FindObjectsOfType<CannonProjectile>().Length;
            firer.Fire();
            yield return null;
            int after = Object.FindObjectsOfType<CannonProjectile>().Length;

            Assert.AreEqual(before, after, "No projectile should spawn when meriam is not loaded.");
        }

        [UnityTest]
        public IEnumerator AfterFiring_AimerIsLockedDuringCooldown()
        {
            loader.ForceLoad();
            firer.Fire();
            yield return null;

            Assert.IsTrue(aimer.IsLocked, "Aimer should be locked immediately after firing.");
        }

        [UnityTest]
        public IEnumerator AfterCooldown_AimerIsUnlocked()
        {
            loader.ForceLoad();
            firer.Fire();

            yield return new WaitForSeconds(config.cannonCooldownDuration + 0.1f);

            Assert.IsFalse(aimer.IsLocked, "Aimer should be unlocked after cooldown.");
        }

        [UnityTest]
        public IEnumerator AfterFiring_LoaderResets_RequiresReload()
        {
            loader.ForceLoad();
            firer.Fire();
            yield return null;

            Assert.IsFalse(loader.IsLoaded, "Loader should reset after firing.");
        }

        [UnityTest]
        public IEnumerator AimClamp_CannotExceedMaxAngle()
        {
            aimer.SetAimAngle(999f);
            yield return null;
            Assert.AreEqual(config.maxAimAngle, aimer.CurrentAngle, 0.1f);
        }

        [UnityTest]
        public IEnumerator Loading_HoldAndRelease_ResetsProgress()
        {
            loader.BeginLoading();
            yield return new WaitForSeconds(0.05f); // partial load
            loader.CancelLoading();
            yield return null;

            Assert.IsFalse(loader.IsLoaded);
            Assert.AreEqual(0f, loader.LoadProgress, 0.01f);
        }
    }
}
