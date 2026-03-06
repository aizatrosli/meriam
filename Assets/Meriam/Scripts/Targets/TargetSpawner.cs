using System.Collections;
using Meriam.Core;
using Meriam.ScriptableObjects;
using UnityEngine;

namespace Meriam.Targets
{
    /// <summary>
    /// Spawns targets in the kampung yard according to a RoundConfigSO.
    /// Positions them horizontally across the scene's target zone.
    /// </summary>
    public class TargetSpawner : MonoBehaviour
    {
        [SerializeField] private Transform targetZoneCenter;
        [SerializeField] private RoundManager roundManager;

        public void SpawnRound(RoundConfigSO round)
        {
            StartCoroutine(SpawnRoutine(round));
        }

        private IEnumerator SpawnRoutine(RoundConfigSO round)
        {
            float xPos = targetZoneCenter != null ? targetZoneCenter.position.x - 3f : -3f;

            foreach (var entry in round.targets)
            {
                for (int i = 0; i < entry.count; i++)
                {
                    Vector3 spawnPos = new Vector3(
                        xPos,
                        (targetZoneCenter != null ? targetZoneCenter.position.y : 0f) + entry.heightOffset,
                        0f);

                    var obj = Instantiate(entry.config.prefab, spawnPos, Quaternion.identity);
                    var target = obj.GetComponent<TargetBase>();
                    target?.Initialize();

                    xPos += entry.spacing;
                    yield return new WaitForSeconds(round.timeBetweenSpawns);
                }
            }
        }
    }
}
