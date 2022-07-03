
public struct UMUndoBlockOperation {
 let block: @Sendable () async throws -> ()
 
 public func execute() async throws {
  try await block()
 }
}
