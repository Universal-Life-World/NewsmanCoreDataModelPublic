import CoreData

public protocol NMUndoManageable: AnyObject  {
 @MainActor var undoManager: NMUndoManager { get set }
}

@MainActor public class NMGlobalUndoManager: NMUndoManageable{
 public lazy var undoManager = NMUndoManager(targetID: nil)
 public static let shared = NMGlobalUndoManager()
 private init (){}
 
 public static func undo() async throws  { try await shared.undoManager.undo() }
 public static func redo() async throws  { try await shared.undoManager.redo() }
 
}


@available(iOS 15.0, *)
public extension NMUndoManageable {
 func withRegisteredUndoManager(targetID: UUID) async -> Self {
  guard let registeredUndoManager = await NMUndoManager[targetID] else { return self }
  await MainActor.run{ self.undoManager = registeredUndoManager }
  return self
 }
 
 @discardableResult func undo(persist: Bool = false) async throws -> Self where Self: NSManagedObject {
  try await undoManager.undo()
  return try await self.persisted(persist)
 }
 
 @discardableResult func redo(persist: Bool = false) async throws -> Self where Self: NSManagedObject {
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
