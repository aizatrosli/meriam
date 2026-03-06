using System;
using UnityEngine;

namespace Meriam.Core
{
    /// <summary>
    /// Simple enum-driven state machine for the Meriam Raya game flow.
    /// </summary>
    public enum GameState
    {
        MainMenu,
        RoundCountdown,
        Playing,
        Paused,
        RoundComplete,
        GameOver,
        Victory,
    }

    public class GameStateMachine
    {
        public GameState CurrentState { get; private set; } = GameState.MainMenu;

        /// <summary>Fired when a valid transition occurs. Args: (fromState, toState)</summary>
        public event Action<GameState, GameState> OnStateChanged;

        public void TransitionTo(GameState newState)
        {
            if (newState == CurrentState)
                return;

            if (!IsValidTransition(CurrentState, newState))
            {
                Debug.LogWarning($"[GameStateMachine] Invalid transition: {CurrentState} -> {newState}");
                return;
            }

            var previous = CurrentState;
            CurrentState = newState;
            OnStateChanged?.Invoke(previous, newState);
        }

        private static bool IsValidTransition(GameState from, GameState to)
        {
            return (from, to) switch
            {
                (GameState.MainMenu,       GameState.RoundCountdown) => true,
                (GameState.RoundCountdown, GameState.Playing)        => true,
                (GameState.Playing,        GameState.Paused)         => true,
                (GameState.Playing,        GameState.RoundComplete)  => true,
                (GameState.Playing,        GameState.GameOver)       => true,
                (GameState.Paused,         GameState.Playing)        => true,
                (GameState.Paused,         GameState.MainMenu)       => true,
                (GameState.RoundComplete,  GameState.RoundCountdown) => true,
                (GameState.RoundComplete,  GameState.Victory)        => true,
                (GameState.GameOver,       GameState.MainMenu)       => true,
                (GameState.Victory,        GameState.MainMenu)       => true,
                _                                                    => false,
            };
        }
    }
}
