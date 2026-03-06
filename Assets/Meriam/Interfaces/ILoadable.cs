namespace Meriam.Interfaces
{
    /// <summary>
    /// Implemented by CannonLoader. Player 2 (Anak Bongsu) holds the load button
    /// to pack the meriam buluh with gunpowder before firing.
    /// </summary>
    public interface ILoadable
    {
        bool IsLoaded { get; }
        float LoadProgress { get; }
        void BeginLoading();
        void CancelLoading();
        void ForceLoad();
        event System.Action OnLoadComplete;
    }
}
