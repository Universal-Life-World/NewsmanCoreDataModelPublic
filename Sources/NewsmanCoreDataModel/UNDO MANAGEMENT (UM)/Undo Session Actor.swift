import Foundation


public func withOpenUndoSession(of target: NMUndoManageable, action: () async throws -> () ) async rethrows {
 await NMUndoSession.open(target: target)  //OPEN UNDO/REDO SESSION!
 try await action()
 await NMUndoSession.close() //CLOSE UNDO/REDO SESSION AFTER MOVE!

}

public func withGlobalUndoSession( action: () async throws -> () ) async rethrows {
 let globalTarget = NMGlobalUndoManager.shared
 await NMUndoSession.open(target: globalTarget)  //OPEN UNDO/REDO SESSION!
 try await action()
 await NMUndoSession.close() //CLOSE UNDO/REDO SESSION AFTER MOVE
}

public actor NMUndoSession: NSObject {
 
 public fileprivate (set) var isExecuted = false
 
 public var isEmpty: Bool { blockOperations.isEmpty }
 public var blockCount: Int { blockOperations.count }
 
 unowned fileprivate let targetObject: NMUndoManageable
 
 @MainActor public private(set) var isOpen: Bool
 
 @MainActor public static var current: NMUndoSession? { currentSession }
 
 public fileprivate(set) lazy var redoSession = NMUndoSession(target: targetObject)
 
 @MainActor public static var hasOpenSession: Bool {
  guard let currentSession = currentSession, currentSession.isOpen else { return false }
  return true
 }
 
 @MainActor static fileprivate var currentSession: NMUndoSession? {
  didSet {
   if let current = oldValue, currentSession == nil { current.isOpen = false }
  }
 }
 
 //public var sessionTask: Task<Void, Error>?
 
 fileprivate var blockOperations = [UMUndoBlockOperation]()
 
 @MainActor fileprivate static var closeContinuations = [CheckedContinuation<Void, Never>]()
 
 @MainActor fileprivate static var undoRegistrationTask: Task<Void, Never>?
 @MainActor fileprivate static var redoRegistrationTask: Task<Void, Never>?
 
 fileprivate func setExecutedState(_ state: Bool ) { isExecuted = state }
 
 public func undoTask(dependency: Task<Void, Error>?) -> Task<Void, Error> {
  Task.detached { [ unowned self ] in
   try await dependency?.value
   let operations = await blockOperations
   for op in operations.reversed() { try await op.execute() }
   await setExecutedState(true)
   await redoSession.setExecutedState(false)
   
  }
 }
 
 public func redoTask(dependency: Task<Void, Error>?) -> Task<Void, Error> {
  Task.detached { [ unowned self ] in
   try await dependency?.value
   let operations = await redoSession.blockOperations
   for op in operations { try await op.execute() }
   await redoSession.setExecutedState(true)
   await setExecutedState(false)
  }
 }
 
 
 // opens new undo/redo session with target object without blocking.
 // if current session is open all undo/redo tasks are registered with this open current session.
 // if you try to open new session the session will not be opened until you close current one
 @MainActor public static func open(target: NMUndoManageable) async {
  guard currentSession == nil else { return }
  let newSession = NMUndoSession(target: target)
  Self.currentSession = newSession
  await target.undoManager.registerUndoSession(newSession)
 }
 
 @MainActor fileprivate static func closeWaiter() async  {
  guard currentSession != nil else { return }
  await withCheckedContinuation{ closeContinuations.append($0) }
 }
 
 // opens new undo/redo session with target object with blocking.
 // if current session is open all undo/redo tasks are registered with this open current session.
 // you can try open other sessions but opening will wait for closing the current one.
 @MainActor public static func waitAndOpen(target: NMUndoManageable) async {
  await closeWaiter()
  let newSession = NMUndoSession(target: target)
  Self.currentSession = newSession
  await target.undoManager.registerUndoSession(newSession)
 }
 
 
 // closes current session and unblocks (resumes continuation) to open new one.
 @MainActor public static func close() async {
  
  if closeContinuations.count != 0 { closeContinuations.remove(at: 0).resume() }
  
  await undoRegistrationTask?.value
  await redoRegistrationTask?.value
  
  currentSession = nil
 }
 
 
 // attach new undo/redo task
 fileprivate func add(_ block: @Sendable @escaping () async throws -> () ) async {
  blockOperations.append(.init(block))
 }
 
 @MainActor public static func registerUndo(_ block: @Sendable @escaping () async throws -> () ) async {
  let currentTask = undoRegistrationTask
  
  undoRegistrationTask = Task {
   await currentTask?.value
   await currentSession?.add(block)
  }
  
 }
 
 
 @MainActor public static func registerRedo(_ block: @Sendable @escaping () async throws -> () ) async {
  let currentTask = redoRegistrationTask
  
  redoRegistrationTask = Task {
   await currentTask?.value
   await currentSession?.redoSession.add(block)
  }

  
 }
 
 //TO BE USED FROM ASYNC CONTEXT.
 @MainActor public static func register(undo: @Sendable @escaping () async throws -> (),
                                        with redo: @Sendable @escaping () async throws -> ()) async {
  await registerUndo(undo)
  await registerRedo(redo)
 }
 
 //TO BE USED FROM SYNC CONTEXT.
 public static func register(undo: @Sendable @escaping () async throws -> (),
                             with redo: @Sendable @escaping () async throws -> ()) {
  Task.detached {
   await registerUndo(undo)
   await registerRedo(redo)
  }
 }
 
 private init(target: NMUndoManageable) {
  self.targetObject = target
  self.isOpen = true
  super.init()
 }
}

