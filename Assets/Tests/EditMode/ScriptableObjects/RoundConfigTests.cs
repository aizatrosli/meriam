using Meriam.ScriptableObjects;
using NUnit.Framework;
using UnityEngine;

namespace Meriam.Tests.EditMode
{
    [TestFixture]
    public class RoundConfigTests
    {
        private RoundConfigSO roundConfig;

        [SetUp]
        public void SetUp()
        {
            roundConfig = ScriptableObject.CreateInstance<RoundConfigSO>();
            roundConfig.roundNumber = 1;
            roundConfig.timeBetweenSpawns = 1.5f;
            roundConfig.roundStartDelay = 3f;
            roundConfig.completionBonusScore = 500;
            roundConfig.timeLimit = 60f;
            roundConfig.targets = new TargetSpawnEntry[]
            {
                new TargetSpawnEntry { count = 3, spacing = 1.5f },
                new TargetSpawnEntry { count = 2, spacing = 1.5f },
            };
        }

        [TearDown]
        public void TearDown()
        {
            Object.DestroyImmediate(roundConfig);
        }

        [Test]
        public void RoundNumber_IsPositive()
        {
            Assert.Greater(roundConfig.roundNumber, 0);
        }

        [Test]
        public void TimeBetweenSpawns_IsNonNegative()
        {
            Assert.GreaterOrEqual(roundConfig.timeBetweenSpawns, 0f);
        }

        [Test]
        public void TimeLimit_IsPositive()
        {
            Assert.Greater(roundConfig.timeLimit, 0f);
        }

        [Test]
        public void TargetEntries_AllHavePositiveCount()
        {
            foreach (var entry in roundConfig.targets)
                Assert.Greater(entry.count, 0);
        }

        [Test]
        public void CompletionBonusScore_IsNonNegative()
        {
            Assert.GreaterOrEqual(roundConfig.completionBonusScore, 0);
        }

        [Test]
        public void TotalTargetCount_CalculatesCorrectly()
        {
            int total = 0;
            foreach (var entry in roundConfig.targets)
                total += entry.count;
            Assert.AreEqual(5, total);
        }
    }
}
