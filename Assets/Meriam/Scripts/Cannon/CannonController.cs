using UnityEngine;

namespace Meriam.Cannon
{
    /// <summary>
    /// Root component on the Meriam prefab.
    /// Provides a single access point to the cannon sub-components.
    /// Placed on a kampung yard prop representing the kids' meriam buluh.
    /// </summary>
    public class CannonController : MonoBehaviour
    {
        [SerializeField] private CannonAimer aimer;
        [SerializeField] private CannonLoader loader;
        [SerializeField] private CannonFirer firer;
        [SerializeField] private CannonReloadIndicator reloadIndicator;

        public CannonAimer Aimer => aimer;
        public CannonLoader Loader => loader;
        public CannonFirer Firer => firer;
        public CannonReloadIndicator ReloadIndicator => reloadIndicator;
    }
}
