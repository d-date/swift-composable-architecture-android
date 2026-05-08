#if canImport(OSLog)
  import OSLog

  @_spi(Logging)
  @preconcurrency @MainActor
  public final class Logger {
    public static let shared = Logger()
    public var isEnabled = false
    @Published public var logs: [String] = []
    #if DEBUG
      var logger: os.Logger {
        os.Logger(subsystem: "composable-architecture", category: "store-events")
      }
      public func log(level: OSLogType = .default, _ string: @autoclosure () -> String) {
        guard self.isEnabled else { return }
        let string = string()
        if isRunningForPreviews {
          print("\(string)")
        } else {
          self.logger.log(level: level, "\(string)")
        }
        self.logs.append(string)
      }
      public func clear() {
        self.logs = []
      }
    #else
      @inlinable @inline(__always)
      public func log(level: OSLogType = .default, _ string: @autoclosure () -> String) {
      }
      @inlinable @inline(__always)
      public func clear() {
      }
    #endif
  }

  private let isRunningForPreviews =
    ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
#else
  import Foundation

  // Fallback Logger for non-Apple platforms (Linux/Android) where OSLog is
  // unavailable. Keeps the same API surface so call sites compile without
  // `#if canImport(OSLog)` guards.
  @_spi(Logging)
  @preconcurrency @MainActor
  public final class Logger {
    public static let shared = Logger()
    public var isEnabled = false
    public var logs: [String] = []

    public func log(level: Int = 0, _ string: @autoclosure () -> String) {
      guard self.isEnabled else { return }
      let s = string()
      print(s)
      self.logs.append(s)
    }

    public func clear() {
      self.logs = []
    }
  }
#endif
