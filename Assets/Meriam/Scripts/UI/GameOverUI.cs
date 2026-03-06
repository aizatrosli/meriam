using TMPro;
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.UI;

namespace Meriam.UI
{
    /// <summary>
    /// Game over and victory screen for Meriam Raya.
    /// Shows final score (Markah Akhir) and prompts kids to play again (Main Semula).
    /// </summary>
    public class GameOverUI : MonoBehaviour
    {
        [SerializeField] private GameObject gameOverPanel;
        [SerializeField] private GameObject victoryPanel;
        [SerializeField] private TextMeshProUGUI finalScoreText;
        [SerializeField] private TextMeshProUGUI highScoreText;
        [SerializeField] private Button mainSemula;   // Play again
        [SerializeField] private Button balikMenu;    // Back to main menu

        private void Start()
        {
            gameOverPanel?.SetActive(false);
            victoryPanel?.SetActive(false);
            mainSemula?.onClick.AddListener(() => SceneManager.LoadScene("GameScene"));
            balikMenu?.onClick.AddListener(() => SceneManager.LoadScene("MainMenu"));
        }

        public void ShowGameOver(object scoreData)
        {
            int score = scoreData is int s ? s : 0;
            gameOverPanel?.SetActive(true);

            if (finalScoreText != null)
                finalScoreText.text = $"Markah Akhir: {score}";

            int high = PlayerPrefs.GetInt("MeriamRaya_HighScore", 0);
            if (highScoreText != null)
                highScoreText.text = $"Tertinggi: {high}";
        }

        public void ShowVictory(int score)
        {
            victoryPanel?.SetActive(true);

            if (finalScoreText != null)
                finalScoreText.text = $"Tahniah! Markah: {score}";
        }
    }
}
