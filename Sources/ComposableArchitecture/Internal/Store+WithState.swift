// `withState` lifted out of `Deprecations.swift` so Store.swift's
// `subscribeToDidSet` helper compiles on platforms where the rest of
// Deprecations.swift is gated behind `canImport(SwiftUI)`.

extension Store {
  @available(
    *,
    deprecated,
    message:
      "Use '@ObservableState', instead. See the following migration guide for more information: https://swiftpackageindex.com/pointfreeco/swift-composable-architecture/main/documentation/composablearchitecture/migratingto1.7#Using-ObservableState"
  )
  public func withState<R>(_ body: (_ state: State) -> R) -> R {
    #if DEBUG && canImport(Perception)
      return _PerceptionLocals.$skipPerceptionChecking.withValue(true) {
        body(self.currentState)
      }
    #else
      return body(self.currentState)
    #endif
  }
}
