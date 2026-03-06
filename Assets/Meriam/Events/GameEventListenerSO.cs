using UnityEngine;
using UnityEngine.Events;

namespace Meriam.Events
{
    /// <summary>
    /// Component placed on GameObjects that need to respond to a GameEventSO.
    /// Assign the event asset in Inspector and wire up a UnityEvent response.
    /// </summary>
    public class GameEventListenerSO : MonoBehaviour
    {
        [Tooltip("The GameEvent asset this listener subscribes to.")]
        public GameEventSO gameEvent;

        [Tooltip("Called when the event is raised. Data is passed as a generic object.")]
        public UnityEvent<object> response;

        private void OnEnable()
        {
            gameEvent?.Register(this);
        }

        private void OnDisable()
        {
            gameEvent?.Unregister(this);
        }

        public void OnEventRaised(object data)
        {
            response?.Invoke(data);
        }
    }
}
