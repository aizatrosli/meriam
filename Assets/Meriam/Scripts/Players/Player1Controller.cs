using Meriam.Cannon;
using UnityEngine;

namespace Meriam.Players
{
    /// <summary>
    /// Anak Sulung (Elder Child) - controls aiming the meriam barrel.
    /// Receives processed aim deltas from PlayerInputRouter.
    /// </summary>
    public class Player1Controller : MonoBehaviour
    {
        [SerializeField] private CannonAimer aimer;

        public void OnAimInput(float deltaAngle)
        {
            aimer?.AdjustAim(deltaAngle);
        }
    }
}
