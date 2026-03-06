using Meriam.Core;
using TMPro;
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.UI;

namespace Meriam.UI
{
    /// <summary>
    /// Main menu for Meriam Raya.
    /// Shows the game title, high score, and mode selection:
    ///   - Main Tempatan (Local co-op, same device)
    ///   - Main Dalam Talian (Online co-op)
    /// </summary>
    public class MainMenuController : MonoBehaviour
    {
        [Header("Buttons")]
        [SerializeField] private Button mainTempatanButton;   // Local co-op
        [SerializeField] private Button mainDalamTalianButton; // Online co-op

        [Header("Display")]
        [SerializeField] private TextMeshProUGUI highScoreText;
        [SerializeField] private TextMeshProUGUI titleText;

        private void Start()
        {
            mainTempatanButton?.onClick.AddListener(StartLocal);
            mainDalamTalianButton?.onClick.AddListener(StartOnline);

            int highScore = PlayerPrefs.GetInt("MeriamRaya_HighScore", 0);
            if (highScoreText != null)
                highScoreText.text = $"Markah Tertinggi: {highScore}";
        }

        private void StartLocal()
        {
            NetworkMode.IsOnline = false;
            SceneManager.LoadScene("GameScene");
        }

        private void StartOnline()
        {
            NetworkMode.IsOnline = true;
            SceneManager.LoadScene("GameScene");
        }
    }

    /// <summary>Simple static flag to pass the chosen mode between scenes.</summary>
    public static class NetworkMode
    {
        public static bool IsOnline { get; set; }
    }
}
