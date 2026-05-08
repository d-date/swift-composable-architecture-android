// Non-SwiftUI Store accessors that the @dynamicMemberLookup attribute on
// `Store` requires. These exist on every platform so that
// `Sources/ComposableArchitecture/Store.swift` compiles when SwiftUI is
// unavailable (Android / Linux). On Apple platforms the SwiftUI-bound
// `Store+Observation.swift` adds richer integrations on top.

#if canImport(Observation)
  import Observation
#endif

extension Store where State: ObservableState {
  /// Direct access to state in the store when `State` conforms to
  /// ``ObservableState``.
  public var state: State {
    self._$observationRegistrar.access(self, keyPath: \.currentState)
    return self.currentState
  }

  public subscript<Value>(dynamicMember keyPath: KeyPath<State, Value>) -> Value {
    self.state[keyPath: keyPath]
  }
}

extension Store: Equatable {
  public static nonisolated func == (lhs: Store, rhs: Store) -> Bool {
    lhs === rhs
  }
}

extension Store: Hashable {
  public nonisolated func hash(into hasher: inout Hasher) {
    hasher.combine(ObjectIdentifier(self))
  }
}

extension Store: Identifiable {}
