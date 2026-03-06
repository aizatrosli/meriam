using UnityEngine;
using UnityEngine.UI;

namespace Meriam.Cannon
{
    /// <summary>
    /// Visual feedback showing Player 2 how full the loading progress is.
    /// Displayed as a progress bar above the meriam in the kampung scene.
    /// </summary>
    public class CannonReloadIndicator : MonoBehaviour
    {
        [SerializeField] private CannonLoader loader;
        [SerializeField] private Image fillBar;
        [SerializeField] private GameObject loadedIcon;

        private void Update()
        {
            if (loader == null) return;

            if (fillBar != null)
                fillBar.fillAmount = loader.LoadProgress;

            if (loadedIcon != null)
                loadedIcon.SetActive(loader.IsLoaded);
        }
    }
}
