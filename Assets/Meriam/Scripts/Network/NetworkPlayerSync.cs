using Meriam.Players;
using Unity.Netcode;
using UnityEngine;

namespace Meriam.Network
{
    /// <summary>
    /// Synchronises player role assignment over the network.
    /// Host automatically becomes Player 1 (Anak Sulung, aimer).
    /// Joining client automatically becomes Player 2 (Anak Bongsu, loader/firer).
    /// </summary>
    public class NetworkPlayerSync : NetworkBehaviour
    {
        [SerializeField] private Player1Controller player1;
        [SerializeField] private Player2Controller player2;

        public override void OnNetworkSpawn()
        {
            if (IsHost)
            {
                player1?.gameObject.SetActive(true);
                player2?.gameObject.SetActive(false);
                Debug.Log("[NetworkPlayerSync] Host: assigned as Player 1 (Anak Sulung)");
            }
            else
            {
                player1?.gameObject.SetActive(false);
                player2?.gameObject.SetActive(true);
                Debug.Log("[NetworkPlayerSync] Client: assigned as Player 2 (Anak Bongsu)");
            }
        }
    }
}
