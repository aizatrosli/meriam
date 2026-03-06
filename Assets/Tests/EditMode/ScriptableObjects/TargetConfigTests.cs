using Meriam.ScriptableObjects;
using NUnit.Framework;
using UnityEngine;

namespace Meriam.Tests.EditMode
{
    [TestFixture]
    public class TargetConfigTests
    {
        private TargetConfigSO pelitaConfig;
        private TargetConfigSO kelapaConfig;
        private TargetConfigSO belonConfig;

        [SetUp]
        public void SetUp()
        {
            pelitaConfig = ScriptableObject.CreateInstance<TargetConfigSO>();
            pelitaConfig.targetId = "pelita";
            pelitaConfig.displayNameMalay = "Pelita";
            pelitaConfig.baseHealth = 1;
            pelitaConfig.scoreValue = 100;
            pelitaConfig.type = TargetType.Swinging;
            pelitaConfig.isSwinging = true;

            kelapaConfig = ScriptableObject.CreateInstance<TargetConfigSO>();
            kelapaConfig.targetId = "kelapa";
            kelapaConfig.displayNameMalay = "Kelapa";
            kelapaConfig.baseHealth = 2;
            kelapaConfig.scoreValue = 150;
            kelapaConfig.type = TargetType.Rolling;
            kelapaConfig.isMoving = true;
            kelapaConfig.moveSpeed = 1.5f;

            belonConfig = ScriptableObject.CreateInstance<TargetConfigSO>();
            belonConfig.targetId = "belon";
            belonConfig.displayNameMalay = "Belon";
            belonConfig.baseHealth = 1;
            belonConfig.scoreValue = 300;
            belonConfig.type = TargetType.Floating;
        }

        [TearDown]
        public void TearDown()
        {
            Object.DestroyImmediate(pelitaConfig);
            Object.DestroyImmediate(kelapaConfig);
            Object.DestroyImmediate(belonConfig);
        }

        [Test]
        public void Pelita_HasPositiveHealth()
        {
            Assert.Greater(pelitaConfig.baseHealth, 0);
        }

        [Test]
        public void Pelita_ScoreValueIsPositive()
        {
            Assert.Greater(pelitaConfig.scoreValue, 0);
        }

        [Test]
        public void Pelita_TypeIsSwinging()
        {
            Assert.AreEqual(TargetType.Swinging, pelitaConfig.type);
        }

        [Test]
        public void Kelapa_IsMoving()
        {
            Assert.IsTrue(kelapaConfig.isMoving);
        }

        [Test]
        public void Kelapa_MoveSpeedIsPositive()
        {
            Assert.Greater(kelapaConfig.moveSpeed, 0f);
        }

        [Test]
        public void Belon_ScoreHigherThanPelita()
        {
            Assert.Greater(belonConfig.scoreValue, pelitaConfig.scoreValue);
        }

        [Test]
        public void Belon_TypeIsFloating()
        {
            Assert.AreEqual(TargetType.Floating, belonConfig.type);
        }

        [Test]
        public void AllTargets_HaveNonEmptyDisplayName()
        {
            Assert.IsNotEmpty(pelitaConfig.displayNameMalay);
            Assert.IsNotEmpty(kelapaConfig.displayNameMalay);
            Assert.IsNotEmpty(belonConfig.displayNameMalay);
        }
    }
}
