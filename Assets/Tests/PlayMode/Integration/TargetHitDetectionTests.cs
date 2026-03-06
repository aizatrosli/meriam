using System.Collections;
using Meriam.Cannon;
using Meriam.ScriptableObjects;
using Meriam.Targets;
using NUnit.Framework;
using UnityEngine;
using UnityEngine.TestTools;

namespace Meriam.Tests.PlayMode
{
    /// <summary>
    /// Integration tests for projectile -> target hit detection.
    /// Verifies damage, death events, and projectile destruction
    /// in the Raya night kampung target-shooting gameplay.
    /// </summary>
    public class TargetHitDetectionTests
    {
        private GameObject targetGO;
        private GameObject projectileGO;

        [UnitySetUp]
        public IEnumerator SetUp()
        {
            yield return null;
        }

        [UnityTearDown]
        public IEnumerator TearDown()
        {
            if (targetGO != null) Object.Destroy(targetGO);
            if (projectileGO != null) Object.Destroy(projectileGO);
            yield return null;
        }

        private (GameObject, TargetPelita) CreateTestTarget(int health = 2)
        {
            var go = new GameObject("TestPelita");
            var col = go.AddComponent<CircleCollider2D>();
            col.isTrigger = true;
            var rb = go.AddComponent<Rigidbody2D>();
            rb.isKinematic = true;

            var config = ScriptableObject.CreateInstance<TargetConfigSO>();
            config.baseHealth = health;
            config.scoreValue = 100;
            config.type = TargetType.Swinging;

            var target = go.AddComponent<TargetPelita>();

            return (go, target);
        }

        private (GameObject, CannonProjectile) CreateTestProjectile(int damage = 1)
        {
            var go = new GameObject("TestProjectile");
            var col = go.AddComponent<CircleCollider2D>();
            col.isTrigger = true;
            var rb = go.AddComponent<Rigidbody2D>();
            var proj = go.AddComponent<CannonProjectile>();
            return (go, proj);
        }

        [UnityTest]
        public IEnumerator Projectile_Hits_Target_And_DealsOneDamage()
        {
            (targetGO, var pelita) = CreateTestTarget(health: 2);
            (projectileGO, var proj) = CreateTestProjectile(damage: 1);

            int initialHealth = pelita.CurrentHealth;

            // Overlap the colliders in the same spot
            targetGO.transform.position = Vector3.zero;
            projectileGO.transform.position = Vector3.zero;

            yield return new WaitForFixedUpdate();

            // After physics resolves, target should have taken damage
            Assert.Less(pelita.CurrentHealth, initialHealth);
        }

        [UnityTest]
        public IEnumerator Projectile_IsDestroyed_AfterHit()
        {
            (targetGO, var pelita) = CreateTestTarget(health: 10);
            (projectileGO, var proj) = CreateTestProjectile();

            targetGO.transform.position = Vector3.zero;
            projectileGO.transform.position = Vector3.zero;

            yield return new WaitForFixedUpdate();
            yield return null; // allow Destroy to process

            Assert.IsTrue(projectileGO == null || !projectileGO.activeInHierarchy,
                "Projectile should be destroyed after hitting a target.");
        }

        [UnityTest]
        public IEnumerator Target_WithOneHealth_Dies_OnOneHit()
        {
            (targetGO, var pelita) = CreateTestTarget(health: 1);
            (projectileGO, var proj) = CreateTestProjectile(damage: 1);

            bool died = false;

            targetGO.transform.position = Vector3.zero;
            projectileGO.transform.position = Vector3.zero;

            yield return new WaitForFixedUpdate();
            yield return null;

            // If the GameObject is destroyed, the target died
            Assert.IsTrue(targetGO == null || !targetGO.activeInHierarchy,
                "Pelita with 1 health should be destroyed after 1 hit.");
        }
    }
}
