using Meriam.Events;
using Meriam.ScriptableObjects;
using UnityEngine;

namespace Meriam.Core
{
    /// <summary>
    /// Top-level singleton that wires subsystems together for the Meriam Raya game.
    /// Scene: kampung yard at night, Ramadan / Raya celebration.
    /// Two kids co-operate: Anak Sulung (Player 1) aims, Anak Bongsu (Player 2) loads and fires.
    /// </summary>
    public class GameManager : MonoBehaviour
    {
        public static GameManager Instance { get; private set; }

        [Header("Configuration")]
        [SerializeField] private GameConfigSO gameConfig;

        [Header("Event Bus")]
        [SerializeField] private GameEventSO onTargetHit;
        [SerializeField] private GameEventSO onRoundComplete;
        [SerializeField] private GameEventSO onGameOver;

        [Header("Subsystems")]
        [SerializeField] private RoundManager roundManager;

        public ScoreManager ScoreManager { get; private set; }
        public LivesManager LivesManager { get; private set; }
        public GameStateMachine StateMachine { get; private set; }

        private void Awake()
        {
            if (Instance != null && Instance != this)
            {
                Destroy(gameObject);
                return;
            }
            Instance = this;

            ScoreManager = new ScoreManager();
            LivesManager = new LivesManager();
            StateMachine = new GameStateMachine();
        }

        private void Start()
        {
            LivesManager.Initialize(gameConfig.startingLives);
            LivesManager.OnGameOver += HandleGameOver;

            roundManager.OnAllRoundsComplete += HandleVictory;
            roundManager.OnRoundComplete += HandleRoundComplete;
        }

        public void StartGame()
        {
            ScoreManager.ResetScore();
            LivesManager.Initialize(gameConfig.startingLives);
            StateMachine.TransitionTo(GameState.RoundCountdown);
            roundManager.StartRound(0);
        }

        public void OnTargetDefeated(int scoreValue)
        {
            ScoreManager.AddScore(scoreValue);
            roundManager.RegisterTargetDefeated();
            onTargetHit?.Raise(scoreValue);
        }

        public void OnProjectileMissed()
        {
            LivesManager.LoseLife();
        }

        private void HandleRoundComplete(int roundNumber)
        {
            StateMachine.TransitionTo(GameState.RoundComplete);
            onRoundComplete?.Raise(roundNumber);

            if (!roundManager.IsLastRound)
            {
                StateMachine.TransitionTo(GameState.RoundCountdown);
                roundManager.AdvanceRound();
            }
        }

        private void HandleVictory()
        {
            StateMachine.TransitionTo(GameState.Victory);
        }

        private void HandleGameOver()
        {
            StateMachine.TransitionTo(GameState.GameOver);
            onGameOver?.Raise(ScoreManager.GetCurrentScore());
        }
    }
}
