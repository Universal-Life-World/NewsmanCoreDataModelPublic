import CoreData

public protocol NMUndoManageable where Self: NSManagedObject {
 @MainActor var undoManager: NMUndoManager { get set }
}


public extension NMUndoManageable {
 func withRegisteredUndoManager(targetID: UUID) async -> Self {
  guard let registeredUndoManager = await NMUndoManager[targetID] else { return self }
  await MainActor.run{ self.undoManager = registeredUndoManager }
  return self
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
