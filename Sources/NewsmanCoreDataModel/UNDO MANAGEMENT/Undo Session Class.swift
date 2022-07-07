import Foundation

public actor NMUndoSession: NSObject {
 
 unowned fileprivate let targetObject: AnyObject
 
 @MainActor public static var current: NMUndoSession? { currentSession }
 
 @MainActor static fileprivate var currentSession: NMUndoSession?
 
 //public var sessionTask: Task<Void, Error>?
 
 fileprivate var blockOperations = [UMUndoBlockOperation]()
 fileprivate lazy var redoSession = NMUndoSession(target: targetObject)
 
 @MainActor fileprivate static var closeContinuations = [CheckedContinuation<Void, Never>]()
 
 @MainActor fileprivate static var undoRegistrationTask: Task<Void, Never>?
 @MainActor fileprivate static var redoRegistrationTask: Task<Void, Never>?
 
 
 public func undoTask(dependency: Task<Void, Error>?) -> Task<Void, Error> {
  Task.detached { [ unowned self ] in
   try await dependency?.value
   let operations = await blockOperations
   for op in operations.reversed() { try await op.execute() }
  }
 }
 
 public func redoTask(dependency: Task<Void, Error>?) -> Task<Void, Error> {
  Task.detached { [ unowned self ] in
   try await dependency?.value
   let operations = await redoSession.blockOperations
   for op in operations { try await op.execute() }
  }
 }
 
 
 @MainActor fileprivate static func closeWaiter() async  {
  guard currentSession != nil else { return }
  await withCheckedContinuation{ closeContinuations.append($0) }
 }
 
 @MainActor public static func open(target: AnyObject) async {
  await closeWaiter()
  currentSession = NMUndoSession(target: target)
  
 }
 
 @MainActor public static func close () async {
  if closeContinuations.count != 0 { closeContinuations.remove(at: 0).resume() }
  currentSession = nil
  await undoRegistrationTask?.value
  await redoRegistrationTask?.value
 }
 
 fileprivate func add(_ block: @Sendable @escaping () async throws -> () ) async {
  blockOperations.append(.init(block: block))
 }
 
 @MainActor public static func registerUndo(_ block: @Sendable @escaping () async throws -> () ) async {
  let currentTask = self.undoRegistrationTask
  
  self.undoRegistrationTask = Task {
   await currentTask?.value
   await currentSession?.add(block)
  }
  
 }
 
 
 @MainActor public static func registerRedo(_ block: @Sendable @escaping () async throws -> () ) async {
  let currentTask = self.redoRegistrationTask
  
  self.redoRegistrationTask = Task {
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
 
 private init(target: AnyObject) {
  self.targetObject = target
  super.init()
 }
}

