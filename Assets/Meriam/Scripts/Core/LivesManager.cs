using System;

namespace Meriam.Core
{
    /// <summary>
    /// Pure C# class tracking the kids' remaining shots / lives.
    /// When lives hit zero the game is over.
    /// </summary>
    public class LivesManager
    {
        public int LivesRemaining { get; private set; }
        public bool IsGameOver => LivesRemaining <= 0;

        public event Action OnLifeLost;
        public event Action OnGameOver;

        public void Initialize(int startingLives)
        {
            LivesRemaining = startingLives;
        }

        public void LoseLife()
        {
            if (IsGameOver)
                return;

            LivesRemaining--;
            OnLifeLost?.Invoke();

            if (IsGameOver)
                OnGameOver?.Invoke();
        }
    }
}
