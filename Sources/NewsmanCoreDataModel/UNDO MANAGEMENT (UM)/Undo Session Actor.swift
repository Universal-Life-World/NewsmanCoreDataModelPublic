import Foundation
import Combine
import CoreData

@available(iOS 15.0, macOS 12.0, *)
public func withOpenUndoSession(of target: NMUndoManageable, action: () async throws -> () ) async rethrows {
 await NMUndoSession.open(target: target)  //OPEN UNDO/REDO SESSION!
 try await action()
 await NMUndoSession.close() //CLOSE UNDO/REDO SESSION AFTER MOVE!

}

@available(iOS 15.0, macOS 12.0, *)
public func withGlobalUndoSession( action: () async throws -> () ) async rethrows {
 let globalTarget = NMGlobalUndoManager.shared
 await NMUndoSession.open(target: globalTarget)  //OPEN UNDO/REDO SESSION!
 try await action()
 await NMUndoSession.close() //CLOSE UNDO/REDO SESSION AFTER MOVE
}


public actor NMUndoSession: NSObject {
 
 //if this flag is set the session is undone somehow and must be skipped in UM stack.
 public fileprivate (set) var isExecuted = false
 fileprivate func setExecutedState(_ state: Bool ) { isExecuted = state }
 
 //if this flag is set the session target MO was deleted from MOC and must be skipped in UM stack.
 public fileprivate (set) var hasDeletedTarget = false
 fileprivate func setTargetDeletedState(_ state: Bool ) { hasDeletedTarget = state }
 
 public var isSkipped: Bool { isExecuted || hasDeletedTarget }
 
 public var isEmpty: Bool { blockOperations.isEmpty }
 public var blockCount: Int { blockOperations.count }
 
 weak fileprivate (set) var targetObject: NMUndoManageable?
 public func updateTarget(_ newTarget: NMUndoManageable ) { targetObject = newTarget }
 
 //weak fileprivate (set) var targetOwner:  NMUndoManageable?
 
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
 

 
 public final func undoTask(dependency: Task<Void, Error>?) -> Task<Void, Error> {
  Task.detached { [ unowned self ] in
   try await dependency?.value
   let operations = await blockOperations
   for op in operations.reversed() { try await op.execute() }
   await setExecutedState(true)
   await redoSession.setExecutedState(false)
   
  }
 }
 
 public final func redoTask(dependency: Task<Void, Error>?) -> Task<Void, Error> {
  Task.detached { [ unowned self ] in
   try await dependency?.value
   let operations = await redoSession.blockOperations
   for op in operations { try await op.execute() }
   await redoSession.setExecutedState(true)
   await setExecutedState(false)
  }
 }
 
 private var undoTargetOwnerSubscription: AnyCancellable?
 
 // Create subscriprion to listen to target owner keypath changes.
 @available(iOS 15.0, macOS 12.0, *)
 fileprivate final func subscribeUndoTargetOwner() async  {
  guard let target = self.targetObject else { return }
  undoTargetOwnerSubscription = await target.subscribeTargetOwner { [ unowned self ] in
   await Self.register(session: self, with: target)
  }
 }
 
 private var undoTargetDeletedSubscription: AnyCancellable?
 
 // Create subscriprion to listen to target MO isDeleted state changes.
 @available(iOS 15.0, macOS 12.0, *)
 fileprivate final func subscribeUndoTargetDeleted() async  {
  guard let target = self.targetObject else { return }
  undoTargetOwnerSubscription = await target.subscribeTargetDeleted { [ unowned self ] isDeleted in
   hasDeletedTarget = isDeleted
  }
 }
 
 
 // Opens new undo & corresponding redo session lazily with target object without blocking.
 // if current undo session is open all undo & redo tasks are registered with this open current session.
 // if you try to open new session the session will not be opened until you close current one.
 
 @available(iOS 15.0, macOS 12.0, *)
 @MainActor public static func open(target: NMUndoManageable) async {
  guard currentSession == nil else { return }
  let newSession = NMUndoSession(target: target)
//  await newSession.setTargetOwner(target.undoTargetOwner)
  Self.currentSession = newSession
  await target.undoManager.registerUndoSession(newSession) // register this new undo session with its target UM.
  await register(session: newSession, with: target)        // register new session recursively with target owners UMs.
  await newSession.subscribeUndoTargetOwner()   // listen to target owner changes and reregister session with UMs.
  await newSession.subscribeUndoTargetDeleted() // listen to target MO isDeleted property state.
 }
 
// fileprivate func setTargetOwner(_ newOwner: NMUndoManageable?){
//  targetOwner = newOwner
// }
 

 //Registers undo session with target recurcively with its owner UMs.
 // * Single elements sessions with their respective direct owner UM - folders UMs or snippets UMs.
 // * Folders sessions with their snippets UMs as direct owners.
 // * Snippets with Core Data Model UM asa direct owner.
 
 @MainActor fileprivate static func register(session: NMUndoSession, with target: NMUndoManageable?) async  {
 
  guard let nextOwner = await target?.undoTargetOwner else { return }
  await nextOwner.undoManager.registerUndoSession(session)
  await register(session: session, with: nextOwner)
  
 }
 
// @MainActor fileprivate static func reregisterUndoSession() async  {
//  guard let session = currentSession else { return }
//  let target = await session.targetObject
//  let prevOwner = await session.targetOwner
//  let currOwner = target?.undoTargetOwner
//  guard prevOwner !== currOwner else { return }
//  await register(session: session, with: target)
//
// }
 
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
//  await target.undoManager.registerUndoSession(newSession)
 }
 
 
 // closes current session and unblocks (resumes continuation) to open new one.
 @MainActor public static func close() async {
  
  if closeContinuations.count != 0 { closeContinuations.remove(at: 0).resume() }
  
  await undoRegistrationTask?.value
  await redoRegistrationTask?.value
  //await reregisterUndoSession()
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
 
 private init(target: NMUndoManageable?) {
  self.targetObject = target
  self.isOpen = true
  super.init()

 }
}

