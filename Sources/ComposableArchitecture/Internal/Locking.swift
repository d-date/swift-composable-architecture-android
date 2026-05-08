import Foundation

#if canImport(Darwin)
  // os_unfair_lock_s comes from <os/lock.h> via the Darwin overlay.
  extension UnsafeMutablePointer<os_unfair_lock_s> {
    @inlinable @discardableResult
    func sync<R>(_ work: () -> R) -> R {
      os_unfair_lock_lock(self)
      defer { os_unfair_lock_unlock(self) }
      return work()
    }

    func lock() {
      os_unfair_lock_lock(self)
    }

    func unlock() {
      os_unfair_lock_unlock(self)
    }
  }

  /// Cross-platform handle backed by `os_unfair_lock` on Apple platforms and
  /// `NSLock` elsewhere. Internal call sites use the same surface
  /// (`allocate(capacity:)`, `initialize(to:)`, `lock()`, `unlock()`,
  /// `sync(_:)`, `deinitialize(count:)`, `deallocate()`) so they compile
  /// identically across platforms.
  @usableFromInline
  typealias _TCAInternalLockHandle = UnsafeMutablePointer<os_unfair_lock_s>

  @inlinable
  func _TCAInternalLockMake() -> _TCAInternalLockHandle {
    let p = _TCAInternalLockHandle.allocate(capacity: 1)
    p.initialize(to: os_unfair_lock())
    return p
  }

  @inlinable
  func _TCAInternalLockDispose(_ p: _TCAInternalLockHandle) {
    p.deinitialize(count: 1)
    p.deallocate()
  }
#else
  /// NSLock-backed fallback used on non-Apple platforms (Linux / Android).
  /// Wrapped in a class so that struct-style allocate/deallocate semantics
  /// emulate the Apple side; the lock survives across `lock()`/`unlock()`
  /// calls because all references share the underlying NSLock.
  @usableFromInline
  final class _TCAInternalLock: @unchecked Sendable {
    @usableFromInline let nsLock = NSLock()

    @usableFromInline init() {}

    @inlinable @discardableResult
    func sync<R>(_ work: () -> R) -> R {
      nsLock.lock()
      defer { nsLock.unlock() }
      return work()
    }

    @inlinable func lock() { nsLock.lock() }
    @inlinable func unlock() { nsLock.unlock() }
  }

  @usableFromInline
  typealias _TCAInternalLockHandle = _TCAInternalLock

  @inlinable
  func _TCAInternalLockMake() -> _TCAInternalLockHandle {
    _TCAInternalLock()
  }

  @inlinable
  func _TCAInternalLockDispose(_: _TCAInternalLockHandle) {
    // ARC handles cleanup; nothing to do.
  }
#endif

extension NSRecursiveLock {
  @inlinable @discardableResult
  @_spi(Internals) public func sync<R>(work: () -> R) -> R {
    self.lock()
    defer { self.unlock() }
    return work()
  }
}
