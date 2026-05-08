// Combine namespace shim for the swift-composable-architecture-android fork.
//
// On Apple platforms this re-exports the system Combine framework so the
// rest of the package compiles unchanged. On Linux / Android we re-export
// OpenCombine + OpenCombineDispatch + OpenCombineFoundation so that
// `AnyPublisher`, `PassthroughSubject`, `AnyCancellable`,
// `Publishers.HandleEvents`, `Publishers.PrefixUntilOutput`, etc. are still
// in scope.
//
// TCA source files in this fork replace `import Combine` with
// `import _TCACombineShim` so a single file controls which Combine
// implementation is in scope per platform.

#if canImport(Combine)
  @_exported import Combine
#else
  @_exported import OpenCombine
  @_exported import OpenCombineDispatch
  @_exported import OpenCombineFoundation
#endif
