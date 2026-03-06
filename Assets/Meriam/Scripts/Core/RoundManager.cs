using System;
using System.Collections;
using Meriam.ScriptableObjects;
using Meriam.Targets;
using UnityEngine;

namespace Meriam.Core
{
    /// <summary>
    /// Sequences rounds from GameConfigSO.rounds[].
    /// Drives TargetSpawner with the current RoundConfigSO.
    /// Kampung setting: each round is a new set of targets placed in the yard.
    /// </summary>
    public class RoundManager : MonoBehaviour
    {
        [SerializeField] private GameConfigSO config;
        [SerializeField] private TargetSpawner targetSpawner;

        public int CurrentRoundIndex { get; private set; } = -1;
        public int TargetsRemainingInRound { get; private set; }
        public bool IsLastRound => CurrentRoundIndex >= config.rounds.Length - 1;

        public event Action<int> OnRoundStarted;
        public event Action<int> OnRoundComplete;
        public event Action OnAllRoundsComplete;

        public void StartRound(int roundIndex)
        {
            if (roundIndex < 0 || roundIndex >= config.rounds.Length)
            {
                Debug.LogError($"[RoundManager] Invalid round index: {roundIndex}");
                return;
            }

            CurrentRoundIndex = roundIndex;
            var roundConfig = config.rounds[roundIndex];
            TargetsRemainingInRound = CountTargets(roundConfig);

            StartCoroutine(SpawnRoutine(roundConfig));
            OnRoundStarted?.Invoke(roundIndex + 1);
        }

        public void AdvanceRound()
        {
            if (IsLastRound)
            {
                OnAllRoundsComplete?.Invoke();
                return;
            }

            OnRoundComplete?.Invoke(CurrentRoundIndex + 1);
            StartRound(CurrentRoundIndex + 1);
        }

        public void RegisterTargetDefeated()
        {
            TargetsRemainingInRound = Mathf.Max(0, TargetsRemainingInRound - 1);
            if (TargetsRemainingInRound == 0)
                OnRoundComplete?.Invoke(CurrentRoundIndex + 1);
        }

        private IEnumerator SpawnRoutine(RoundConfigSO round)
        {
            yield return new WaitForSeconds(round.roundStartDelay);
            targetSpawner.SpawnRound(round);
        }

        private static int CountTargets(RoundConfigSO round)
        {
            int total = 0;
            foreach (var entry in round.targets)
                total += entry.count;
            return total;
        }
    }
}
