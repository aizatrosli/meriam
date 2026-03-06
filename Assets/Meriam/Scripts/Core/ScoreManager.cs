using System;
using UnityEngine;

namespace Meriam.Core
{
    /// <summary>
    /// Pure C# class (no MonoBehaviour) for score accounting.
    /// Easily unit-tested in EditMode without a scene.
    /// </summary>
    public class ScoreManager
    {
        private const string HighScoreKey = "MeriamRaya_HighScore";

        public int CurrentScore { get; private set; }

        public event Action<int> OnScoreChanged;

        public int GetCurrentScore() => CurrentScore;

        public int GetHighScore() => PlayerPrefs.GetInt(HighScoreKey, 0);

        public void AddScore(int points)
        {
            if (points <= 0)
                return;

            CurrentScore += points;

            if (CurrentScore > GetHighScore())
                PlayerPrefs.SetInt(HighScoreKey, CurrentScore);

            OnScoreChanged?.Invoke(CurrentScore);
        }

        public void ResetScore()
        {
            CurrentScore = 0;
            OnScoreChanged?.Invoke(CurrentScore);
        }
    }
}
