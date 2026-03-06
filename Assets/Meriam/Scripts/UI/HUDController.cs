using Meriam.Core;
using TMPro;
using UnityEngine;
using UnityEngine.UI;

namespace Meriam.UI
{
    /// <summary>
    /// Heads-up display for the Meriam Raya game.
    /// Shows score (Markah), lives remaining (Nyawa), round number (Pusingan),
    /// and Player 2's load progress bar.
    /// Text is bilingual Malay / English.
    /// </summary>
    public class HUDController : MonoBehaviour
    {
        [Header("Score")]
        [SerializeField] private TextMeshProUGUI markahText;  // "Markah: 0"

        [Header("Lives")]
        [SerializeField] private TextMeshProUGUI nyawaText;   // "Nyawa: 3"
        [SerializeField] private Image[] lifeIcons;

        [Header("Round")]
        [SerializeField] private TextMeshProUGUI pusinganText; // "Pusingan 1 / Round 1"

        [Header("Load Progress")]
        [SerializeField] private Image loadProgressBar;
        [SerializeField] private TextMeshProUGUI loadStatusText;

        private GameManager gameManager;

        private void Start()
        {
            gameManager = GameManager.Instance;
            if (gameManager == null) return;

            gameManager.ScoreManager.OnScoreChanged += UpdateScore;
            gameManager.LivesManager.OnLifeLost += UpdateLives;
        }

        private void OnDestroy()
        {
            if (gameManager == null) return;
            gameManager.ScoreManager.OnScoreChanged -= UpdateScore;
            gameManager.LivesManager.OnLifeLost -= UpdateLives;
        }

        private void UpdateScore(int score)
        {
            if (markahText != null)
                markahText.text = $"Markah: {score}";
        }

        private void UpdateLives()
        {
            int lives = gameManager.LivesManager.LivesRemaining;
            if (nyawaText != null)
                nyawaText.text = $"Nyawa: {lives}";

            for (int i = 0; i < lifeIcons.Length; i++)
                lifeIcons[i].enabled = i < lives;
        }

        public void UpdateRound(int roundNumber)
        {
            if (pusinganText != null)
                pusinganText.text = $"Pusingan {roundNumber} / Round {roundNumber}";
        }

        private void Update()
        {
            // Continuously poll load progress for smooth bar
            // In a larger project this would be event-driven
            if (loadProgressBar == null) return;

            var cannon = FindObjectOfType<Meriam.Cannon.CannonLoader>();
            if (cannon == null) return;

            loadProgressBar.fillAmount = cannon.LoadProgress;

            if (loadStatusText != null)
                loadStatusText.text = cannon.IsLoaded ? "Sedia!" : "Isi...";
        }
    }
}
