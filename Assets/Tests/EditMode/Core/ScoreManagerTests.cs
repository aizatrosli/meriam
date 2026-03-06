using Meriam.Core;
using NUnit.Framework;

namespace Meriam.Tests.EditMode
{
    [TestFixture]
    public class ScoreManagerTests
    {
        private ScoreManager scoreManager;

        [SetUp]
        public void SetUp()
        {
            scoreManager = new ScoreManager();
        }

        [Test]
        public void AddScore_IncreasesCurrentScore()
        {
            scoreManager.AddScore(100);
            Assert.AreEqual(100, scoreManager.GetCurrentScore());
        }

        [Test]
        public void AddScore_NegativeValue_DoesNotChangeScore()
        {
            scoreManager.AddScore(50);
            scoreManager.AddScore(-10);
            Assert.AreEqual(50, scoreManager.GetCurrentScore());
        }

        [Test]
        public void AddScore_ZeroValue_DoesNotChangeScore()
        {
            scoreManager.AddScore(200);
            scoreManager.AddScore(0);
            Assert.AreEqual(200, scoreManager.GetCurrentScore());
        }

        [Test]
        public void ResetScore_SetsScoreToZero()
        {
            scoreManager.AddScore(500);
            scoreManager.ResetScore();
            Assert.AreEqual(0, scoreManager.GetCurrentScore());
        }

        [Test]
        public void AddScore_FiresOnScoreChangedEvent()
        {
            int firedValue = -1;
            scoreManager.OnScoreChanged += v => firedValue = v;
            scoreManager.AddScore(200);
            Assert.AreEqual(200, firedValue);
        }

        [Test]
        public void ResetScore_FiresOnScoreChangedEventWithZero()
        {
            int firedValue = -1;
            scoreManager.AddScore(100);
            scoreManager.OnScoreChanged += v => firedValue = v;
            scoreManager.ResetScore();
            Assert.AreEqual(0, firedValue);
        }

        [Test]
        public void AddScore_MultipleTimes_AccumulatesCorrectly()
        {
            scoreManager.AddScore(100);
            scoreManager.AddScore(250);
            scoreManager.AddScore(50);
            Assert.AreEqual(400, scoreManager.GetCurrentScore());
        }
    }
}
