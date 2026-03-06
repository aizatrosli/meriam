using Meriam.Cannon;
using Unity.Netcode;
using UnityEngine;

namespace Meriam.Network
{
    /// <summary>
    /// Server-authoritative network layer for online co-op Meriam Raya.
    /// Host = Anak Sulung (Player 1, aims).
    /// Client = Anak Bongsu (Player 2, loads + fires).
    ///
    /// All game-state changes go through ServerRpc -> ClientRpc to prevent desync.
    /// </summary>
    public class NetworkGameManager : NetworkBehaviour
    {
        [SerializeField] private CannonController cannon;

        // -------------------------------------------------------------------------
        // ServerRpc: called by a client, runs on the server
        // -------------------------------------------------------------------------

        [ServerRpc(RequireOwnership = false)]
        public void FireCannonServerRpc(float angle, ServerRpcParams rpcParams = default)
        {
            Debug.Log($"[NetworkGameManager] Server: Fire at angle {angle:F1} from client {rpcParams.Receive.SenderClientId}");

            // Validate angle on server to prevent cheating
            var aimer = cannon.Aimer;
            if (angle < aimer.MinAngle || angle > aimer.MaxAngle)
            {
                Debug.LogWarning("[NetworkGameManager] Rejected fire: angle out of range.");
                return;
            }

            aimer.SetAimAngle(angle);
            cannon.Firer.Fire();

            NotifyFireClientRpc(angle);
        }

        [ServerRpc(RequireOwnership = false)]
        public void RegisterHitServerRpc(NetworkObjectReference targetRef, int damage, ServerRpcParams rpcParams = default)
        {
            if (!targetRef.TryGet(out NetworkObject netObj)) return;

            var damageable = netObj.GetComponent<Meriam.Interfaces.IDamageable>();
            damageable?.TakeDamage(damage);
        }

        [ServerRpc(RequireOwnership = false)]
        public void AimCannonServerRpc(float angle, ServerRpcParams rpcParams = default)
        {
            cannon.Aimer.SetAimAngle(angle);
            SyncAimClientRpc(angle);
        }

        // -------------------------------------------------------------------------
        // ClientRpc: called by server, runs on all clients
        // -------------------------------------------------------------------------

        [ClientRpc]
        private void NotifyFireClientRpc(float angle)
        {
            Debug.Log($"[NetworkGameManager] Client: cannon fired at {angle:F1}");
        }

        [ClientRpc]
        private void SyncAimClientRpc(float angle)
        {
            if (!IsServer)
                cannon.Aimer.SetAimAngle(angle);
        }

        [ClientRpc]
        public void SyncGameStateClientRpc(int stateIndex)
        {
            var state = (Core.GameState)stateIndex;
            Core.GameManager.Instance?.StateMachine.TransitionTo(state);
        }

        [ClientRpc]
        public void SyncScoreClientRpc(int score, int lives)
        {
            var gm = Core.GameManager.Instance;
            if (gm == null) return;
            // Clients display the server-authoritative score/lives; local managers are read-only on clients
            Debug.Log($"[NetworkGameManager] Synced: score={score}, lives={lives}");
        }
    }
}
