import CoreData

public protocol NMUndoManageable where Self: NSManagedObject {
 @MainActor var undoManager: NMUndoManager { get set }
}


@available(iOS 15.0, *)
public extension NMUndoManageable {
 func withRegisteredUndoManager(targetID: UUID) async -> Self {
  guard let registeredUndoManager = await NMUndoManager[targetID] else { return self }
  await MainActor.run{ self.undoManager = registeredUndoManager }
  return self
 }
 
 @discardableResult func undo(persist: Bool = false) async throws -> Self {
  try await undoManager.undo()
  return try await self.persisted(persist)
 }
 
 @discardableResult func redo(persist: Bool = false) async throws -> Self {
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
