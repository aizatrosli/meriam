using UnityEngine;

namespace Meriam.ScriptableObjects
{
    /// <summary>
    /// Configuration for one round of the Raya night meriam game.
    /// Each round spawns a set of targets (pelita, kelapa, periuk) in the kampung yard.
    /// </summary>
    [CreateAssetMenu(menuName = "Meriam/Config/RoundConfig", fileName = "RoundConfig")]
    public class RoundConfigSO : ScriptableObject
    {
        [Header("Round Info")]
        public int roundNumber;

        [Tooltip("Malay announcement shown before the round starts, e.g. 'Pusingan 1'.")]
        public string roundAnnouncementMalay;

        [Header("Target Spawning")]
        public float timeBetweenSpawns = 1.5f;
        public float roundStartDelay = 3f;

        [Tooltip("Targets to spawn this round.")]
        public TargetSpawnEntry[] targets;

        [Header("Scoring")]
        public int completionBonusScore = 500;
        public float timeLimit = 60f;
    }

    [System.Serializable]
    public class TargetSpawnEntry
    {
        public TargetConfigSO config;
        public int count;
        [Tooltip("Horizontal spacing between spawned targets.")]
        public float spacing = 1.5f;
        [Tooltip("Y position offset relative to the ground line.")]
        public float heightOffset = 0f;
    }
}
