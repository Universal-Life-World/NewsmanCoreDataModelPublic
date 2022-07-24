
import Foundation

public actor NMUndoManager: NSObject {
 
 @MainActor private static var undoManagersMap = [UUID: NMUndoManager]()
 /* The static undo/redo sessions map used to cache all such sessions globally for the life time of the app and possibly used when object is recreated (undone deleted) after deletion from the object MO context with file storage recovery. The UUID Key in this map corresponds to ID (UUID) field of the Target MO. All static properties including this map are isolated on the main global actor! */
 
 public fileprivate(set) var targetID: UUID? //the UUID of target MO using this undo/redo session.
 
 @MainActor public static var registeredManagers: [NMUndoManager] { Array(undoManagersMap.values) }
 
 @MainActor public static var registeredTargets: [UUID] { Array(undoManagersMap.keys) }
 
 @MainActor public static subscript(targetID: UUID) -> NMUndoManager? { undoManagersMap[targetID] }
 
 public var sessionCount: Int { undoStack.count }
 
 public var executedUndoSessions: [NMUndoSession] {
  get async throws {
   try await withThrowingTaskGroup(of: (NMUndoSession, Bool).self, returning: [NMUndoSession].self){ group in
    undoStack.forEach { session in
     group.addTask{ (session, await session.isExecuted) }
    }
    return try await group.filter{$0.1}.reduce(into: []){ $0.append($1.0)}
     
   }
  }
 }
 
 public var lastExecutedUndo: NMUndoSession? {
  get async throws { try await executedUndoSessions.first }
 }
 
 public var firstExecutedUndo: NMUndoSession? {
  get async throws { try await executedUndoSessions.last }
 }
  
 public var executedUndoCount: Int {
  get async throws { try await executedUndoSessions.count }
 }
 
 public var executedRedoSessions: [NMUndoSession] {
  get async throws {
   try await withThrowingTaskGroup(of: (NMUndoSession, Bool).self, returning: [NMUndoSession].self){ group in
    undoStack.forEach { session in
     group.addTask{ (session, await session.redoSession.isExecuted) }
    }
    return try await group.filter{$0.1}.reduce(into: []){ $0.append($1.0)}
    
   }
  }
 }
 
 public var lastExecutedRedo: NMUndoSession? {
  get async throws { try await executedRedoSessions.last }
 }
 
 public var firstExecutedRedo: NMUndoSession? {
  get async throws { try await executedRedoSessions.first }
 }
 
 public var executedRedoCount: Int {
  get async throws { try await executedRedoSessions.count }
 }
 
 public var unexecutedUndoSessions: [NMUndoSession] {
  get async throws {
   try await withThrowingTaskGroup(of: (NMUndoSession, Bool).self, returning: [NMUndoSession].self){ group in
    undoStack.forEach { session in
     group.addTask{ (session, await session.isExecuted) }
    }
    return try await group.filter{!$0.1}.reduce(into: []){ $0.append($1.0)}
    
   }
  }
 }
 
 public var lastUnexecutedUndo: NMUndoSession? {
  get async throws { try await unexecutedUndoSessions.first }
 }
 
 public var firstUnexecutedUndo: NMUndoSession? {
  get async throws { try await unexecutedUndoSessions.last }
 }
 
 public var unexecutedUndoCount: Int {
  get async throws { try await unexecutedUndoSessions.count }
 }
 
 
 public var unexecutedRedoSessions: [NMUndoSession] {
  get async throws {
   try await withThrowingTaskGroup(of: (NMUndoSession, Bool).self, returning: [NMUndoSession].self){ group in
    undoStack.forEach { session in
     group.addTask{ (session, await session.redoSession.isExecuted) }
    }
    return try await group.filter{!$0.1}.reduce(into: []){ $0.append($1.0)}
    
   }
  }
 }
 
 public var lastUnexecutedRedo: NMUndoSession? {
  get async throws { try await unexecutedRedoSessions.last }
 }
 
 public var firstUnexecutedRedo: NMUndoSession? {
  get async throws { try await unexecutedRedoSessions.first }
 }
 
 public var unexecutedRedoCount: Int {
  get async throws { try await unexecutedRedoSessions.count }
 }
 
 public var isEmpty: Bool { undoStack.isEmpty }
 
 public var currentUndo: NMUndoSession?{ undoStackPointer < 0 ? nil : undoStack[undoStackPointer] }
 
 public var topUndo: NMUndoSession? { isEmpty ? nil : undoStack[sessionCount - 1] }
 
 public var bottomUndo: NMUndoSession? { undoStack.first }
 
 private var undoStackPointer: Int = -1
 
 fileprivate var undoStack = [NMUndoSession]()
 
 public func registerUndoSession(_ session: NMUndoSession) async {
  
  /* Registers this Undo Session with global sessions map when the first block is actually registered with this session. Empty sessions are not attached to this map! The process is isolated to the main global actor. */
  
  if isEmpty, let targetID = targetID {
   await MainActor.run { Self.undoManagersMap[targetID] = self }
  }
  
  undoStack.insert(session, at: 0)
  undoStackPointer += 1
 }
 
 fileprivate var currentSessionTask: Task<Void, Error>?
 
 public var canUndo: Bool { undoStackPointer >= 0 }
 public var canRedo: Bool { undoStackPointer < undoStack.count - 1 }
 
 
 fileprivate func skipUndo() async  {
  while undoStackPointer >= 0 {
   if await undoStack[undoStackPointer].isExecuted {
    undoStackPointer -= 1
   } else {
    break
   }
  }
 }
 
 fileprivate func skipRedo() async  {
  while undoStackPointer < undoStack.count - 1 {
   if await undoStack[undoStackPointer + 1].redoSession.isExecuted {
    undoStackPointer += 1
   } else {
    break
   }
  }
 }
 
 public func undo() async throws {
  
  print (#function)
 
  await skipUndo()
  guard canUndo else { return }
  let currentSession = undoStack[undoStackPointer]
  let currentTask = currentSessionTask
  currentSessionTask = await currentSession.undoTask(dependency: currentTask)
  try await currentSessionTask?.value
  undoStackPointer -= 1
 
  print ("UNDO DONE", #function)
 }
 
 public func redo() async throws {
  
  print (#function)
  
  await skipRedo()
  guard canRedo else { return }
  undoStackPointer += 1
  let currentSession = undoStack[undoStackPointer]
  let currentTask = currentSessionTask
  currentSessionTask = await currentSession.redoTask(dependency: currentTask)
  try await currentSessionTask?.value
  
  print ("REDO DONE", #function)
 }
 
 
 public init(targetID: UUID?) {
  super.init()
  self.targetID = targetID
 }
}
