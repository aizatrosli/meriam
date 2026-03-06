using Meriam.Cannon;
using Meriam.ScriptableObjects;
using UnityEngine;
using UnityEngine.InputSystem;

namespace Meriam.Players
{
    /// <summary>
    /// Routes raw Unity Input System actions to Player1Controller and Player2Controller.
    /// Supports two local input schemes:
    ///   - Keyboard split: Player 1 W/S, Player 2 Space (hold) + Enter (fire)
    ///   - Two gamepads: Player 1 Gamepad 1 left-stick Y, Player 2 Gamepad 2 South + East
    /// In networked mode this class is only active on the local client.
    /// </summary>
    public class PlayerInputRouter : MonoBehaviour
    {
        [SerializeField] private Player1Controller player1;
        [SerializeField] private Player2Controller player2;
        [SerializeField] private GameConfigSO config;

        private PlayerInput player1Input;
        private PlayerInput player2Input;

        private void Awake()
        {
            var inputs = GetComponentsInChildren<PlayerInput>();
            foreach (var pi in inputs)
            {
                if (pi.playerIndex == 0) player1Input = pi;
                else if (pi.playerIndex == 1) player2Input = pi;
            }
        }

        private void OnEnable()
        {
            if (player1Input != null)
            {
                player1Input.actions["Aim"].performed += OnAim;
                player1Input.actions["Aim"].canceled += OnAimCanceled;
            }

            if (player2Input != null)
            {
                player2Input.actions["Load"].started += OnLoadStarted;
                player2Input.actions["Load"].canceled += OnLoadCanceled;
                player2Input.actions["Fire"].performed += OnFire;
            }
        }

        private void OnDisable()
        {
            if (player1Input != null)
            {
                player1Input.actions["Aim"].performed -= OnAim;
                player1Input.actions["Aim"].canceled -= OnAimCanceled;
            }

            if (player2Input != null)
            {
                player2Input.actions["Load"].started -= OnLoadStarted;
                player2Input.actions["Load"].canceled -= OnLoadCanceled;
                player2Input.actions["Fire"].performed -= OnFire;
            }
        }

        private void Update()
        {
            // Continuous aim input per frame (analog stick / key held)
            if (player1Input != null)
            {
                float aimValue = player1Input.actions["Aim"].ReadValue<float>();
                if (Mathf.Abs(aimValue) > 0.05f)
                    player1?.OnAimInput(aimValue * config.cannonAimSpeed * Time.deltaTime);
            }
        }

        private void OnAim(InputAction.CallbackContext ctx) { }
        private void OnAimCanceled(InputAction.CallbackContext ctx) { }
        private void OnLoadStarted(InputAction.CallbackContext ctx) => player2?.OnLoadPressed();
        private void OnLoadCanceled(InputAction.CallbackContext ctx) => player2?.OnLoadReleased();
        private void OnFire(InputAction.CallbackContext ctx) => player2?.OnFirePressed();
    }
}
