using System.Collections.Generic;
using UnityEngine;

namespace Meriam.Events
{
    /// <summary>
    /// ScriptableObject-based event bus (Ryan Hipple pattern).
    /// Decouples systems: e.g. CannonFirer raises OnTargetHit;
    /// ScoreManager and HUDController both listen without knowing each other.
    /// </summary>
    [CreateAssetMenu(menuName = "Meriam/Events/GameEvent", fileName = "NewGameEvent")]
    public class GameEventSO : ScriptableObject
    {
        private readonly List<GameEventListenerSO> listeners = new List<GameEventListenerSO>();

        public void Raise(object data = null)
        {
            for (int i = listeners.Count - 1; i >= 0; i--)
            {
                listeners[i].OnEventRaised(data);
            }
        }

        public void Register(GameEventListenerSO listener)
        {
            if (!listeners.Contains(listener))
                listeners.Add(listener);
        }

        public void Unregister(GameEventListenerSO listener)
        {
            listeners.Remove(listener);
        }
    }
}
