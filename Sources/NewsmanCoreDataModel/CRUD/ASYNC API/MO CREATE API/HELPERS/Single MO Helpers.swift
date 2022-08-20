import CoreData

@available(iOS 15.0, macOS 12.0, *)
public extension NSManagedObject {
 
 @discardableResult func updated<T: NSManagedObject>(_ block: ( (T) throws -> () )? ) async throws -> T {
  
  try Task.checkCancellation()
  
  guard let context = self.managedObjectContext else {
   throw ContextError.noContext(object: self, entity: .object, operation: .updateObject)
  }
  
  guard let block = block else { return self as! T }
  
  return try await context.perform { [ unowned self ] in
   do {
    try Task.checkCancellation()
    
    guard self.isDeleted == false else {
     throw ContextError.isDeleted(object: self, entity: .object, operation: .updateObject)
    }
    
    try block(self as! T)
    return self as! T
   }
   catch {
    context.delete(self)
    throw error
   }
  }
 }
 
 
 @discardableResult func persisted<T: NSManagedObject>(_ persist: Bool = true ) async throws -> T {
  try Task.checkCancellation()
  
  guard persist else { return self as! T }
  
  guard let context = self.managedObjectContext else {
   throw ContextError.noContext(object: self, entity: .object, operation: .persistObject )
  }
  
  return try await context.perform { [ unowned self ] in
   try Task.checkCancellation()
   guard self.hasChanges else { return self as! T }
   try context.save()
   return self as! T
  }
 }
 
 @discardableResult func withFileStorage<T: NSManagedObject>() async throws -> T {
  try Task.checkCancellation()
  guard let manageStorage = self as? NMFileStorageManageable else { return self as! T  }
  return try await manageStorage.withFileStorage() as! T
 }
 
 
 
}//public extension NSManagedObject...
