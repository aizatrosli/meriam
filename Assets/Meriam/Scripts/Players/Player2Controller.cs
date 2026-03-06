using Meriam.Cannon;
using UnityEngine;

namespace Meriam.Players
{
    /// <summary>
    /// Anak Bongsu (Younger Child) - loads and fires the meriam.
    /// Hold Load to pack gunpowder; tap Fire when loaded.
    /// Receives callbacks from PlayerInputRouter.
    /// </summary>
    public class Player2Controller : MonoBehaviour
    {
        [SerializeField] private CannonLoader loader;
        [SerializeField] private CannonFirer firer;

        public void OnLoadPressed()
        {
            loader?.BeginLoading();
        }

        public void OnLoadReleased()
        {
            if (loader != null && !loader.IsLoaded)
                loader.CancelLoading();
        }

        public void OnFirePressed()
        {
            firer?.Fire();
        }
    }
}
