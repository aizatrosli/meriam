using Meriam.Interfaces;
using UnityEngine;

namespace Meriam.Cannon
{
    /// <summary>
    /// Production ITimeProvider that delegates to Unity's Time.deltaTime.
    /// </summary>
    public class UnityTimeProvider : ITimeProvider
    {
        public float DeltaTime => Time.deltaTime;
    }

    /// <summary>
    /// Fake ITimeProvider for deterministic EditMode unit tests.
    /// Set DeltaTime manually to simulate frame passage without waiting.
    /// </summary>
    public class FakeTimeProvider : ITimeProvider
    {
        public float DeltaTime { get; set; }
    }
}
