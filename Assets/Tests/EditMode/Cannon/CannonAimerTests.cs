using Meriam.Cannon;
using Meriam.ScriptableObjects;
using NUnit.Framework;
using UnityEngine;

namespace Meriam.Tests.EditMode
{
    [TestFixture]
    public class CannonAimerTests
    {
        private GameObject go;
        private CannonAimer aimer;

        [SetUp]
        public void SetUp()
        {
            go = new GameObject("TestCannon");
            aimer = go.AddComponent<CannonAimer>();

            var config = ScriptableObject.CreateInstance<GameConfigSO>();
            config.cannonAimSpeed = 90f;
            config.minAimAngle = 0f;
            config.maxAimAngle = 75f;

            aimer.InitializeForTesting(config);
        }

        [TearDown]
        public void TearDown()
        {
            Object.DestroyImmediate(go);
        }

        [Test]
        public void AdjustAim_IncreasesAngle()
        {
            aimer.AdjustAim(20f);
            Assert.AreEqual(20f, aimer.CurrentAngle, 0.001f);
        }

        [Test]
        public void AdjustAim_ClampsAtMaxAngle()
        {
            aimer.AdjustAim(200f);
            Assert.AreEqual(75f, aimer.CurrentAngle, 0.001f);
        }

        [Test]
        public void AdjustAim_ClampsAtMinAngle()
        {
            aimer.AdjustAim(-50f);
            Assert.AreEqual(0f, aimer.CurrentAngle, 0.001f);
        }

        [Test]
        public void WhenLocked_AdjustAimHasNoEffect()
        {
            aimer.IsLocked = true;
            aimer.AdjustAim(45f);
            Assert.AreEqual(0f, aimer.CurrentAngle, 0.001f);
        }

        [Test]
        public void SetAimAngle_SetsExactAngle()
        {
            aimer.SetAimAngle(30f);
            Assert.AreEqual(30f, aimer.CurrentAngle, 0.001f);
        }

        [Test]
        public void SetAimAngle_ClampsToMaxAngle()
        {
            aimer.SetAimAngle(999f);
            Assert.AreEqual(75f, aimer.CurrentAngle, 0.001f);
        }

        [Test]
        public void SetAimAngle_WhenLocked_HasNoEffect()
        {
            aimer.IsLocked = true;
            aimer.SetAimAngle(45f);
            Assert.AreEqual(0f, aimer.CurrentAngle, 0.001f);
        }

        [Test]
        public void IsLocked_DefaultIsFalse()
        {
            Assert.IsFalse(aimer.IsLocked);
        }

        [Test]
        public void MinAngle_MatchesConfig()
        {
            Assert.AreEqual(0f, aimer.MinAngle, 0.001f);
        }

        [Test]
        public void MaxAngle_MatchesConfig()
        {
            Assert.AreEqual(75f, aimer.MaxAngle, 0.001f);
        }
    }
}
