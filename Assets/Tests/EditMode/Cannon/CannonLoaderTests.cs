using Meriam.Cannon;
using Meriam.ScriptableObjects;
using NUnit.Framework;
using UnityEngine;

namespace Meriam.Tests.EditMode
{
    [TestFixture]
    public class CannonLoaderTests
    {
        private GameObject go;
        private CannonLoader loader;
        private FakeTimeProvider fakeTime;

        [SetUp]
        public void SetUp()
        {
            go = new GameObject("TestLoader");
            loader = go.AddComponent<CannonLoader>();

            var config = ScriptableObject.CreateInstance<GameConfigSO>();
            config.cannonLoadDuration = 2f;

            loader.InitializeForTesting(config);

            fakeTime = new FakeTimeProvider { DeltaTime = 0f };
            loader.SetTimeProvider(fakeTime);
        }

        [TearDown]
        public void TearDown()
        {
            Object.DestroyImmediate(go);
        }

        [Test]
        public void InitialState_IsNotLoaded()
        {
            Assert.IsFalse(loader.IsLoaded);
        }

        [Test]
        public void InitialProgress_IsZero()
        {
            Assert.AreEqual(0f, loader.LoadProgress, 0.001f);
        }

        [Test]
        public void BeginLoading_DoesNotImmediatelyLoad()
        {
            loader.BeginLoading();
            // Simulate 0 frames
            Assert.IsFalse(loader.IsLoaded);
        }

        [Test]
        public void AfterFullDuration_IsLoaded()
        {
            loader.BeginLoading();
            // Simulate enough delta time via manual Update calls
            fakeTime.DeltaTime = 2.1f;
            loader.SendMessage("Update"); // triggers Update via MonoBehaviour reflection
            Assert.IsTrue(loader.IsLoaded);
        }

        [Test]
        public void CancelLoading_ResetsProgress()
        {
            loader.BeginLoading();
            fakeTime.DeltaTime = 1f;
            loader.SendMessage("Update");
            loader.CancelLoading();
            Assert.AreEqual(0f, loader.LoadProgress, 0.001f);
            Assert.IsFalse(loader.IsLoaded);
        }

        [Test]
        public void ForceLoad_SetsIsLoadedTrue()
        {
            loader.ForceLoad();
            Assert.IsTrue(loader.IsLoaded);
        }

        [Test]
        public void ForceLoad_SetsProgressToOne()
        {
            loader.ForceLoad();
            Assert.AreEqual(1f, loader.LoadProgress, 0.001f);
        }

        [Test]
        public void OnLoadComplete_FiredWhenLoaded()
        {
            bool fired = false;
            loader.OnLoadComplete += () => fired = true;
            loader.ForceLoad();
            Assert.IsTrue(fired);
        }

        [Test]
        public void BeginLoading_WhenAlreadyLoaded_IsNoOp()
        {
            loader.ForceLoad();
            int fireCount = 0;
            loader.OnLoadComplete += () => fireCount++;
            loader.BeginLoading(); // should be no-op
            Assert.AreEqual(1, fireCount); // only fired once (from ForceLoad)
        }

        [Test]
        public void LoadDuration_MatchesConfig()
        {
            Assert.AreEqual(2f, loader.LoadDuration, 0.001f);
        }
    }
}
