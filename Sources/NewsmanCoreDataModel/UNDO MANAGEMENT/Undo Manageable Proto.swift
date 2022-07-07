import CoreData

public protocol NMUndoManageable where Self: NSManagedObject {
 var undoManager: NMUndoManager { get }
}


