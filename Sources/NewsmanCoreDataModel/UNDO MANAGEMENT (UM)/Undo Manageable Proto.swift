import CoreData
import Combine

public protocol NMUndoManageable where Self: NSObject {
 
 var undoManager:     NMUndoManager                                       { get set   }
 var undoTargetOwner: NMUndoManageable?                                   { get async }
 
 var undoTargetOwnerPublisher: AnyPublisher<NMUndoManageable, Never>      { get       }
 func subscribeTargetOwner(handler: @escaping () async  -> ()) async -> AnyCancellable?
 
 var undoTargetDeletedPublisher: AnyPublisher<Bool, Never>                { get       }
 func subscribeTargetDeleted(handler: @escaping (Bool) -> ()) async -> AnyCancellable?
}


extension NMUndoManageable where Self: NMBaseSnippet {
 public var undoTargetOwnerPublisher: AnyPublisher<NMUndoManageable, Never> {
  publisher(for: \.coreDataModel, options: [.new])
   .compactMap{ $0 }
   .eraseToAnyPublisher()
 }
 
 public func subscribeTargetOwner(handler: @escaping () async  -> ()) async -> AnyCancellable? {
  undoTargetOwnerPublisher.sink{ _ in Task { await handler() }}
 }
}

@available(iOS 15.0, macOS 12.0, *)
extension NMUndoManageable where Self: NSManagedObject {
 
 public var undoTargetDeletedPublisher: AnyPublisher<Bool, Never> {
  publisher(for: \.isDeleted, options: [.new]).eraseToAnyPublisher()
 }
 
 public func subscribeTargetDeleted(handler: @escaping (Bool) -> ()) async -> AnyCancellable? {
  await managedObjectContext?.perform {[ unowned self ] in
   undoTargetDeletedPublisher.sink(receiveValue: handler)
  }
 }
}

@available(iOS 15.0, macOS 12.0, *)
extension NMUndoManageable where Self: NMBaseContent {
 public func subscribeTargetOwner(handler: @escaping () async  -> ()) async -> AnyCancellable? {
  await managedObjectContext?.perform {[ unowned self ] in
   undoTargetOwnerPublisher.sink{ _ in Task { await handler() }}
  }
 }
}

public class NMGlobalUndoManager: NSObject, NMUndoManageable {
 public var undoTargetDeletedPublisher: AnyPublisher<Bool, Never> { Empty().eraseToAnyPublisher() }
 
 public func subscribeTargetDeleted(handler: @escaping (Bool) -> ()) async -> AnyCancellable? { nil }

 public func subscribeTargetOwner(handler: @escaping () async -> ()) async -> AnyCancellable? { nil }
 
 public var undoTargetOwnerPublisher: AnyPublisher<NMUndoManageable, Never> { Empty().eraseToAnyPublisher() }
 
 public let undoTargetOwner: NMUndoManageable? = nil
 
 public lazy var undoManager = NMUndoManager(targetID: nil)
 public static let shared = NMGlobalUndoManager()
 
 private override init (){} // sigleton
 
 public static func undo() async throws  { try await shared.undoManager.undo() }
 public static func redo() async throws  { try await shared.undoManager.redo() }
 
}


@available(iOS 15.0, *)
public extension NMUndoManageable where Self: NMFileStorageManageable {
 @discardableResult func withRegisteredUndoManager(targetID: UUID) async -> Self {
  guard let registeredUndoManager = await NMUndoManager[targetID] else { return self }
  undoManager = registeredUndoManager
  return self
 }
 
 var targetID: UUID {
  get async throws {
   
   guard let context = self.managedObjectContext else {
    throw ContextError.noContext(object: self, entity: .contentElementContainer, operation: .gettingObjectID)
   }
   
   return try await context.perform {
    guard let ID = self.id else {
     throw ContextError.noID(object: self, entity: .contentElementContainer, operation: .gettingObjectID)
    }
    return ID
   }
  }
 }

 
 @discardableResult func withRecoveredUndoManager() async throws -> Self {
  let targetID = try await self.targetID
  guard let registeredUndoManager = await NMUndoManager[targetID] else { return self }
  undoManager = registeredUndoManager
  return self
 }
 
 @discardableResult func undo(persist: Bool = false) async throws -> Self  {
  try await undoManager.undo()
  return try await self.persisted(persist)
 }
 
 @discardableResult func redo(persist: Bool = false) async throws -> Self  {
  try await undoManager.redo()
  return try await self.persisted(persist)
 }
 
}


public extension Collection where Element: NMUndoManageable {
 func withRegisteredUndoManager(targetIDs: [UUID]) async -> [ Element ] {
  await MainActor.run{
   zip(self, targetIDs).forEach { (element, ID) in
    guard let registeredUndoManager = NMUndoManager[ID] else { return }
    element.undoManager = registeredUndoManager
   }
  }
  
  return Array(self)
 }
}
