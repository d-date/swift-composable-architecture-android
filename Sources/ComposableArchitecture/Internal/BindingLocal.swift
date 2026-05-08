// Lifted out of `Deprecations.swift` so it remains available even when
// the rest of that file is gated on `#if canImport(SwiftUI)` for the
// Android port. Used by `Core.swift` unconditionally.
enum BindingLocal {
  @TaskLocal static var isActive = false
}
