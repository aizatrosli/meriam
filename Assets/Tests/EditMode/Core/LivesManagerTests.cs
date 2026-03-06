using Meriam.Core;
using NUnit.Framework;

namespace Meriam.Tests.EditMode
{
    [TestFixture]
    public class LivesManagerTests
    {
        private LivesManager livesManager;

        [SetUp]
        public void SetUp()
        {
            livesManager = new LivesManager();
            livesManager.Initialize(3);
        }

        [Test]
        public void Initialize_SetsLivesToStartingCount()
        {
            Assert.AreEqual(3, livesManager.LivesRemaining);
        }

        [Test]
        public void LoseLife_DecrementsLives()
        {
            livesManager.LoseLife();
            Assert.AreEqual(2, livesManager.LivesRemaining);
        }

        [Test]
        public void IsGameOver_FalseWhenLivesAboveZero()
        {
            Assert.IsFalse(livesManager.IsGameOver);
        }

        [Test]
        public void IsGameOver_TrueWhenLivesReachZero()
        {
            livesManager.LoseLife();
            livesManager.LoseLife();
            livesManager.LoseLife();
            Assert.IsTrue(livesManager.IsGameOver);
        }

        [Test]
        public void LoseLife_DoesNotGoBelowZero()
        {
            livesManager.LoseLife();
            livesManager.LoseLife();
            livesManager.LoseLife();
            livesManager.LoseLife(); // extra call after game over
            Assert.AreEqual(0, livesManager.LivesRemaining);
        }

        [Test]
        public void LoseLife_FiresOnLifeLostEvent()
        {
            bool fired = false;
            livesManager.OnLifeLost += () => fired = true;
            livesManager.LoseLife();
            Assert.IsTrue(fired);
        }

        [Test]
        public void LoseLife_FiresOnGameOverWhenLastLife()
        {
            bool gameOverFired = false;
            livesManager.OnGameOver += () => gameOverFired = true;
            livesManager.LoseLife();
            livesManager.LoseLife();
            livesManager.LoseLife();
            Assert.IsTrue(gameOverFired);
        }

        [Test]
        public void LoseLife_DoesNotFireGameOverBeforeLastLife()
        {
            bool gameOverFired = false;
            livesManager.OnGameOver += () => gameOverFired = true;
            livesManager.LoseLife();
            Assert.IsFalse(gameOverFired);
        }
    }
}
