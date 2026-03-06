using System.Collections;
using Meriam.ScriptableObjects;
using Meriam.Targets;
using NUnit.Framework;
using UnityEngine;
using UnityEngine.TestTools;

namespace Meriam.Tests.PlayMode
{
    /// <summary>
    /// Integration tests for the round/target spawning system.
    /// Verifies that the correct number and type of Raya targets
    /// (pelita, kelapa, belon) appear in the kampung yard.
    /// </summary>
    public class RoundSpawnIntegrationTests
    {
        private GameObject spawnerGO;

        [UnitySetUp]
        public IEnumerator SetUp()
        {
            spawnerGO = new GameObject("TestSpawner");
            yield return null;
        }

        [UnityTearDown]
        public IEnumerator TearDown()
        {
            if (spawnerGO != null) Object.Destroy(spawnerGO);

            // Destroy any spawned targets
            foreach (var t in Object.FindObjectsOfType<TargetBase>())
                Object.Destroy(t.gameObject);

            yield return null;
        }

        private TargetConfigSO CreateTargetConfig(string id, string name, int health = 1)
        {
            var config = ScriptableObject.CreateInstance<TargetConfigSO>();
            config.targetId = id;
            config.displayNameMalay = name;
            config.baseHealth = health;
            config.scoreValue = 100;

            // Minimal prefab with TargetPelita
            var prefab = new GameObject(name);
            prefab.AddComponent<CircleCollider2D>().isTrigger = true;
            prefab.AddComponent<Rigidbody2D>().isKinematic = true;
            prefab.AddComponent<TargetPelita>();
            config.prefab = prefab;

            return config;
        }

        [UnityTest]
        public IEnumerator Spawner_CreatesCorrectNumberOfTargets()
        {
            var spawner = spawnerGO.AddComponent<TargetSpawner>();

            var targetConfig = CreateTargetConfig("pelita", "Pelita");
            var roundConfig = ScriptableObject.CreateInstance<RoundConfigSO>();
            roundConfig.timeBetweenSpawns = 0.05f;
            roundConfig.roundStartDelay = 0f;
            roundConfig.targets = new TargetSpawnEntry[]
            {
                new TargetSpawnEntry { config = targetConfig, count = 3, spacing = 1.5f }
            };

            spawner.SpawnRound(roundConfig);

            // Wait for all 3 to spawn (3 * 0.05s + buffer)
            yield return new WaitForSeconds(0.3f);

            var spawnedTargets = Object.FindObjectsOfType<TargetBase>();
            Assert.AreEqual(3, spawnedTargets.Length,
                "Expected 3 pelita targets to be spawned in the kampung yard.");

            Object.Destroy(targetConfig.prefab);
        }

        [UnityTest]
        public IEnumerator Spawner_WithMixedTargets_SpawnsCorrectTotal()
        {
            var spawner = spawnerGO.AddComponent<TargetSpawner>();

            var pelitaConfig = CreateTargetConfig("pelita", "Pelita");
            var kelapaConfig = CreateTargetConfig("kelapa", "Kelapa");

            var roundConfig = ScriptableObject.CreateInstance<RoundConfigSO>();
            roundConfig.timeBetweenSpawns = 0.05f;
            roundConfig.roundStartDelay = 0f;
            roundConfig.targets = new TargetSpawnEntry[]
            {
                new TargetSpawnEntry { config = pelitaConfig, count = 2, spacing = 1.5f },
                new TargetSpawnEntry { config = kelapaConfig, count = 3, spacing = 1.5f },
            };

            spawner.SpawnRound(roundConfig);

            yield return new WaitForSeconds(0.5f);

            var spawnedTargets = Object.FindObjectsOfType<TargetBase>();
            Assert.AreEqual(5, spawnedTargets.Length,
                "Expected 5 targets total (2 pelita + 3 kelapa).");

            Object.Destroy(pelitaConfig.prefab);
            Object.Destroy(kelapaConfig.prefab);
        }
    }
}
