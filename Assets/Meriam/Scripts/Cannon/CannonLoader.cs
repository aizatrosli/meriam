using System;
using Meriam.Interfaces;
using Meriam.ScriptableObjects;
using UnityEngine;

namespace Meriam.Cannon
{
    /// <summary>
    /// Controlled by Player 2 (Anak Bongsu).
    /// Player must hold the load button for cannonLoadDuration seconds to fully
    /// pack the meriam with gunpowder. Releasing early resets progress.
    /// </summary>
    public class CannonLoader : MonoBehaviour, ILoadable
    {
        [SerializeField] private GameConfigSO config;

        private ITimeProvider timeProvider = new UnityTimeProvider();
        private float loadTimer;
        private bool isLoading;

        public bool IsLoaded { get; private set; }
        public float LoadProgress { get; private set; }
        public float LoadDuration => config != null ? config.cannonLoadDuration : 2f;

        public event Action OnLoadComplete;

        // Inject a fake time provider for tests
        public void SetTimeProvider(ITimeProvider provider) => timeProvider = provider;

        public void InitializeForTesting(GameConfigSO testConfig)
        {
            config = testConfig;
            IsLoaded = false;
            LoadProgress = 0f;
            loadTimer = 0f;
            isLoading = false;
        }

        private void Update()
        {
            if (!isLoading || IsLoaded) return;

            loadTimer += timeProvider.DeltaTime;
            LoadProgress = Mathf.Clamp01(loadTimer / LoadDuration);

            if (loadTimer >= LoadDuration)
            {
                IsLoaded = true;
                isLoading = false;
                OnLoadComplete?.Invoke();
            }
        }

        public void BeginLoading()
        {
            if (IsLoaded) return;
            isLoading = true;
        }

        public void CancelLoading()
        {
            isLoading = false;
            loadTimer = 0f;
            LoadProgress = 0f;
            IsLoaded = false;
        }

        public void ForceLoad()
        {
            loadTimer = LoadDuration;
            LoadProgress = 1f;
            IsLoaded = true;
            isLoading = false;
            OnLoadComplete?.Invoke();
        }
    }
}
