// Lifted out of `Deprecations.swift` so it remains available even when
// the rest of that file is gated on `#if canImport(SwiftUI)` for the
// Android port.
enum TaskResultDebugging {
  @TaskLocal static var emitRuntimeWarnings = true
}
