using System.Collections;
using TMPro;
using UnityEngine;

namespace Meriam.UI
{
    /// <summary>
    /// Full-screen overlay shown between rounds.
    /// Displays bilingual round announcement, e.g.:
    ///   "Pusingan 2 / Round 2"
    ///   "Selamat Raya! Meriam siap?" / "Happy Raya! Ready the cannon?"
    /// </summary>
    public class RoundAnnouncementUI : MonoBehaviour
    {
        [SerializeField] private GameObject panel;
        [SerializeField] private TextMeshProUGUI roundText;
        [SerializeField] private TextMeshProUGUI subtitleText;
        [SerializeField] private float displayDuration = 2.5f;

        private void Awake()
        {
            panel?.SetActive(false);
        }

        public void ShowRoundAnnouncement(int roundNumber, string malayText)
        {
            if (roundText != null)
                roundText.text = $"Pusingan {roundNumber} / Round {roundNumber}";

            if (subtitleText != null)
                subtitleText.text = string.IsNullOrEmpty(malayText)
                    ? "Meriam siap! / Ready the cannon!"
                    : malayText;

            StartCoroutine(ShowThenHide());
        }

        private IEnumerator ShowThenHide()
        {
            panel?.SetActive(true);
            yield return new WaitForSeconds(displayDuration);
            panel?.SetActive(false);
        }
    }
}
