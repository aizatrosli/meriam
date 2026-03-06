using System;
using System.Threading.Tasks;
using Unity.Services.Authentication;
using Unity.Services.Core;
using Unity.Services.Lobby;
using Unity.Services.Lobby.Models;
using Unity.Services.Relay;
using Unity.Services.Relay.Models;
using UnityEngine;

namespace Meriam.Network
{
    /// <summary>
    /// Manages Unity Gaming Services Lobby + Relay for online co-op.
    /// Two kids in different houses connect via a join code (no dedicated server).
    ///
    /// Flow:
    ///   Host  -> CreateLobby() -> CreateRelayAllocation() -> share JoinCode
    ///   Guest -> JoinWithCode(code) -> JoinRelay()
    ///   Both  -> NetworkManager.StartHost() / StartClient()
    /// </summary>
    public class LobbyManager : MonoBehaviour
    {
        public string CurrentJoinCode { get; private set; }
        public bool IsHost { get; private set; }

        public event Action<string> OnJoinCodeReady;
        public event Action OnJoined;
        public event Action<string> OnError;

        private Lobby currentLobby;

        private async void Start()
        {
            try
            {
                await UnityServices.InitializeAsync();
                if (!AuthenticationService.Instance.IsSignedIn)
                    await AuthenticationService.Instance.SignInAnonymouslyAsync();
            }
            catch (Exception e)
            {
                OnError?.Invoke(e.Message);
            }
        }

        public async Task CreateLobby()
        {
            try
            {
                IsHost = true;
                var allocation = await RelayService.Instance.CreateAllocationAsync(maxConnections: 1);
                CurrentJoinCode = await RelayService.Instance.GetJoinCodeAsync(allocation.AllocationId);

                var options = new CreateLobbyOptions
                {
                    Data = new System.Collections.Generic.Dictionary<string, DataObject>
                    {
                        { "RelayCode", new DataObject(DataObject.VisibilityOptions.Public, CurrentJoinCode) }
                    }
                };

                currentLobby = await LobbyService.Instance.CreateLobbyAsync("MeriamRaya", maxPlayers: 2, options);
                OnJoinCodeReady?.Invoke(CurrentJoinCode);
                Debug.Log($"[LobbyManager] Lobby created. Join code: {CurrentJoinCode}");
            }
            catch (Exception e)
            {
                OnError?.Invoke(e.Message);
            }
        }

        public async Task JoinWithCode(string joinCode)
        {
            try
            {
                IsHost = false;
                CurrentJoinCode = joinCode;

                var joinAllocation = await RelayService.Instance.JoinAllocationAsync(joinCode);
                currentLobby = await LobbyService.Instance.JoinLobbyByIdAsync(currentLobby?.Id ?? "");

                OnJoined?.Invoke();
                Debug.Log($"[LobbyManager] Joined lobby with code: {joinCode}");
            }
            catch (Exception e)
            {
                OnError?.Invoke(e.Message);
            }
        }

        private async void OnDestroy()
        {
            if (currentLobby != null && IsHost)
            {
                try { await LobbyService.Instance.DeleteLobbyAsync(currentLobby.Id); }
                catch { /* ignore on destroy */ }
            }
        }
    }
}
