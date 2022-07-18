
import Foundation

public actor UMUndoBlockOperation: NSObject {

 public fileprivate (set) var isExecuted = false
 
 let block: TOperationBlock
 
 typealias TOperationBlock = @Sendable () async throws -> ()
 
 init (_ block: @escaping TOperationBlock){
  self.block = block
  super.init()
 }

 public func execute() async throws {
  try await block()
  isExecuted = true
 }
}
