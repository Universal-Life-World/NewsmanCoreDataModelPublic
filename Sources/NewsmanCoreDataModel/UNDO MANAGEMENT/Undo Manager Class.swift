
import Foundation

public actor NMUndoManager: NSObject {
 
 private var undoStackPointer: Int = -1
 
 fileprivate var undoStack = [NMUndoSession]()
 
 public func registerUndoSession(_ session: NMUndoSession){
  undoStack.insert(session, at: 0)
  undoStackPointer += 1
 }
 
 fileprivate var currentSessionTask: Task<Void, Error>?
 
 public var canUndo: Bool { undoStackPointer >= 0 }
 
 public var canRedo: Bool { undoStackPointer < undoStack.count - 1 }
 
 public func undo() async throws {
  
  print (#function)
  
  guard canUndo else { return }
  let currentSession = undoStack[undoStackPointer]
  let currentTask = currentSessionTask
  currentSessionTask = await currentSession.undoTask(dependency: currentTask)
  try await currentSessionTask?.value
  undoStackPointer -= 1
 }
 
 public func redo() async throws {
  
  print (#function)
  
  guard canRedo else { return }
  undoStackPointer += 1
  let currentSession = undoStack[undoStackPointer]
  let currentTask = currentSessionTask
  currentSessionTask = await currentSession.redoTask(dependency: currentTask)
  try await currentSessionTask?.value
 }
 
 public override init() {
  super.init()
 }
}
