
import CoreData

@available(iOS 15.0, macOS 12.0, *)
public extension Collection where Element: NSManagedObject {
 func updated(_ block: ( ([Element]) throws -> () )? ) async throws -> [ Element ] {
  try Task.checkCancellation()
  
  guard let block = block else { return Array(self) }
  
  let contexts = Array(Set(compactMap(\.managedObjectContext)))
  
  if contexts.isEmpty { return [] }
  
  guard contexts.count == 1 else {
   throw ContextError.multipleContextsInCollection(collection: Array(self))
  }
  
  let context = contexts.first!
  
  return try await context.perform {
   try Task.checkCancellation()
   let validObjects = filter{ $0.managedObjectContext != nil && $0.isDeleted == false }
   do {
    print ("UPDATED PERFORM COLLECTION", validObjects.compactMap{$0 as? NMBaseContent})
    try block(validObjects)
    return validObjects
   }
   catch {
    validObjects.forEach{ context.delete($0) }
    throw error
   }
  }
  
 }
 
 func persisted(_ persist: Bool = true ) async throws -> [ Element ] {
  try Task.checkCancellation()
  
  guard persist else { return Array(self) }
  
  let contexts = Array(Set(compactMap(\.managedObjectContext)))
  
  if contexts.isEmpty { return [] }
  
  guard contexts.count == 1 else {
   throw ContextError.multipleContextsInCollection(collection: Array(self))
  }
  
  let context = contexts.first!
  
  return try await context.perform {
   try Task.checkCancellation()
   let validObjects = filter{ $0.managedObjectContext != nil && $0.isDeleted == false }
   guard validObjects.contains(where: \.hasChanges) else { return validObjects }
   try context.save()
   return validObjects
  }
 }
 
 func withFileStorage() async throws -> [ Element ] {
  try Task.checkCancellation()
  
  return try await withThrowingTaskGroup(of: Element?.self, returning: [Element].self)
  { group in
   forEach { object in
    guard let context = object.managedObjectContext else { return }
    group.addTask {
     try Task.checkCancellation()
     if ( await context.perform { object.isDeleted }) { return nil }
     return try await object.withFileStorage()
     
    }
   }
   return try await group.compactMap{ $0 }.reduce(into: []) { $0.append($1) }
  }
 }
 
}
