#if canImport(SwiftUI)
  import SwiftUI
#endif

extension DependencyValues {
  /// An effect that dismisses the current presentation.
  ///
  /// See the documentation of ``DismissEffect`` for more information.
  public var dismiss: DismissEffect {
    get { self[DismissKey.self] }
    set { self[DismissKey.self] = newValue }
  }
}

/// An effect that dismisses the current presentation.
///
/// On Android (where SwiftUI is unavailable) the SwiftUI-bound overloads
/// (`callAsFunction(animation:)`, `callAsFunction(transaction:)`) are
/// hidden, but the core `dismiss()` and dependency wiring remain.
public struct DismissEffect: Sendable {
  var dismiss: (@MainActor @Sendable () -> Void)?

  @MainActor
  public func callAsFunction(
    fileID: StaticString = #fileID,
    filePath: StaticString = #filePath,
    line: UInt = #line,
    column: UInt = #column
  ) async {
    guard let dismiss = self.dismiss
    else {
      reportIssue(
        """
        A reducer requested dismissal at "\(fileID):\(line)", but couldn't be dismissed.

        This is generally considered an application logic error, and can happen when a reducer \
        assumes it runs in a presentation context. If a reducer can run at both the root level \
        of an application, as well as in a presentation destination, use \
        @Dependency(\\.isPresented) to determine if the reducer is being presented before calling \
        @Dependency(\\.dismiss).
        """,
        fileID: fileID,
        filePath: filePath,
        line: line,
        column: column
      )
      return
    }
    dismiss()
  }

  #if canImport(SwiftUI)
    @MainActor
    public func callAsFunction(
      animation: Animation?,
      fileID: StaticString = #fileID,
      filePath: StaticString = #filePath,
      line: UInt = #line,
      column: UInt = #column
    ) async {
      await callAsFunction(
        transaction: Transaction(animation: animation),
        fileID: fileID,
        filePath: filePath,
        line: line,
        column: column
      )
    }

    @MainActor
    public func callAsFunction(
      transaction: Transaction,
      fileID: StaticString = #fileID,
      filePath: StaticString = #filePath,
      line: UInt = #line,
      column: UInt = #column
    ) async {
      guard let dismiss = self.dismiss
      else {
        reportIssue(
          """
          A reducer requested dismissal at "\(fileID):\(line)", but couldn't be dismissed.

          This is generally considered an application logic error, and can happen when a reducer \
          assumes it runs in a presentation context. If a reducer can run at both the root level \
          of an application, as well as in a presentation destination, use \
          @Dependency(\\.isPresented) to determine if the reducer is being presented before calling \
          @Dependency(\\.dismiss).
          """,
          fileID: fileID,
          filePath: filePath,
          line: line,
          column: column
        )
        return
      }
      withTransaction(transaction) {
        dismiss()
      }
    }
  #endif
}

extension DismissEffect {
  public init(_ dismiss: @escaping @MainActor @Sendable () -> Void) {
    self.dismiss = dismiss
  }
}

private enum DismissKey: DependencyKey {
  static let liveValue = DismissEffect()
  static let testValue = DismissEffect()
}
