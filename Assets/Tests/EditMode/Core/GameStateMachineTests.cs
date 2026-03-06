using Meriam.Core;
using NUnit.Framework;

namespace Meriam.Tests.EditMode
{
    [TestFixture]
    public class GameStateMachineTests
    {
        private GameStateMachine fsm;

        [SetUp]
        public void SetUp()
        {
            fsm = new GameStateMachine();
        }

        [Test]
        public void InitialState_IsMainMenu()
        {
            Assert.AreEqual(GameState.MainMenu, fsm.CurrentState);
        }

        [Test]
        public void Transition_MainMenuToRoundCountdown_Succeeds()
        {
            fsm.TransitionTo(GameState.RoundCountdown);
            Assert.AreEqual(GameState.RoundCountdown, fsm.CurrentState);
        }

        [Test]
        public void Transition_RoundCountdownToPlaying_Succeeds()
        {
            fsm.TransitionTo(GameState.RoundCountdown);
            fsm.TransitionTo(GameState.Playing);
            Assert.AreEqual(GameState.Playing, fsm.CurrentState);
        }

        [Test]
        public void Transition_PlayingToPaused_Succeeds()
        {
            fsm.TransitionTo(GameState.RoundCountdown);
            fsm.TransitionTo(GameState.Playing);
            fsm.TransitionTo(GameState.Paused);
            Assert.AreEqual(GameState.Paused, fsm.CurrentState);
        }

        [Test]
        public void Transition_PausedToPlaying_Succeeds()
        {
            fsm.TransitionTo(GameState.RoundCountdown);
            fsm.TransitionTo(GameState.Playing);
            fsm.TransitionTo(GameState.Paused);
            fsm.TransitionTo(GameState.Playing);
            Assert.AreEqual(GameState.Playing, fsm.CurrentState);
        }

        [Test]
        public void Transition_InvalidTransition_StateUnchanged()
        {
            // MainMenu -> GameOver is invalid
            fsm.TransitionTo(GameState.GameOver);
            Assert.AreEqual(GameState.MainMenu, fsm.CurrentState);
        }

        [Test]
        public void Transition_SameState_IsNoOp()
        {
            int eventCount = 0;
            fsm.OnStateChanged += (_, __) => eventCount++;
            fsm.TransitionTo(GameState.MainMenu);
            Assert.AreEqual(0, eventCount);
        }

        [Test]
        public void OnStateChanged_EventFiredOnValidTransition()
        {
            GameState fromState = GameState.MainMenu;
            GameState toState = GameState.MainMenu;
            fsm.OnStateChanged += (f, t) => { fromState = f; toState = t; };
            fsm.TransitionTo(GameState.RoundCountdown);
            Assert.AreEqual(GameState.MainMenu, fromState);
            Assert.AreEqual(GameState.RoundCountdown, toState);
        }

        [Test]
        public void Transition_GameOverToMainMenu_Succeeds()
        {
            fsm.TransitionTo(GameState.RoundCountdown);
            fsm.TransitionTo(GameState.Playing);
            fsm.TransitionTo(GameState.GameOver);
            fsm.TransitionTo(GameState.MainMenu);
            Assert.AreEqual(GameState.MainMenu, fsm.CurrentState);
        }

        [Test]
        public void Transition_PlayingToRoundComplete_Succeeds()
        {
            fsm.TransitionTo(GameState.RoundCountdown);
            fsm.TransitionTo(GameState.Playing);
            fsm.TransitionTo(GameState.RoundComplete);
            Assert.AreEqual(GameState.RoundComplete, fsm.CurrentState);
        }
    }
}
